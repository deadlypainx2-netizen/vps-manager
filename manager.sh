#!/bin/bash

# ========== RED COLORS ==========
RED='\033[1;31m'
BRED='\033[1;31m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# ========== ROOT CHECK ==========
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}❌ Please run as root!${NC}"
  exit
fi

# Stop on error
set -e

# ========== LOADING ==========
loading() {
echo -ne "${RED}NeoPlayz Processing"
for i in {1..5}; do
    echo -ne "."
    sleep 0.3
done
echo -e "${NC}"
}

# ========== HEADER ==========
clear
echo -e "${RED}"
echo "========================================"
echo "    🚀 NEOPLAYZ RED INSTALLER V3 🚀     "
echo "      POWERED BY NEOPLAYZ TOOLS         "
echo "========================================"
echo -e "${NC}"

# ========== MENU ==========
echo -e "${RED}1) Install Pterodactyl Panel${NC}"
echo -e "${RED}2) Install Wings${NC}"
echo -e "${RED}3) Create Admin User${NC}"
echo -e "${RED}4) Install PufferPanel${NC}"
echo -e "${RED}5) Create New VPS (KVM Setup)${NC}"
echo -e "${RED}6) List/Manage VPS${NC}"
echo -e "${RED}7) System Info${NC}"
echo -e "${RED}8) Exit${NC}"

echo ""
read -p "👉 Select option [1-8]: " option

# ========== PANEL INSTALL ==========
install_panel() {
loading
echo -e "${RED}Installing Pterodactyl Panel...${NC}"
apt update -y && apt upgrade -y
apt install nginx mysql-server redis-server curl tar unzip git software-properties-common -y
add-apt-repository ppa:ondrej/php -y
apt update
apt install php8.1 php8.1-cli php8.1-fpm php8.1-mysql php8.1-gd php8.1-mbstring php8.1-bcmath php8.1-xml php8.1-curl php8.1-zip -y
echo -e "${RED}✅ Panel Base Ready!${NC}"
}

# ========== VPS CREATOR (FIXED) ==========
create_vps() {
loading
echo -e "${RED}Installing Virtualization Tools...${NC}"
apt update && apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst
systemctl enable --now libvirtd

echo -e "${BRED}--- NeoPlayz VPS Wizard ---${NC}"
read -p "Enter VM Name: " vm_name
read -p "Enter RAM (MB) [2048]: " vm_ram
read -p "Enter CPU Cores: " vm_cpu
read -p "Enter Disk Size (GB): " vm_disk

qemu-img create -f qcow2 /var/lib/libvirt/images/${vm_name}.qcow2 ${vm_disk}G

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
}

# ========== MENU CONTROL ==========
case $option in

1)
install_panel
;;

2)
curl -sSL https://get.docker.com/ | bash
systemctl enable --now docker
mkdir -p /etc/pterodactyl
curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
chmod +x /usr/local/bin/wings
echo -e "${RED}✅ Wings Installed!${NC}"
;;

3)
cd /var/www/pterodactyl || exit
php artisan p:user:make
;;

4)
bash <(curl -sL https://data.pufferpanel.com/install.sh)
;;

5)
create_vps
;;

6)
virsh list --all
;;

7)
echo -e "${RED}===== SYSTEM INFO =====${NC}"
echo -e "${RED}OS:${NC} $(lsb_release -d | cut -f2)"
echo -e "${RED}RAM:${NC} $(free -h | awk '/Mem:/ {print $2}')"
echo -e "${RED}IP:${NC} $(curl -s ifconfig.me)"
;;

8)
exit
;;

*)
echo -e "${RED}Invalid Option!${NC}"
;;

esac
