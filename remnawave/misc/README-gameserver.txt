[gameserver]

1:
apt install -y ufw btop tmux curl git nano cron logrotate rsyslog sudo fail2ban

2:
sed -i -e 's/^#\?Port .*/Port 1337/' -e 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config && systemctl restart ssh
find /etc/ssh/sshd_config.d/ -type f -name "*.conf" -exec sed -i -e 's/^#\?Port .*/Port 1337/' -e 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' {} +
ufw allow 1337 comment 'SSH (non-standard)' && ufw allow 80 comment 'HTTP' && ufw allow 443 comment 'HTTPS' && ufw allow <needed_port> comment '<game>' && ufw enable && ufw reload

3:
>> nano /etc/sysctl.d/99-custom-gameserver.conf
99-custom-gameserver.conf
>>
sysctl --system

4:
fallocate -l 2G /swapfile
[dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress] - if previous fails

chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile

grep "/swapfile" /etc/fstab
[echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab] - if previous returns nothing

free -h
swapon --show

5:
>> nano /etc/fail2ban/jail.local
[DEFAULT]
backend = systemd

[sshd]
enabled = true
>>
systemctl restart fail2ban
fail2ban-client status
fail2ban-client status sshd

6:
curl -fsSL https://raw.githubusercontent.com/Winterstarf/traffic-guard/refs/heads/master/install.sh | bash
traffic-guard full \
  -u https://raw.githubusercontent.com/Winterstarf/traffic-guard-lists/refs/heads/main/public/antiscanner.list \
  -u https://raw.githubusercontent.com/Winterstarf/traffic-guard-lists/refs/heads/main/public/government_networks.list \
  -u https://raw.githubusercontent.com/Winterstarf/traffic-guard-lists/refs/heads/main/public/skipa.list \
  -u https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level2.netset \
  -u https://lists.blocklist.de/lists/all.txt \
  --enable-logging
