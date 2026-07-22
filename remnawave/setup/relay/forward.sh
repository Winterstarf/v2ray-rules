#!/bin/bash

set -euo pipefail

# Output colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check root privileges
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

show_help() {
    local script_name
    script_name=$(basename "$0")
    cat << EOF
UFW Port Forwarding

Usage:
  $script_name [OPTIONS] -i <interface> -p <protocol> -d <dest_port> -t <dest_ip> [-s <src_port>]

OPTIONS:
  -i  Source interface (e.g., eth0) [Required]
  -p  Protocol: tcp, udp [Required]
  -d  Destination port [Required]
  -t  Destination IP [Required]
  -s  Source port (defaults to dest_port)
  -r  Remove the rule instead of adding it
  -h  Show this help message

Example:
  Forward incoming traffic on eth0 port 80 to internal IP 192.168.1.10 port 8080:
  $script_name -i eth0 -p tcp -s 80 -t 192.168.1.10 -d 8080
EOF
}

check_and_install_ufw() {
    # Check absolute path to avoid PATH issues in sudo, and skip apt-get if it exists
    if ! command -v ufw &> /dev/null &&[ ! -x "/usr/sbin/ufw" ]; then
        print_info "UFW not found, installing..."
        apt-get update > /dev/null 2>&1
        DEBIAN_FRONTEND=noninteractive apt-get install -y ufw > /dev/null 2>&1
    fi

    # Only enable the systemd service if it isn't already
    if ! systemctl is-enabled --quiet ufw 2>/dev/null; then
        systemctl enable ufw > /dev/null 2>&1
    fi

    # Only force-enable UFW if it's inactive
    if ! ufw status | grep -qw "active"; then
        ufw --force enable > /dev/null 2>&1
    fi
}

validate_params() {
    if [[ -z "${SRC_IFACE}" ]] || [[ -z "${PROTOCOL}" ]] || [[ -z "${DEST_PORT}" ]] || [[ -z "${DEST_IP}" ]]; then
        print_error "Missing required params"
        echo ""
        show_help
        exit 1
    fi
}

enable_ip_forward() {
    local sysctl_conf="/etc/ufw/sysctl.conf"

    # Safely edit or create the net.ipv4.ip_forward config
    if grep -qE "^net/ipv4/ip_forward=1" "$sysctl_conf"; then
        print_info "IPv4 forwarding in $sysctl_conf is already enabled"
    else
        print_info "Enabling IPv4 forwarding in $sysctl_conf..."
        if grep -q "net/ipv4/ip_forward" "$sysctl_conf"; then
            sed -i 's/^#*\s*\(net\/ipv4\/ip_forward\s*=\).*/\11/' "$sysctl_conf"
        else
            echo "net/ipv4/ip_forward=1" >> "$sysctl_conf"
        fi
        print_status "IPv4 forwarding in $sysctl_conf enabled"
    fi

    # Apply to kernel immediately if not set
    if [[ "$(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null)" != "1" ]]; then
        sysctl -w net.ipv4.ip_forward=1 > /dev/null
        print_status "IPv4 forwarding in kernel enabled"
    fi
}

delete_exact_line() {
    local file="$1"
    local line="$2"
    local tmp_file
    tmp_file=$(mktemp)

    grep -vF -- "$line" "$file" > "$tmp_file"
    cat "$tmp_file" > "$file"
    rm -f "$tmp_file"
}

# Add NAT rules to /etc/ufw/before.rules
add_nat_rules() {
    local rules_file="/etc/ufw/before.rules"
    local s_port="${SRC_PORT:-$DEST_PORT}"

    local exact_prerouting="-A PREROUTING -i ${SRC_IFACE} -p ${PROTOCOL} --dport ${s_port} -j DNAT --to-destination ${DEST_IP}:${DEST_PORT}"
    local exact_postrouting="-A POSTROUTING -p ${PROTOCOL} -d ${DEST_IP} --dport ${DEST_PORT} -j MASQUERADE"

    print_info "Adding NAT rules to before.rules..."

    if grep -qF -- "${exact_prerouting}" "${rules_file}"; then
        print_info "NAT rule for ${PROTOCOL} ${SRC_IFACE}:${s_port} -> ${DEST_IP}:${DEST_PORT} already exists"
        # Heal accidentally deleted MASQUERADE rules if PREROUTING exists
        if ! grep -qF -- "${exact_postrouting}" "${rules_file}"; then
            local tmp_file
            tmp_file=$(mktemp)
            awk -v rule="${exact_postrouting}" '
            /^\*nat/ { in_nat=1 }
            in_nat && /^[[:space:]]*$/ { empty_line=1; next }
            in_nat && empty_line && !/^COMMIT$/ { print ""; empty_line=0 }
            in_nat && /^COMMIT$/ {
                print rule
                print ""
                print "COMMIT"
                in_nat=0
                empty_line=0
                next
            }
            { print }
            ' "${rules_file}" > "$tmp_file"
            cat "$tmp_file" > "${rules_file}"
            rm -f "$tmp_file"

            print_status "Added missing POSTROUTING MASQUERADE rules"
        fi
        return
    fi

    # Check for duplicate listening ports mapping to different destinations
    local conflict_pattern="-A PREROUTING -i ${SRC_IFACE} -p ${PROTOCOL} --dport ${s_port} -j DNAT --to-destination"
    if grep -qE -- "${conflict_pattern}" "${rules_file}"; then
        print_error "Conflicting rules already exist for ${SRC_IFACE}:${s_port} (${PROTOCOL}):"
        grep -E -- "${conflict_pattern}" "${rules_file}" | while read -r line; do
            echo -e "  ${YELLOW}$line${NC}"
        done

        if [ ! -t 0 ]; then
            print_error "Running non-interactively, aborting to prevent duplicate/conflicting rules"
            exit 1
        fi

        exit 1
    fi

    # Append block if entirely missing
    if ! grep -q "^\*nat" "${rules_file}"; then
        cat <<EOF >> "${rules_file}"

*nat
:PREROUTING ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
${exact_prerouting}
${exact_postrouting}

COMMIT
EOF
        print_status "New NAT added in before.rules for ${PROTOCOL}"
    else
        local post_rule=""
        if ! grep -qF -- "${exact_postrouting}" "${rules_file}"; then
            post_rule="${exact_postrouting}"
        fi

        local tmp_file
        tmp_file=$(mktemp)
        awk -v pre="${exact_prerouting}" -v post="${post_rule}" '
        /^\*nat/ { in_nat=1 }
        in_nat && /^[[:space:]]*$/ { empty_line=1; next }
        in_nat && empty_line && !/^COMMIT$/ { print ""; empty_line=0 }
        in_nat && /^COMMIT$/ {
            print pre
            if (post != "") print post
            print ""
            print "COMMIT"
            in_nat=0
            empty_line=0
            next
        }
        { print }
        ' "${rules_file}" > "$tmp_file"
        cat "$tmp_file" > "${rules_file}"
        rm -f "$tmp_file"

        print_status "Rules added to existing before.rules NAT for ${PROTOCOL}"
    fi
}

