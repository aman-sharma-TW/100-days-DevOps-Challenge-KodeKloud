#!/bin/bash

# ==============================
# Secure App Host - CentOS Firewall Setup Script
# ==============================

# Prompt for LBR IP
read -p "Enter the IP address of the LBR host: " LBR_IP

# Validate IP format
if [[ ! $LBR_IP =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
  echo "Invalid IP address format. Exiting."
  exit 1
fi

echo "[+] Using LBR IP: $LBR_IP"

# Install iptables and dependencies
echo "[+] Installing iptables..."
yum install -y iptables iptables-services

# Enable and start iptables service
systemctl enable iptables
systemctl start iptables

# Flush existing rules
echo "[+] Flushing existing iptables rules..."
iptables -F

# Allow port 5000 from LBR only
echo "[+] Allowing port 5000 from $LBR_IP..."
iptables -A INPUT -p tcp --dport 5000 -s "$LBR_IP" -j ACCEPT

# Block all other access to port 5000
echo "[+] Blocking port 5000 from all other sources..."
iptables -A INPUT -p tcp --dport 5000 -j DROP

# (Optional) Allow established/related connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Save rules to persist after reboot
echo "[+] Saving iptables rules..."
service iptables save

echo "[✔] Firewall configuration complete and persistent after reboot."
