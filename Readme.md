# Fawry Tasks - Solutions

This README documents the solutions for two Fawry tasks: creating a custom grep-like command and troubleshooting DNS connectivity issues.

## Table of Contents
- [Task 1: Custom Command (mygrep.sh)](#task-1-custom-command-mygrepsh)
  - [Implementation](#implementation)
  - [Testing](#testing)
  - [Reflective Analysis](#reflective-analysis)
  - [Script Breakdown](#script-breakdown)
- [Task 2: DNS Troubleshooting](#task-2-dns-troubleshooting)
  - [Verification Steps](#verification-steps)
  - [Potential Causes](#potential-causes)
  - [Solutions](#solutions)
  - [Bonus Configuration](#bonus-configuration)

## Task 1: Custom Command (mygrep.sh)

### Implementation

Here's the implementation of the custom `mygrep.sh` script:

```bash
#!/bin/bash

# mygrep.sh - A simplified version of grep command

# Function to display usage information
function show_usage {
    echo "Usage: $0 [OPTIONS] PATTERN FILE"
    echo "Search for PATTERN in FILE."
    echo ""
    echo "Options:"
    echo "  -n         Show line numbers for each match"
    echo "  -v         Invert the match (print lines that do not match)"
    echo "  --help     Display this help message and exit"
    exit 1
}

# Initialize variables
show_line_numbers=false
invert_match=false

# Parse options
while [[ "$1" == -* ]]; do
    case "$1" in
        -n)
            show_line_numbers=true
            ;;
        -v)
            invert_match=true
            ;;
        -vn|-nv)
            show_line_numbers=true
            invert_match=true
            ;;
        --help)
            show_usage
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            ;;
    esac
    shift
done

# Check if we have enough arguments
if [ $# -lt 2 ]; then
    echo "Error: Missing required arguments."
    show_usage
fi

pattern="$1"
file="$2"

# Check if file exists
if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found."
    exit 1
fi

# Perform the search
line_number=0
while IFS= read -r line; do
    line_number=$((line_number + 1))
    
    # Case-insensitive match using grep (to avoid complex bash pattern matching)
    if echo "$line" | grep -qi "$pattern"; then
        match_found=true
    else
        match_found=false
    fi
    
    # Determine whether to print the line based on match and invert settings
    if { $match_found && ! $invert_match; } || { ! $match_found && $invert_match; }; then
        if $show_line_numbers; then
            echo "$line_number:$line"
        else
            echo "$line"
        fi
    fi
done < "$file"
```

Make the script executable:
```bash
chmod +x mygrep.sh
```

### Testing

Create a test file called `testfile.txt` with the following content:

```
Hello world
This is a test
another test line
HELLO AGAIN
Don't match this line
Testing one two three
```

Execute the script with various options:

```bash
./mygrep.sh hello testfile.txt
./mygrep.sh -n hello testfile.txt
./mygrep.sh -vn hello testfile.txt
./mygrep.sh -v testfile.txt
```

![Script Output]
![Result](https://github.com/user-attachments/assets/a3c7de6a-2156-4a2d-b51f-cc0b361a5474)


### Reflective Analysis

#### Arguments and Options Handling

The script handles arguments and options as follows:

1. **Option Processing**:
   - The script uses a while loop that processes arguments starting with a dash (`-`).
   - Within the loop, it sets boolean flags based on the options provided.
   - It supports both individual options (-n, -v) and combined options (-vn, -nv).
   - After each option is processed, it shifts the arguments to move to the next one.

2. **Input Validation**:
   - After options are processed, the script checks if there are at least two arguments left (pattern and filename).
   - It verifies that the file exists before attempting to read from it.
   - It provides informative error messages when inputs are invalid.

3. **Pattern Matching**:
   - The script reads the file line by line.
   - For each line, it uses `grep -qi` for case-insensitive matching.
   - Based on the matching result and the invert flag, it decides whether to output the line.
   - If the line number flag is set, it prefixes the output with the line number.

#### Supporting Additional Options

To support regex or additional options like `-i`, `-c`, or `-l`:

1. **For regex support**:
   - I would add a flag to determine whether the pattern should be treated as a regex or a fixed string.
   - The matching mechanism would switch between `grep -q` (fixed string) and `grep -qE` (regex).

2. **For `-i` (case-insensitive)**:
   - I would add a new boolean flag and modify the matching logic to control case sensitivity.
   - For fixed strings, this would change between `grep -q` and `grep -qi`.
   - For regex patterns, it would change between `grep -qE` and `grep -qiE`.

3. **For `-c` (count)**:
   - Instead of outputting lines, I would keep a counter of matched lines.
   - At the end of processing, I would output only the count.

4. **For `-l` (files with matches)**:
   - I would modify the script to accept multiple file arguments.
   - Upon finding the first match in a file, output the filename and move to the next file.

These changes would require restructuring the main processing loop to separate the matching logic from the output logic, making it more modular.

#### Implementation Challenges

The most challenging part of the script was handling the combined options like `-vn` or `-nv`. This required careful consideration of how to:

1. Parse these combined options correctly
2. Set the appropriate flags
3. Ensure that options work the same regardless of the order

Another tricky aspect was the inverted matching logic. The script needs to correctly determine when to print a line based on both the match result and the invert flag. This required a careful logical expression that handles all four possible combinations.

### Script Breakdown

1. **Initialization**:
   - The script begins by defining a `show_usage` function and initializing boolean flags for line numbers and inverted matching.

2. **Option Parsing**:
   - A while loop processes options until it encounters an argument not starting with a dash.
   - The case statement handles different options and sets flags accordingly.
   - Combined options like `-vn` are explicitly handled.

3. **Argument Validation**:
   - The script checks if enough arguments remain after option processing.
   - It validates that the specified file exists.

4. **Main Processing**:
   - The script reads the file line by line using a while loop.
   - For each line, it uses `grep -qi` to perform a case-insensitive match.
   - Based on the match result and flags, it decides whether to print the line.
   - If line numbers are requested, it prefixes the output with the line number.

## Task 2: DNS Troubleshooting

### Verification Steps

#### 1. Verify DNS Resolution

Compare resolution between local DNS and Google's public DNS:

```bash
# Check current DNS configuration
cat /etc/resolv.conf

# Try resolving using system's configured DNS
nslookup internal.example.com

# Try resolving using Google's DNS
nslookup internal.example.com 8.8.8.8

# More detailed resolution checks
dig internal.example.com
dig internal.example.com @8.8.8.8
```

![DNS Resolution Check]
![DNS_Commpare](https://github.com/user-attachments/assets/e53932c0-b621-4b30-92e5-675ee3b5b6b1)


#### 2. Diagnose Service Reachability

Check if the service is reachable on the resolved IP:

```bash
# Try connecting via HTTP/HTTPS
curl -v http://internal.example.com
curl -v https://internal.example.com

# If we have an IP address, try directly
curl -v http://<IP_ADDRESS>

# Check if ports are open
telnet internal.example.com 80
telnet internal.example.com 443

# Alternative port checks
nc -zv internal.example.com 80
nc -zv internal.example.com 443

# Trace the network path
traceroute internal.example.com

# Check listening ports on local machine
ss -tuln | grep -E ':(80|443)'
```

![Service Reachability]
![Curl_talnet](https://github.com/user-attachments/assets/b09e8456-f056-4dae-a429-664704501832)
![connection_testing](https://github.com/user-attachments/assets/ce17827b-ff90-4d1f-a125-a38b24ce6c87)
![netstat](https://github.com/user-attachments/assets/c6cc0b6d-31e2-4e71-872c-575fd1e1404d)
![Traceroute](https://github.com/user-attachments/assets/2158c1cc-79f8-4d8c-ab57-669c219c8dde)



### Potential Causes

#### DNS-Related Issues:

1. **DNS server failure**: The DNS servers in /etc/resolv.conf are down or unreachable
2. **Missing/incorrect DNS records**: No record exists for internal.example.com or it has incorrect data
3. **DNS cache issues**: Stale DNS entries in cache
4. **Split-horizon DNS misconfiguration**: Internal DNS views not properly configured
5. **DNS propagation delays**: Recent changes haven't propagated
6. **Local DNS resolution override**: /etc/hosts entries missing or incorrect

#### Network/Service Issues:

7. **Firewall blocking DNS queries**: Network firewalls blocking port 53
8. **Routing problems**: Network routes to DNS or web server are broken
9. **VPN/network segregation**: Service only accessible from certain networks
10. **Service downtime**: Web service is down despite DNS working
11. **Load balancer issues**: Configuration problems with load balancers
12. **Network interface misconfiguration**: Using incorrect network interfaces

### Solutions

For each potential issue, here's how to confirm and fix it:

#### DNS Server Failure

**Confirm:**
```bash
# Check if DNS servers are responding
ping $(grep nameserver /etc/resolv.conf | head -1 | awk '{print $2}')
```

**Fix:**
```bash
# Update DNS servers temporarily
sudo sh -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'

# For persistent fix with systemd-resolved
sudo systemctl edit systemd-resolved.service
# Add:
# [Resolve]
# DNS=8.8.8.8 1.1.1.1
sudo systemctl restart systemd-resolved.service
```

#### Missing/Incorrect DNS Records

**Confirm:**
```bash
# Check if record exists
dig internal.example.com @<your_dns_server> +noall +answer
```

**Fix:** (on DNS server)
```bash
# Edit zone file
sudo vi /etc/bind/zones/db.example.com
# Add: internal IN A 192.168.1.100

# Reload DNS service
sudo systemctl reload bind9
# or
sudo systemctl reload named
```

#### DNS Cache Issues

**Confirm:**
```bash
# Compare cached vs authoritative results
dig internal.example.com
dig internal.example.com +trace
```

**Fix:**
```bash
# Flush DNS cache
sudo systemd-resolve --flush-caches
# or
sudo systemctl restart nscd
# or
sudo systemctl restart dnsmasq
```

#### Firewall Blocking Issues

**Confirm:**
```bash
# Check firewall rules
sudo iptables -L -n
```

**Fix:**
```bash
# Allow DNS traffic
sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 53 -j ACCEPT

# Allow web traffic
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Make it persistent
sudo iptables-save > /etc/iptables/rules.v4
```

#### Routing Problems

**Confirm:**
```bash
# Check routes
traceroute internal.example.com
ip route show
```

**Fix:**
```bash
# Add static route
sudo ip route add <server_network> via <gateway_ip>

# Make it permanent
sudo vi /etc/network/interfaces
# Add: post-up ip route add <server_network> via <gateway_ip>
```

#### VPN/Network Segregation

**Confirm:**
```bash
# Check network interfaces
ip a
```

**Fix:**
```bash
# Connect to required VPN
sudo openvpn --config /path/to/config.ovpn
# or
sudo nmcli con up VPN_Connection
```

### Bonus Configuration

#### Local hosts Entry to Bypass DNS

```bash
# Add entry to /etc/hosts
echo "192.168.1.100 internal.example.com" | sudo tee -a /etc/hosts

# Test it works
ping internal.example.com
```


#### Persist DNS Settings with systemd-resolved

```bash
sudo vi /etc/systemd/resolved.conf

  DNS=8.8.8.8 1.1.1.1
  FallbackDNS=9.9.9.9 149.112.112.112

sudo systemctl restart systemd-resolved
```

#### Persist DNS Settings with NetworkManager

```bash
# Create a DNS configuration
sudo vi /etc/NetworkManager/conf.d/dns-servers.conf
# Add:
# [global-dns-domain-*]
# servers=8.8.8.8,1.1.1.1

# Restart NetworkManager
sudo systemctl restart NetworkManager
```


Through systematic troubleshooting of these potential issues, you can identify and resolve the connectivity problems with the internal web dashboard.
