#!/bin/bash

# Output colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

BASE_DIR="/opt/remnanode"
WEB_DIR="$BASE_DIR/webserver"
LOCKFILE="$BASE_DIR/.setup_complete"

if [ -f "$LOCKFILE" ]; then
    print_error "Setup has already been run on this machine"
    exit 1
fi

echo -ne "${YELLOW}[i]${NC} Have you exported a pubkey to this machine (pass auth will be turned off)? [y/n]: "
read CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    print_error "Setup aborted by user"
    exit 0
fi

echo -ne "${YELLOW}[i]${NC} Enter panel IP for UFW: "
read PANEL_IP
if [ -z "$PANEL_IP" ]; then
    print_error "Panel IP cannot be empty, exiting"
    exit 1
fi

echo -ne "${YELLOW}[i]${NC} Enter panel port for UFW (default 42069): "
read PANEL_PORT
if [ -z "$PANEL_PORT" ]; then
    PANEL_PORT=42069
fi

echo -ne "${YELLOW}[i]${NC} Enter SECRET_KEY: "
read SECRET_KEY
if [ -z "$SECRET_KEY" ]; then
    print_error "SECRET_KEY cannot be empty, exiting"
    exit 1
fi

print_info "Select webserver config:"
echo "  1) Caddy in front of Xray (recommended)"
echo "  2) Caddy behind Xray"
echo "  3) nginx in front of Xray (not yet implemented)"
echo -ne "${YELLOW}[i]${NC} Enter choice [1, 2 or 3]: "
read SERVER_CHOICE

if [[ "$SERVER_CHOICE" != "1" && "$SERVER_CHOICE" != "2" && "$SERVER_CHOICE" != "3" ]]; then
    print_error "Invalid choice, exiting"
    exit 1
fi

echo -ne "${YELLOW}[i]${NC} Enter main domain (e.g. main.example.com): "
read NODE_DOMAIN
if [ -z "$NODE_DOMAIN" ]; then
    print_error "Main domain cannot be empty"
    exit 1
fi

echo -ne "${YELLOW}[i]${NC} Enter first steal domain (e.g. steal1.example.com): "
read NODE_DOMAIN2
if [ -z "$NODE_DOMAIN2" ]; then
    print_error "First steal domain cannot be empty"
    exit 1
fi

if [[ "$SERVER_CHOICE" == "1" || "$SERVER_CHOICE" == "2" ]]; then
    TOTAL_RAM_MB=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo 2>/dev/null)
    if [ -z "$TOTAL_RAM_MB" ] || ! [[ "$TOTAL_RAM_MB" =~ ^[0-9]+$ ]]; then
        echo -ne "${YELLOW}[i]${NC} Could not calculate RAM, enter total RAM in MiB (e.g. 2048): "
        read TOTAL_RAM_MB
    fi
    print_info "Available RAM: ${TOTAL_RAM_MB}MiB"

    # CADDY_MEM is for GOMEMLIMIT (75% of CADDY_HARD_MEM), CADDY_HARD_MEM is for Docker memory limit
    if [ "$TOTAL_RAM_MB" -lt 1200 ]; then
        # 1GB
        CADDY_MEM=150
        CADDY_HARD_MEM=200
    elif [ "$TOTAL_RAM_MB" -lt 2300 ]; then
        # 2GB
        CADDY_MEM=525
        CADDY_HARD_MEM=700
    elif [ "$TOTAL_RAM_MB" -lt 4300 ]; then
        # 4GB
        CADDY_MEM=1125
        CADDY_HARD_MEM=1500
    elif [ "$TOTAL_RAM_MB" -lt 5700 ]; then
        # 6GB
        CADDY_MEM=1500
        CADDY_HARD_MEM=2000
    elif [ "$TOTAL_RAM_MB" -lt 7700 ]; then
        # 8GB
        CADDY_MEM=2250
        CADDY_HARD_MEM=3000
    else
        # 10GB+
        CADDY_MEM=3000
        CADDY_HARD_MEM=4000
    fi
fi

# ------------------------------------------------------------------------------
# 1. PACKAGES
# ------------------------------------------------------------------------------
print_info "[Task 1] Installing Docker and required packages..."
apt-get update && apt-get install -y ufw btop tmux curl git nano cron logrotate rsyslog sudo fail2ban nftables rsync

