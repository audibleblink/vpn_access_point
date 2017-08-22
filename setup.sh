#!/usr/bin/env bash

# SETTINGS

## Typical Settings
pi_lan=192.168.42.1
pi_network=192.168.42.0
ap_ssid=my_vpn_ap
ap_password=dontspyonme
ovpn_user=xxxx
ovpn_pass=yyyy
ovpn_file="US East"

## Advanced Settings
pi_interface=wlan0
pi_dhcp_range_min=192.168.42.2
pi_dhcp_range_max=192.168.42.20
pi_netmask=255.255.255.0
pi_cidr=24
ap_channel=11

########################################
# SHOULDN'T NEED TO CHANGE BEYOND HERE
########################################

# Install necessary depenencies
#
apt update && apt install -y hostapd dnsmasq openvpn iptables-persistent

# Fetch the OVPN files
#
wget -O /root/vpn.zip https://www.privateinternetaccess.com/openvpn/openvpn.zip
unzip /root/vpn.zip -d /root/

# Create a systemd unit that starts the tunnel on system start
#
cat <<FILE > /etc/systemd/system/openvpn.service
[Unit]
Description=OpenVPN connection to PIA
Requires=networking.service
After=networking.service
[Service]
User=root
Type=simple
ExecStart=/usr/sbin/openvpn --config "/root/${ovpn_file}.ovpn" --auth-user-pass /root/up.txt
WorkingDirectory=/root
[Install]
WantedBy=multi-user.target
FILE

# Create the auth file for autostarting the VPM tunnel
#
cat <<FILE > /root/up.txt
${ovpn_user}
${ovpn_pass}
FILE
chmod 600 /root/up.txt

# Recognize the changes by reloading the daemon and enable the unit
#
systemctl daemon-reload
systemctl enable openvpn.service

# Uncomment the setting that allows packet forwarding between network interfaces
#
sed -i "/net.ipv4.ip_forward=1/ s/#*//" /etc/sysctl.conf

# Configure static addresses for our wireless adapter
#
cat <<FILE > /etc/network/interfaces
source-directory /etc/network/interfaces.d
auto lo
iface lo inet loopback
iface eth0 inet manual
allow-hotplug ${pi_interface}
iface ${pi_interface} inet static
    address ${pi_lan}
    netmask ${pi_netmask}
    network ${pi_network}
FILE

# Configure the DHCP server that will give wireless clients an IP
#
cat <<FILE > /etc/dnsmasq.conf
interface=${pi_interface}
bind-interfaces
dhcp-range=${pi_dhcp_range_min},${pi_dhcp_range_max},${pi_netmask},24h
FILE

# Exclude the wireless adapter from any dhcp operations performed by the OS
# Only add if we haven't done it yet
#
grep "denyinterfaces" /etc/dhcpcd.conf || \
  echo "denyinterfaces ${pi_interface}" >> /etc/dhcpcd.conf

# Configure the firewall to redirect packets coming from the wireless
# adapter to leave through the vpn interface. Deny all but established
# connections coming from the tun0 interface. Persist the rules.
#
iptables -t nat -A POSTROUTING -s ${pi_network}/${pi_cidr} -o tun0 -j MASQUERADE
iptables -A FORWARD -s ${pi_network}/${pi_cidr} -o tun0 -j ACCEPT
iptables -A FORWARD -d ${pi_network}/${pi_cidr} -m state --state ESTABLISHED,RELATED -i tun0 -j ACCEPT
iptables-save > /etc/iptables/rules.v4

# Configure the access point
#
cat <<FILE > /etc/hostapd/hostapd.conf
interface=${pi_interface}
driver=nl80211
ssid=${ap_ssid}
hw_mode=g
channel=${ap_channel}
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=${ap_password}
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
FILE

# Point the hostapd daemon to the configuration file
#
grep "/etc/hostapd/hostapd.conf" || cat <<FILE >> /etc/default/hostapd
DAEMON_CONF="/etc/hostapd/hostapd.conf"
FILE

# Cleanup function that runs when script exits, regardless of exit code
function finish {
  rm /root/vpn.zip
}
trap 'finish' EXIT
