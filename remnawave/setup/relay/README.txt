[remnawave-relay]

1:
apt install -y ufw btop tmux curl git nano cron logrotate rsyslog sudo fail2ban

2:
sed -i -e 's/^#\?Port .*/Port 1337/' -e 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config && systemctl restart ssh
find /etc/ssh/sshd_config.d/ -type f -name "*.conf" -exec sed -i -e 's/^#\?Port .*/Port 1337/' -e 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' {} +
ufw allow 1337 comment 'SSH (non-standard)' && ufw allow 80 comment 'HTTP' && ufw allow 443 comment 'HTTPS' && ufw enable && ufw reload

3:
>> nano /etc/sysctl.d/99-custom-node.conf
99-custom-node.conf
>>
sysctl --system

4:
>> nano /etc/quic-mtuc.nft
add table ip QuicMtuClamp
flush table ip QuicMtuClamp

table ip QuicMtuClamp {
    chain output {
        type filter hook output priority raw; policy accept;

        # Invalidate checksum on oversized QUIC packets to force PMTUD step-down
        oifname != "lo" udp sport 443 meta length > 1478 ip frag-off & 0x4000 != 0 ip checksum set 0 notrack
    }
}
>>

>> nano /etc/systemd/system/quic-mtuc.service
[Unit]
Description=QUIC MTU Clamp fix
After=network.target nftables.service

[Service]
Type=oneshot
ExecStart=/usr/sbin/nft -f /etc/quic-mtuc.nft
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
>>
systemctl daemon-reload
systemctl enable --now quic-mtuc.service

5:
fallocate -l 2G /swapfile
[dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress] - if previous fails

chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile

grep "/swapfile" /etc/fstab
[echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab] - if previous returns nothing

free -h
swapon --show

6:
use forward.sh to forward 80/tcp, 443/tcp, 443/udp, and then porthop ranges with -hysteria flag
point this server ip to subdomain(s) of dest server if using selfsteal inbounds

7:
>> nano /etc/fail2ban/jail.local
[DEFAULT]
backend = systemd

[sshd]
enabled = true
>>
systemctl restart fail2ban
fail2ban-client status
fail2ban-client status sshd

8:
curl -fsSL https://raw.githubusercontent.com/Winterstarf/traffic-guard/refs/heads/master/install.sh | bash
traffic-guard full \
  -u https://raw.githubusercontent.com/Winterstarf/traffic-guard-lists/refs/heads/main/public/antiscanner.list \
  -u https://raw.githubusercontent.com/Winterstarf/traffic-guard-lists/refs/heads/main/public/government_networks.list \
  -u https://raw.githubusercontent.com/Winterstarf/traffic-guard-lists/refs/heads/main/public/skipa.list \
  -u https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level2.netset \
  -u https://lists.blocklist.de/lists/all.txt \
  --enable-logging