if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
else
    print_status "Docker is already installed, skipping"
fi

# ------------------------------------------------------------------------------
# 2. DIR STRUCTURE
# ------------------------------------------------------------------------------
print_info "[Task 2] Creating dirs..."
mkdir -p "$BASE_DIR"/warp
mkdir -p "$WEB_DIR"/{certs,website}

# --- .ENV ---
cat << EOF > "$BASE_DIR/.env"
NODE_PORT=$PANEL_PORT
XTLS_API_PORT=61000
SECRET_KEY=$SECRET_KEY

SNI_VERIFICATION=true
NFTABLES_LOGGING=true
NFTABLES_ACCEPT_REPLY_TRAFFIC=false
EOF

if [ "$SERVER_CHOICE" -eq "1" ]; then
    # Caddy in front of Xray
    print_info "Dropping configs..."

    curl -sSL "https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/remnawave/setup/node/caddy/docker-compose-front.yml" -o "$BASE_DIR/docker-compose.yml"
    curl -sSL "https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/remnawave/setup/node/caddy/Caddyfile-front" -o "$WEB_DIR/Caddyfile"

    sed -i "s|<NODE_DOMAIN>|$NODE_DOMAIN|g" "$WEB_DIR/Caddyfile"
    sed -i "s|<NODE_DOMAIN2>|$NODE_DOMAIN2|g" "$WEB_DIR/Caddyfile"

    # Update GOMEMLIMIT and hard docker ram limit
    sed -i "s|GOMEMLIMIT=[0-9]*MiB|GOMEMLIMIT=${CADDY_MEM}MiB|g" "$BASE_DIR/docker-compose.yml"
    sed -i "s|memory: [0-9]*M|memory: ${CADDY_HARD_MEM}M|g" "$BASE_DIR/docker-compose.yml"

elif [ "$SERVER_CHOICE" -eq "2" ]; then
    # Caddy behind Xray
    print_info "Dropping configs..."

    curl -sSL "https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/remnawave/setup/node/caddy/docker-compose-back.yml" -o "$BASE_DIR/docker-compose.yml"
    curl -sSL "https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/remnawave/setup/node/caddy/Caddyfile-back" -o "$WEB_DIR/Caddyfile"

    sed -i "s|<NODE_DOMAIN>|$NODE_DOMAIN|g" "$WEB_DIR/Caddyfile"
    sed -i "s|<NODE_DOMAIN2>|$NODE_DOMAIN2|g" "$WEB_DIR/Caddyfile"

    # Update GOMEMLIMIT and hard docker ram limit
    sed -i "s|GOMEMLIMIT=[0-9]*MiB|GOMEMLIMIT=${CADDY_MEM}MiB|g" "$BASE_DIR/docker-compose.yml"
    sed -i "s|memory: [0-9]*M|memory: ${CADDY_HARD_MEM}M|g" "$BASE_DIR/docker-compose.yml"

elif [ "$SERVER_CHOICE" -eq "3" ]; then
    # nginx in front of Xray
    print_error "Not yet implemented, exiting"
    exit 1
fi

# ------------------------------------------------------------------------------
# 3. SSH auth & UFW
# ------------------------------------------------------------------------------
print_info "[Task 3] Configuring SSH auth and UFW..."

# 1. Update main sshd_config
sed -i 's/^#*Port .*/Port 1337/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config

# 2. Update any include files in sshd_config.d
if [ -d "/etc/ssh/sshd_config.d" ]; then
    print_info "Updating override files in /etc/ssh/sshd_config.d/..."
    find /etc/ssh/sshd_config.d/ -type f -name "*.conf" -exec sed -i 's/^#*PasswordAuthentication .*/PasswordAuthentication no/' {} +
fi

# 3. Add panel pubkey
mkdir -p /root/.ssh
chmod 700 /root/.ssh
touch /root/.ssh/authorized_keys

if ! grep -q "remnawave-panel" /root/.ssh/authorized_keys; then
    # Ensure a trailing newline exists ONLY if the file doesn't already end with one
    if [ -s /root/.ssh/authorized_keys ] && [ "$(tail -c1 /root/.ssh/authorized_keys)" != $'\n' ]; then
        echo "" >> /root/.ssh/authorized_keys
    fi

