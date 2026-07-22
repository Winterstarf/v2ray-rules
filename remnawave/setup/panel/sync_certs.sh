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

NODES=("1.1.1.1" "2.2.2.2" "3.3.3.3")
SSH_PORT=1337

CERT_DIR="/opt/remnanode/webserver/certs"

LOCAL_CERT="/opt/remnawave/wildcard/fullchain.pem"
LOCAL_KEY="/opt/remnawave/wildcard/privkey.key"

if [ -n "$1" ]; then
    TARGET_NODES=("$1")
    print_info "Single target: $1"
else
    TARGET_NODES=("${NODES[@]}")
    print_info "Updating all nodes"
fi

for IP in "${TARGET_NODES[@]}"; do
    print_info "Pushing new certs to $IP..."

    rsync -avz -e "ssh -p $SSH_PORT -o StrictHostKeyChecking=accept-new" "$LOCAL_CERT" "$LOCAL_KEY" root@$IP:$CERT_DIR/
    ssh -p $SSH_PORT -o StrictHostKeyChecking=accept-new root@$IP "docker exec remnawave-caddy caddy reload --config /etc/caddy/Caddyfile"

    print_status "Done updating $IP"
done
