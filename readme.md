# Wireguard on GL.iNet Comet

This depends on at least firmware version **_1.4.0 beta2_**. I haven't used beta1, maybe it works.

```log
Dec 31 14:00:12 glkvm daemon.debug wg-quick: Waiting for network (default route)...
Dec 31 14:00:14 glkvm daemon.debug wg-quick: Network ready after 2s.
Dec 31 14:00:14 glkvm daemon.debug wg-quick: [+] Starting WireGuard config: /etc/kvmd/user/wireguard/wg0.conf
Dec 31 14:00:14 glkvm daemon.debug wg-quick: [#] ip link add dev wg0 type wireguard
Dec 31 14:00:14 glkvm daemon.debug wg-quick: [#] wg addconf wg0 /dev/fd/63
Dec 31 14:00:14 glkvm daemon.debug wg-quick: [#] ip -4 address add 10.0.0.51/24 dev wg0
Dec 31 14:00:15 glkvm daemon.debug wg-quick: [#] ip link set mtu 1420 up dev wg0
```

## Prepare needed directories
```bash
mkdir -w /etc/kvmd/user/scripts
mkdir -w /etc/kvmd/user/wireguard
chmod 660 -R /etc/kvmd/user/wireguard
```

## Get wg-quick
```bash
wget -O /etc/kvmd/user/scripts/wg-quick https://raw.githubusercontent.com/WireGuard/wireguard-tools/refs/heads/master/src/wg-quick/linux.bash
chmod +x wg-quick
```

## Create init script

Add `S99wireguard` script to `/etc/kvmd/user/scripts` and mark executable. It just pulls the file from this gist.

```bash
wget -O /etc/kvmd/user/scripts/S99wireguard https://github.com/fragtastic/gl-rm1_wireguard/raw/refs/heads/master/S99wireguard
chmod +x /etc/kvmd/user/scripts/S99wireguard
```

## Create WG config(s)

Run `chmod 660 -R /etc/kvmd/user/wireguard` to set folder and all configs to the right permission.

```config
[Interface]
PrivateKey = <your-private-key>
Address = 10.0.0.2/24
ListenPort = 51820

[Peer]
PublicKey = <peer-public-key>
Endpoint = 1.2.3.4:51820
AllowedIPs = 10.0.0.0/24
PersistentKeepalive = 25
```

### Note
It will NOT work if `AllowedIPs = 0.0.0.0/0` is used.
There is something wrong with how it interacts with iptables and I don't care enough to actually do full tunnel traffic over wireguard.

Expected output:
```
# /etc/kvmd/user/scripts/wg-quick up /etc/kvmd/user/wireguard/wg0.conf 
[#] ip link add dev wg0 type wireguard
[#] wg addconf wg0 /dev/fd/63
[#] ip -4 address add 10.0.0.51/24 dev wg0
[#] ip link set mtu 1420 up dev wg0
```

Failed output:
```
# /etc/kvmd/user/scripts/wg-quick up /etc/kvmd/user/wireguard/wg0.conf 
[#] ip link add dev wg0 type wireguard
[#] wg addconf wg0 /dev/fd/63
[#] ip -4 address add 10.0.0.51/24 dev wg0
[#] ip link set mtu 1420 up dev wg0
[#] wg set wg0 fwmark 51820
[#] ip -4 rule add not fwmark 51820 table 51820
[#] ip -4 rule add table main suppress_prefixlength 0
[#] ip -4 route add 0.0.0.0/0 dev wg0 table 51820
[#] sysctl -q net.ipv4.conf.all.src_valid_mark=1
[#] iptables-restore -n
iptables-restore: line 3 failed
[#] ip -4 rule delete table 51820
[#] ip -4 rule delete table main suppress_prefixlength 0
[#] ip link delete dev wg0
```