cat << 'EOF' >> /root/.ssh/authorized_keys
# Remnawave Panel
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJm73lJR/5bNep7YyewrQz8mCmpJz3aiU5WUhd38HIZp remnawave-panel
EOF

cat -s /root/.ssh/authorized_keys > /tmp/auth_keys && mv /tmp/auth_keys /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
fi

systemctl restart sshd

ufw allow 1337 comment 'SSH (non-standard)'
ufw allow 80 comment 'HTTP'
ufw allow 443 comment 'HTTPS'
ufw allow from "$PANEL_IP" to any port "$PANEL_PORT" comment 'Remnawave Panel'
ufw --force enable

# 4. Configure fail2ban
print_info "Creating fail2ban jail.local config..."
cat << 'EOF' > /etc/fail2ban/jail.local
[DEFAULT]
backend = systemd

[sshd]
enabled = true
EOF

print_info "Restarting fail2ban and checking status..."
systemctl restart fail2ban
fail2ban-client status
fail2ban-client status sshd

# 5. Install and run traffic-guard
print_info "Installing traffic-guard..."
curl -fsSL https://raw.githubusercontent.com/Winterstarf/traffic-guard/refs/heads/master/install.sh | bash

print_info "Applying traffic-guard blocklists..."
traffic-guard full \
  -u https://raw.githubusercontent.com/Winterstarf/traffic-guard-lists/refs/heads/main/public/antiscanner.list \
  -u https://raw.githubusercontent.com/Winterstarf/traffic-guard-lists/refs/heads/main/public/government_networks.list \
  -u https://raw.githubusercontent.com/Winterstarf/traffic-guard-lists/refs/heads/main/public/skipa.list \
  -u https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level2.netset \
  -u https://lists.blocklist.de/lists/all.txt \
  --enable-logging

# ------------------------------------------------------------------------------
# 4. SYSCTL
# ------------------------------------------------------------------------------
print_info "[Task 4] Adding 99-custom-node.conf to sysctl..."
curl -sSL "https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/remnawave/sysctl/99-custom-node.conf" -o /etc/sysctl.d/99-custom-node.conf
sysctl --system

# ------------------------------------------------------------------------------
# 5. DOCKER AUTO-RESTART
# ------------------------------------------------------------------------------
print_info "[Task 5] Enabling Docker services for auto-reboot..."
systemctl enable docker docker.service containerd.service

# ------------------------------------------------------------------------------
# 6. DOCKER MTU ADJUSTMENT
# ------------------------------------------------------------------------------
print_info "[Task 6] Configuring Docker MTU..."

# daemon.json
mkdir -p /etc/docker
cat << 'EOF' > /etc/docker/daemon.json
{
  "mtu": 1400
}
EOF

systemctl daemon-reexec
systemctl restart docker

# ------------------------------------------------------------------------------
# 7. DUMMY SCRIPT
# ------------------------------------------------------------------------------
print_info "[Task 7] Setting up update_dummy.sh..."
git clone https://github.com/Winterstarf/dummy-site.git "$BASE_DIR/webserver/website"

cat << 'EOF' > "$BASE_DIR/webserver/update_dummy.sh"
#!/bin/bash

# Output colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

WEB_DIR="/opt/remnanode/webserver/website"
LOG_FILE="/var/log/dummy_updates.log"

if [ -d "$WEB_DIR" ]; then
    cd "$WEB_DIR" || exit
    print_info "[$(date)] Pulling updates for dummy..." >> "$LOG_FILE"

    git fetch --all >> "$LOG_FILE" 2>&1
    git reset --hard origin/master >> "$LOG_FILE" 2>&1
else
    print_error "[$(date)] $WEB_DIR not found" >> "$LOG_FILE"
fi
EOF
chmod +x "$BASE_DIR/webserver/update_dummy.sh"
touch /var/log/dummy_updates.log

print_info "Executing update_dummy.sh..."
bash "$BASE_DIR/webserver/update_dummy.sh"

