#!/bin/bash
#
# This software is provided under under the BSD 3-Clause License.
# See the accompanying LICENSE file for more information.
#
# Configure Kali for stealhy use in Red Team Operations recording all actions performed
#
# Author:
#  Arris Huijgen
#
# Website:
#  https://github.com/bitsadmin/linuxconfig
#

# Install asciinema
apt -y install python3-pip
pip3 install asciinema
mkdir ~/Logging/
cat <<EOT >> ~/.zshrc
if [[ -z $ASCIINEMA_REC ]] && ! [ -e "/tmp/no_asciinema" ]; then
    mkdir -p $HOME/Logging/$(date +"%Y%m%d")/Terminal/
    export ASCIINEMA_REC=1
    asciinema rec $HOME/Logging/$(date +"%Y%m%d")/Terminal/$(date +"%Y%m%d_%H%M%S")_shell.json
    exit
fi
EOT

# Disable IPv6
cat << EOT >> /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOT
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.lo.disable_ipv6=1

# Disable ICMP reply
echo "net.ipv4.icmp_echo_ignore_all = 1" >> /etc/sysctl.conf
sysctl net.ipv4.icmp_echo_ignore_all=1

# Disable Network Manager
systemctl stop NetworkManager
systemctl disable NetworkManager

# Install DNSMasq
apt -y install dnsmasq
# Disable DHCP&TFTP
sed -i 's/#no-dhcp-interface=/no-dhcp-interface=/g' /etc/dnsmasq.conf
sed -i 's/#listen-address=/listen-address=127.0.0.1/g' /etc/dnsmasq.conf
cat << EOT >> /etc/dnsmasq.conf
server=192.168.25.2
server=/mydomain.local/1.2.3.4
server=/2.1.in-addr.arpa/1.2.3.4
EOT
systemctl enable dnsmasq
systemctl restart dnsmasq

# Prevent dhclient from updating /etc/resolv.conf
pkill dhclient
cat << EOT >> /etc/dhcp/dhclient-enter-hooks.d/nodnsupdate
#!/bin/sh
make_resolv_conf(){
    :
}
EOT
chmod +x /etc/dhcp/dhclient-enter-hooks.d/nodnsupdate

# Update /etc/resolv.conf
echo "nameserver 127.0.0.1" > /etc/resolv.conf

# Block Burp updater/telemetry
iptables -A OUTPUT -d 54.246.133.196 -j REJECT
iptables -A OUTPUT -p udp --dport 53 -m string --string "portswigger" --algo bm -j DROP
iptables -A OUTPUT -p tcp --dport 53 -m string --string "portswigger" --algo bm -j DROP
echo "::1 portswigger.net" >> /etc/hosts
echo "127.0.0.1 portswigger.net" >> /etc/hosts

# Silence Firefox
cat << EOT >> /etc/hosts
127.0.0.1 detectportal.firefox.com
127.0.0.1 self-repair.mozilla.org
127.0.0.1 blocklist.addons.mozilla.org
127.0.0.1 firefox.settings.services.mozilla.com
127.0.0.1 content-signature.cdn.mozilla.net
127.0.0.1 safebrowsing.google.com
127.0.0.1 safebrowsing-cache.google.com
127.0.0.1 support.mozilla.org
EOT

# NTP
systemctl disable ntp
systemctl stop ntp
systemctl disable systemd-timesyncd
systemctl stop systemd-timesyncd
timedatectl set-ntp 0

# SSH
systemctl -q disable ssh
systemctl -q stop ssh
