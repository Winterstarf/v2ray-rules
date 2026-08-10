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

SSH_PORT=1337
TIMEOUT=3
LOCAL_CERT="/opt/remnawave/webserver/wildcard/fullchain.pem"
LOCAL_KEY="/opt/remnawave/webserver/wildcard/privkey.key"

NODES=("<node_ip_1>" "<node_ip_2>" "<node_ip_3>")
SUBSERVER="<subserver_ip>"

NODE_DIR="/opt/remnanode/webserver/certs"
SUBSERVER_DIR="/opt/remnawave/webserver/certs"

# Reload commands
CADDY_RELOAD="docker exec remnawave-caddy caddy reload --config /etc/caddy/Caddyfile"
NGINX_RELOAD="docker exec remnawave-nginx nginx -s reload"

SSH_OPTS="-p $SSH_PORT -o StrictHostKeyChecking=accept-new -o BatchMode=yes"

clear_old_host_key() {
    local IP="$1"
    ssh-keygen -R "[$IP]:$SSH_PORT" >/dev/null 2>&1
}

check_ssh() {
    local IP="$1"

    if ssh -q $SSH_OPTS -o ConnectTimeout=$TIMEOUT "root@$IP" "true" 2>/dev/null; then
        return 0
    fi

    clear_old_host_key "$IP"
    ssh -q $SSH_OPTS -o ConnectTimeout=$TIMEOUT "root@$IP" "true" 2>/dev/null
}

sync_node() {
    local IP="$1"
    local CERT_DIR="$2"
    local RELOAD_CMD="$3"

    print_info "Checking reachability for $IP..."

    if ! check_ssh "$IP"; then
        print_error "Node $IP is unreachable or SSH auth failed (timeout: ${TIMEOUT}s), skipping"
        return 1
    fi

    print_info "Pushing new certs to $IP ($CERT_DIR)..."

    if rsync -avz -e "ssh $SSH_OPTS" "$LOCAL_CERT" "$LOCAL_KEY" "root@$IP:$CERT_DIR/"; then
        if ssh $SSH_OPTS "root@$IP" "$RELOAD_CMD"; then
            print_status "Done updating $IP"
        else
            print_error "Failed to reload webserver on $IP"
        fi
    else
        print_error "Failed to rsync certs to $IP"
    fi
}

if [ -n "$1" ]; then
    TARGET="$1"
    print_info "Single target mode: $TARGET"

    if [ -n "$SUBSERVER" ] && [ "$TARGET" == "$SUBSERVER" ]; then
        sync_node "$TARGET" "$SUBSERVER_DIR" "$NGINX_RELOAD"
        exit 0
    fi

    for IP in "${NODES[@]}"; do
        if [ "$IP" == "$TARGET" ]; then
            sync_node "$TARGET" "$NODE_DIR" "$CADDY_RELOAD"
            exit 0
        fi
    done

    print_error "Target IP $TARGET not found in node list"
    exit 1
fi

print_info "Updating all nodes..."

for IP in "${NODES[@]}"; do
    [ -n "$IP" ] && sync_node "$IP" "$NODE_DIR" "$CADDY_RELOAD"
done

if [ -n "$SUBSERVER" ]; then
    sync_node "$SUBSERVER" "$SUBSERVER_DIR" "$NGINX_RELOAD"
fi