# ------------------------------------------------------------------------------
# 8. CRON
# ------------------------------------------------------------------------------
print_info "[Task 8] Setting up cron..."
systemctl enable --now cron

# 24:00 every day for dummy, utc+3
CRON_FILE="/tmp/tmp_cronfile"
cat << 'EOF' > $CRON_FILE
CRON_TZ=Europe/Moscow
0 0 * * * /opt/remnanode/webserver/update_dummy.sh
EOF
crontab $CRON_FILE
rm $CRON_FILE

# ------------------------------------------------------------------------------
# 9. LOGROTATION
# ------------------------------------------------------------------------------
print_info "[Task 9] Setting up logrotation..."

# Remnanode logrotate
mkdir -p /var/log/remnanode
cat << 'EOF' > /etc/logrotate.d/remnanode
/var/log/remnanode/*.log {
      size 50M
      rotate 5
      compress
      missingok
      notifempty
      copytruncate
  }
EOF
touch /var/log/remnanode/error.log /var/log/remnanode/access.log
chmod 666 /var/log/remnanode/*.log

# Dummy logrotate
cat << 'EOF' > /etc/logrotate.d/dummy
/var/log/dummy_updates.log {
      monthly
      rotate 4
      compress
      missingok
      notifempty
      copytruncate
  }
EOF
touch /var/log/dummy_updates.log
chmod 666 /var/log/dummy_updates.log

# Force initial logrotate run
logrotate -vf /etc/logrotate.d/remnanode
logrotate -vf /etc/logrotate.d/dummy

# ------------------------------------------------------------------------------
# 10. QUIC MTU
# ------------------------------------------------------------------------------
print_info "[Task 10] Applying QUIC MTU fix..."

cat << 'EOF' > /etc/quic-mtuc.nft
add table ip QuicMtuClamp
flush table ip QuicMtuClamp

table ip QuicMtuClamp {
    chain output {
        type filter hook output priority raw; policy accept;

        # Invalidate checksum on oversized QUIC packets to force PMTUD step-down
        oifname != "lo" udp sport 443 meta length > 1478 ip frag-off & 0x4000 != 0 ip checksum set 0 notrack
    }
}
EOF

cat << 'EOF' > /etc/systemd/system/quic-mtuc.service
[Unit]
Description=QUIC MTU Clamp fix
After=network.target nftables.service

[Service]
Type=oneshot
ExecStart=/usr/sbin/nft -f /etc/quic-mtuc.nft
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now quic-mtuc.service

# ------------------------------------------------------------------------------
# 11. SWAP
# ------------------------------------------------------------------------------
print_info "[Task 11] Checking for swap..."

CREATE_SWAP=0

if ! swapon --show | grep -q "NAME"; then
    CREATE_SWAP=1
else
    read -p "Swap exists, overwrite it with a 2GB one? [y/n]: " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        CREATE_SWAP=1
        ACTIVE_SWAPS=$(swapon --show=NAME --noheadings)
        
        swapoff -a 2>/dev/null || true
        for dev in $ACTIVE_SWAPS; do
            if [ -f "$dev" ]; then
                rm -f "$dev"
            elif [ -b "$dev" ]; then
                # Clean header signature
                wipefs -a "$dev" 2>/dev/null || true
            fi
        done
        
        sed -i.bak '/\bswap\b/d' /etc/fstab
    else
        print_status "Swapfile creation cancelled, skipping"
    fi
fi

if [ "$CREATE_SWAP" -eq 1 ]; then
    # Create swapfile via fallocate, fallback to dd if filesystem rejects fallocate (e.g., btrfs/zfs)
    fallocate -l 2G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=2048 status=none
    chmod 600 /swapfile
    
    mkswap /swapfile >/dev/null 2>&1
    swapon /swapfile

    if ! grep -q "^/swapfile" /etc/fstab; then
        echo '/swapfile none swap sw 0 0' >> /etc/fstab
    fi
    print_status "Created a 2GB swapfile"
fi

touch "$LOCKFILE"
echo "(^人^)"
print_status "Setup complete"
print_info "Add node IP to sync_certs.sh on ${PANEL_IP} server, start the container stack, and connect the node on ${PANEL_PORT} port"
print_info "If needed, review and edit Caddyfile/nginx.conf manually"