# Add UFW route allow rule
add_ufw_rule() {
    print_info "Adding UFW allow route rules..."

    if ufw route allow in on "${SRC_IFACE}" to "${DEST_IP}" port "${DEST_PORT}" proto "${PROTOCOL}" > /dev/null; then
        print_status "UFW allow route rules added for ${PROTOCOL}"
    else
        print_error "Failed to add UFW allow route rules"
    fi
}

# Remove specific rules safely
remove_rule_logic() {
    local rules_file="/etc/ufw/before.rules"
    local s_port="${SRC_PORT:-$DEST_PORT}"

    local exact_prerouting="-A PREROUTING -i ${SRC_IFACE} -p ${PROTOCOL} --dport ${s_port} -j DNAT --to-destination ${DEST_IP}:${DEST_PORT}"
    local exact_postrouting="-A POSTROUTING -p ${PROTOCOL} -d ${DEST_IP} --dport ${DEST_PORT} -j MASQUERADE"

    print_info "Removing configuration for ${PROTOCOL} ${SRC_IFACE}:${s_port} -> ${DEST_IP}:${DEST_PORT}..."

    # Literal deletion prevents messing up files with manual edits
    if grep -qF -- "${exact_prerouting}" "${rules_file}"; then
        delete_exact_line "${rules_file}" "${exact_prerouting}"
        print_status "Removed PREROUTING rules"
    else
        print_info "PREROUTING rules not found in before.rules, skipping"
    fi

    # DO NOT delete MASQUERADE rule if other forwards currently depend on it
    if grep -qE -- "-p ${PROTOCOL}.*-j DNAT --to-destination ${DEST_IP}:${DEST_PORT}[[:space:]]*$" "${rules_file}"; then
        print_info "POSTROUTING rules still in use by other routes, leaving it intact"
    else
        if grep -qF -- "${exact_postrouting}" "${rules_file}"; then
            delete_exact_line "${rules_file}" "${exact_postrouting}"
            print_status "Removed POSTROUTING rules"
        fi
    fi

    # Remove UFW route rule securely
    ufw route delete allow in on "${SRC_IFACE}" to "${DEST_IP}" port "${DEST_PORT}" proto "${PROTOCOL}" > /dev/null 2>&1 || true

    ufw reload > /dev/null || print_error "UFW reload failed (check /etc/ufw/before.rules)"
    print_status "Forward removed"
}

# === MAIN ===

SRC_IFACE=""
PROTOCOL=""
DEST_PORT=""
DEST_IP=""
SRC_PORT=""
REMOVE_MODE=0

while getopts "i:p:d:t:s:rh" opt; do
    case $opt in
        i) SRC_IFACE="$OPTARG" ;;
        p) PROTOCOL="$OPTARG" ;;
        d) DEST_PORT="$OPTARG" ;;
        t) DEST_IP="$OPTARG" ;;
        s) SRC_PORT="$OPTARG" ;;
        r) REMOVE_MODE=1 ;;
        h) show_help; exit 0 ;;
        \?) print_error "Unknown option"; echo ""; show_help; exit 1 ;;
    esac
done

validate_params
check_and_install_ufw

if [[ $REMOVE_MODE -eq 1 ]]; then
    remove_rule_logic
    exit 0
fi

echo ""
print_info "Forwarding with these params:"
echo "  Interface:      ${SRC_IFACE}"
echo "  Protocol:       ${PROTOCOL}"
echo "  Source Port:    ${SRC_PORT:-$DEST_PORT}"
echo "  Dest IP:        ${DEST_IP}"
echo "  Dest Port:      ${DEST_PORT}"
echo ""

enable_ip_forward
add_nat_rules
add_ufw_rule

ufw reload > /dev/null

echo ""
ufw status numbered | grep -E "(${DEST_IP}|${SRC_IFACE})" || echo "No active route rules found"
echo ""
print_status "Forward complete"
print_info "If needed, review and edit before.rules manually"
