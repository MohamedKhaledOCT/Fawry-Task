# DNS Troubleshooting Guide

## Table of Contents
- [Trace the Issue - Possible Causes](#trace-the-issue---possible-causes)
  - [DNS-Related Issues](#dns-related-issues)
  - [Network/Service Layer Issues](#networkservice-layer-issues)
- [Proposed Fixes](#proposed-fixes)
  - [DNS Server Failure](#dns-server-failure)
  - [Missing/Incorrect DNS Records](#missingincorrect-dns-records)
  - [DNS Cache Issues](#dns-cache-issues)
  - [Network Routing Problems](#network-routing-problems)
  - [Firewall Blocking Issues](#firewall-blocking-issues)
  - [VPN/Network Segregation](#vpnnetwork-segregation)
- [Bonus: Local hosts entry and persistent DNS](#bonus-local-hosts-entry-and-persistent-dns)
  - [Add local hosts entry to bypass DNS](#add-local-hosts-entry-to-bypass-dns)
  - [Persistent DNS with NetworkManager](#persistent-dns-with-networkmanager)
  - [Persistent DNS with systemd-resolved](#persistent-dns-with-systemd-resolved)

## Trace the Issue - Possible Causes

Here's a comprehensive list of potential causes for the "host not found" errors:

### DNS-Related Issues:

1. **DNS server failure**: The DNS server specified in /etc/resolv.conf is down or unreachable
2. **Missing/incorrect DNS zone records**: The DNS record for internal.example.com doesn't exist or is incorrect
3. **DNS cache issues**: Stale DNS cache entries on local or intermediate DNS servers
4. **Split-horizon DNS misconfiguration**: Different DNS views might be misconfigured
5. **Local DNS resolution override**: /etc/hosts entries might be missing or incorrect
6. **DNS propagation delays**: Recent DNS changes haven't propagated fully

### Network/Service Layer Issues:

7. **Firewall blocking DNS queries**: Network firewalls blocking UDP/TCP port 53
8. **Routing problems**: Network routes to the DNS server or web server are broken
9. **VPN/network segregation**: Access might require specific network connectivity (VPN)
10. **Service downtime**: The web service itself might be down despite DNS working correctly
11. **Load balancer issues**: If behind a load balancer, it might be misconfigured
12. **Certificate issues**: For HTTPS, invalid certificates can cause connection problems
13. **Network interface configuration**: Wrong network interface might be used for routing

## Proposed Fixes

For each potential issue, here's how to confirm it's the root cause and fix it:

### DNS Server Failure

**Confirm:**
```bash
# Check if DNS servers are responding
ping $(grep nameserver /etc/resolv.conf | head -1 | awk '{print $2}')
```

**Fix:**
```bash
# Update DNS servers in resolv.conf (temporary)
sudo sh -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'

# For permanent fix with systemd-resolved
sudo systemctl edit systemd-resolved.service
# Add DNS= line to the [Resolve] section:
# [Resolve]
# DNS=8.8.8.8 1.1.1.1
sudo systemctl restart systemd-resolved.service
```

### Missing/Incorrect DNS Records

**Confirm:**
```bash
# Check if the record exists in the DNS zone
dig internal.example.com @[your_dns_server] +noall +answer
```

**Fix:** (on the DNS server)
```bash
# Edit zone file to add or correct the record
sudo vi /etc/bind/zones/db.example.com
# Add: internal IN A 192.168.1.100

# Reload DNS configuration
sudo systemctl reload bind9
# or on RHEL/CentOS:
sudo systemctl reload named
```

### DNS Cache Issues

**Confirm:**
```bash
# Check if cached results differ from authoritative results
dig internal.example.com
dig internal.example.com +trace
```

**Fix:**
```bash
# Flush DNS cache on the local machine
# For systemd-resolved:
sudo systemd-resolve --flush-caches
# For nscd:
sudo systemctl restart nscd
# For dnsmasq:
sudo systemctl restart dnsmasq
```

### Network Routing Problems

**Confirm:**
```bash
# Check the route to the server
traceroute internal.example.com

# Check routing table
ip route show
```

**Fix:**
```bash
# Add a static route if needed
sudo ip route add [server_network] via [gateway_ip]

# Make it permanent in /etc/network/interfaces or appropriate config
sudo vi /etc/network/interfaces
# Add: post-up ip route add [server_network] via [gateway_ip]
```

### Firewall Blocking Issues

**Confirm:**
```bash
# Check if firewall is blocking traffic
sudo iptables -L -n

# Try telnet to the specific ports
telnet internal.example.com 80
telnet internal.example.com 443
```

**Fix:**
```bash
# Allow traffic to web ports
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Make it persistent
sudo iptables-save > /etc/iptables/rules.v4
```

### VPN/Network Segregation

**Confirm:**
```bash
# Check network interfaces and connectivity
ip a
ping [gateway_ip]
```

**Fix:**
```bash
# Connect to VPN if needed
sudo openvpn --config /path/to/config.ovpn

# Or configure network settings as required
sudo nmcli con up VPN_Connection
```

## Bonus: Local hosts entry and persistent DNS

### Add local hosts entry to bypass DNS:

```bash
# Add entry to /etc/hosts
echo "192.168.1.100 internal.example.com" | sudo tee -a /etc/hosts

# Test that it works
ping internal.example.com
```

### Persistent DNS with NetworkManager:

```bash
# Create a DNS configuration
sudo vi /etc/NetworkManager/conf.d/dns-servers.conf
# Add:
# [global-dns-domain-*]
# servers=8.8.8.8,1.1.1.1

# Restart NetworkManager
sudo systemctl restart NetworkManager
```

### Persistent DNS with systemd-resolved:

```bash
# Edit the systemd-resolved configuration
sudo vi /etc/systemd/resolved.conf
# Uncomment and modify:
# DNS=8.8.8.8 1.1.1.1
# FallbackDNS=9.9.9.9 149.112.112.112

# Restart systemd-resolved
sudo systemctl restart systemd-resolve
