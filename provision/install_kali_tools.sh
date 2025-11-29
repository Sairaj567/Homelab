#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo "[+] Updating Kali"
sudo apt-get update -y
sudo apt-get upgrade -y

echo "[+] Installing common pentest tools (nmap, hydra, metasploit-framework, tcpdump)"
sudo apt-get install -y nmap hydra metasploit-framework tcpdump john wireshark nikto

# Ensure metasploit db init (may take time)
sudo msfdb init || true

echo "[+] Kali provisioning complete. Tools installed: nmap, hydra, metasploit-framework, tcpdump, john, nikto"
    