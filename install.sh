#!/usr/bin/sh

echo "Preparing needed directories"
mkdir -w /etc/kvmd/user/scripts
mkdir -w /etc/kvmd/user/wireguard
chmod 660 -R /etc/kvmd/user/wireguard

echo "Adding wg-quick"
wget -O /etc/kvmd/user/scripts/wg-quick https://raw.githubusercontent.com/WireGuard/wireguard-tools/refs/heads/master/src/wg-quick/linux.bash
chmod +x wg-quick

echo "adding S99wireguard init script"
wget -O /etc/kvmd/user/scripts/S99wireguard https://github.com/fragtastic/gl-rm1_wireguard/raw/refs/heads/master/S99wireguard
chmod +x /etc/kvmd/user/scripts/S99wireguard

echo "Create wgX.conf files under /etc/kvmd/user/wireguard"
echo "Please remember to set permissions when adding new configs with: chmod 660 -R /etc/kvmd/user/wireguard"
