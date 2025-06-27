#!/bin/bash

# AutoReconX - Simple Recon Automation Tool
# Author: VAPT Fresher | Bash Project | GitHub-Ready

# Ensure a target is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <target.com>"
    exit 1
fi

TARGET=$1
OUTPUT_DIR="output/$TARGET"
WORDLIST="/usr/share/wordlists/dirb/common.txt"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "[*] Starting recon on $TARGET..."
sleep 1

# 1. WHOIS Lookup
echo "[+] Running WHOIS..."
whois "$TARGET" > "$OUTPUT_DIR/whois.txt"

# 2. DNS Lookup
echo "[+] Running DNS Lookup..."
dig "$TARGET" ANY +short > "$OUTPUT_DIR/dns.txt"

# 3. Subdomain Enumeration (using crt.sh)
echo "[+] Enumerating Subdomains..."
curl -s "https://crt.sh/?q=%25.$TARGET&output=json" | \
jq -r '.[].name_value' | sort -u > "$OUTPUT_DIR/subdomains.txt"

# 4. Port Scanning
echo "[+] Running Nmap Scan..."
nmap -Pn -sV -T4 "$TARGET" -oN "$OUTPUT_DIR/nmap.txt"

# 5. Directory Bruteforcing
echo "[+] Running Gobuster..."
gobuster dir -u "http://$TARGET" -w "$WORDLIST" -o "$OUTPUT_DIR/gobuster.txt" -q

# 6. Nikto Web Vulnerability Scan
echo "[+] Running Nikto Scan..."
nikto -h "http://$TARGET" > "$OUTPUT_DIR/nikto.txt"

# 7. Banner Grabbing (Port 80)
echo "[+] Grabbing Web Server Banner..."
(echo -e "HEAD / HTTP/1.0\r\n\r\n"; sleep 2) | nc "$TARGET" 80 > "$OUTPUT_DIR/banner.txt"

# Done
echo "[✓] Recon complete. Results saved in '$OUTPUT_DIR'"
