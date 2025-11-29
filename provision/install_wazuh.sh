#!/usr/bin/env bash
set -euo pipefail

MANAGER_IP=${1:-"127.0.0.1"}
export DEBIAN_FRONTEND=noninteractive

echo "[+] Updating system"
sudo apt-get update -y
sudo apt-get upgrade -y

echo "[+] Installing prerequisites"
sudo apt-get install -y curl apt-transport-https lsb-release gnupg2 software-properties-common unzip

# Install OpenJDK (required by Elastic)
sudo apt-get install -y openjdk-11-jre-headless

# Install Elasticsearch repository and Kibana (official)
# NOTE: Use Elastic 8.x or the supported version for Wazuh. This script uses the Wazuh all-in-one installer as shorthand.
echo "[+] Installing Wazuh manager + Elastic + Kibana via Wazuh install script"
# Download Wazuh quick installer (this script will handle components)
curl -sO https://packages.wazuh.com/4.8/wazuh-install.sh || curl -sO https://packages.wazuh.com/4.x/wazuh-install.sh
sudo bash wazuh-install.sh -a

# Wait a bit for services to come up
sleep 15

echo "[+] Wazuh & Elastic install script finished. Services starting..."

# Print basic status
sudo systemctl enable wazuh-manager --now || true
sudo systemctl enable elasticsearch --now || true
sudo systemctl enable kibana --now || true

echo "----------------------------------------------------------------"
echo "Wazuh manager should be installed."
echo "Kibana (with Wazuh plugin) typically available at: http://${MANAGER_IP}:5601"
echo "Wazuh API: http://${MANAGER_IP}:55000"
echo "Default credentials: check wazuh installer output (or set your own)."
echo "----------------------------------------------------------------"

# Open necessary firewall rules (if UFW is installed)
if command -v ufw >/dev/null 2>&1; then
  sudo ufw allow 5601/tcp
  sudo ufw allow 9200/tcp
  sudo ufw allow 1514/tcp
  sudo ufw allow 514/udp
fi

echo "[+] Provisioning complete."
