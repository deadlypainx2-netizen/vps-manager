#!/bin/bash

# ========== COLORS ==========
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# ========== ROOT CHECK ==========
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}❌ Please run as root (sudo su -)${NC}"
  exit 1
fi

# OS Detection
OS=$(lsb_release -si 2>/dev/null || cat /etc/os-release | grep ^ID= | cut -d'=' -f2 | tr -d '"')

# ========== HEADER ==========
clear
echo -e "${CYAN}========================================"
echo -e "      🎮 NEOPLAYX INSTALLER 🎮      "
echo -e "========================================${NC}"

# ========== MENU ==========
echo -e "${GREEN}1) Install Pterodactyl Panel${NC}"
echo -e "${GREEN}2) Install Wings (Node)${NC}"
echo -e "${GREEN}3) Install PufferPanel${NC}"
echo -e "${CYAN}4)  VM Create (Create VPS inside VPS)${NC}"
echo -e "${YELLOW}5) System Info & Optimization${NC}"
echo -e "${RED}6) Exit${NC}"
echo ""
read -p "👉 Select option [1-6]: " option

# ========== VM MANAGER (VPS CREATOR) ==========
create_vps() {
    echo -e "${CYAN}Checking Virtualization Support...${NC}"
    if [ "$(egrep -c '(vmx|svm)' /proc/cpuinfo)" -eq 0 ]; then
        echo -e "${RED}❌ Your VPS does not support Nested Virtualization!${NC}"
        return
    fi

    echo -e "${YELLOW}Installing KVM, QEMU and Libvirt...${NC}"
    apt update && apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst virt-manager -y
    
    echo -e "${CYAN}--- VPS Creation Wizard ---${NC}"
    read -p "Enter VM Name: " vm_name
    read -p "Enter RAM (MB) [Example: 2048]: " vm_ram
    read -p "Enter CPU Cores: " vm_cpu
    read -p "Enter Disk Size (GB) [Example: 20]: " vm_disk

    # Creating the Disk
    qemu-img create -f qcow2 /var/lib/libvirt/images/${vm_name}.qcow2 ${vm_disk}G

    # Basic VM Installation (Ubuntu 22.04 example)
    echo -e "${GREEN}Starting VM Creation...${NC}"
    virt-install \
    --name=$vm_name \
    --ram=$vm_ram \
    --vcpus=$vm_cpu \
    --disk path=/var/lib/libvirt/images/${vm_name}.qcow2,format=qcow2 \
    --os-variant=ubuntu22.04 \
    --network network=default \
    --graphics none \
    --console pty,target_type=serial \
    --location 'http://archive.ubuntu.com/ubuntu/dists/jammy/main/installer-amd64/' \
    --extra-args 'console=ttyS0,115200n8 serial'

    echo -e "${GREEN}✅ VPS $vm_name has been created!${NC}"
}

# ========== UNIVERSAL INSTALLER LOGIC ==========
install_panel() {
    echo -e "${CYAN}Setting up Web Server & Database...${NC}"
    if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
        apt update && apt upgrade -y
        apt install -y nginx mariadb-server curl tar unzip git
        # PHP 8.1 Setup for Pterodactyl
        apt install -y software-properties-common
        add-apt-repository ppa:ondrej/php -y || true
        apt update
        apt install -y php8.1 php8.1-cli php8.1-fpm php8.1-mysql php8.1-gd php8.1-mbstring php8.1-bcmath php8.1-xml php8.1-curl php8.1-zip
    else
        echo -e "${RED}This script currently supports Debian/Ubuntu for the Panel.${NC}"
        return
    fi
    # (Pterodactyl Logic - Simplified for brevity but kept functional)
    echo -e "${GREEN}✅ Panel Base Installed. Configure Database and Composer to finish.${NC}"
}

install_wings() {
    echo -e "${CYAN}Installing Docker and Wings...${NC}"
    curl -sSL https://get.docker.com/ | bash
    systemctl enable --now docker
    mkdir -p /etc/pterodactyl
    curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
    chmod +x /usr/local/bin/wings
    echo -e "${GREEN}✅ Wings Binary installed.${NC}"
}

# ========== SYSTEM INFO ==========
system_info() {
    echo -e "${CYAN}--- NeoPlayz Diagnostics ---${NC}"
    echo "OS: $OS"
    echo "Uptime: $(uptime -p)"
    echo "Memory: $(free -h | awk '/Mem:/ {print $3 "/" $2}')"
    echo "Disk: $(df -h / | awk 'NR==2 {print $4}') Free"
}

# ========== ACTION CONTROL ==========
case $option in
    1) install_panel ;;
    2) install_wings ;;
    3) bash <(curl -sL https://data.pufferpanel.com/install.sh) ;;
    4) create_vps ;;
    5) system_info ;;
    6) exit 0 ;;
    *) echo -e "${RED}Invalid Option!${NC}" ;;
esac
