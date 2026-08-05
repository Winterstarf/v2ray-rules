[remnawave-panel]

1:
apt install -y ufw btop tmux curl git nano cron logrotate rsyslog fail2ban

2:
curl -fsSL https://get.docker.com | sh

3:
mkdir -p /opt/remnawave/webserver/certs
struct:
/opt/remnawave/docker-compose.yml
/opt/remnawave/webserver/nginx.conf
/opt/remnawave/webserver/get_certs.sh

4:
create a new pubkey or use an existing one from setup/node/setup.sh
use get_certs.sh to either issue a new wildcard cert or use an existing one
add sync_certs.sh to bash source, and push wildcard cert to nodes

5:
sed -i -e 's/^#\?Port .*/Port 1337/' -e 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config && systemctl restart ssh
find /etc/ssh/sshd_config.d/ -type f -name "*.conf" -exec sed -i -e 's/^#\?Port .*/Port 1337/' -e 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' {} +
ufw allow 1337 comment 'SSH (non-standard)' && ufw allow 80 comment 'HTTP' && ufw allow 443 comment 'HTTPS' && ufw enable && ufw reload

6:
>> nano /etc/sysctl.d/99-custom.conf
99-custom.conf
>>
sysctl --system

7:
systemctl enable docker docker.service containerd.service

8:
>> nano /etc/fail2ban/jail.local
[DEFAULT]
backend = systemd

[sshd]
enabled = true
>>
systemctl restart fail2ban
fail2ban-client status
fail2ban-client status sshd

9:
curl -fsSL https://raw.githubusercontent.com/Winterstarf/traffic-guard/refs/heads/master/install.sh | bash
traffic-guard full \
  -u https://raw.githubusercontent.com/Winterstarf/traffic-guard-lists/refs/heads/main/public/antiscanner.list \
  -u https://raw.githubusercontent.com/Winterstarf/traffic-guard-lists/refs/heads/main/public/government_networks.list \
  -u https://raw.githubusercontent.com/Winterstarf/traffic-guard-lists/refs/heads/main/public/skipa.list \
  -u https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level2.netset \
  -u https://lists.blocklist.de/lists/all.txt \
  --enable-logging
