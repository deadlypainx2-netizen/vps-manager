#!/bin/bash

# ========== RED THEME (NEOPLAYZ) ==========
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
echo -ne "${RED}NeoPlayz Loading"
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
echo "    🚀 NEOPLAYZ RED INSTALLER V4 🚀     "
echo "      BASED ON JLPG MASTER CODE         "
echo "========================================"
echo -e "${NC}"

# ========== MENU ==========
echo -e "${RED}1) Install Pterodactyl Panel${NC}"
echo -e "${RED}2) Install Wings${NC}"
echo -e "${RED}3) Install Panel + Wings (Full)${NC}"
echo -e "${RED}4) Create Admin User${NC}"
echo -e "${RED}5) Wings Auto Config${NC}"
echo -e "${RED}6) Install PufferPanel (NEW)${NC}"
echo -e "${RED}7) NeoPlayz VM Manager (VPS Create)${NC}"
echo -e "${RED}8) System Info${NC}"
echo -e "${RED}9) Exit${NC}"

echo ""
read -p "👉 Select option [1-9]: " option

# ========== PANEL INSTALL ==========
install_panel() {
loading
echo -e "${RED}Installing Pterodactyl Panel...${NC}"
apt update -y && apt upgrade -y
apt install nginx mysql-server redis-server curl tar unzip git software-properties-common -y
add-apt-repository ppa:ondrej/php -y
apt update
apt install php8.1 php8.1-cli php8.1-fpm php8.1-mysql php8.1-gd php8.1-mbstring php8.1-bcmath php8.1-xml php8.1-curl php8.1-zip -y
echo -e "${RED}✅ Panel Ready!${NC}"
}

# ========== WINGS ==========
install_wings() {
loading
echo -e "${RED}Installing Wings...${NC}"
curl -sSL https://get.docker.com/ | bash
systemctl enable --now docker
mkdir -p /etc/pterodactyl
curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
chmod +x /usr/local/bin/wings
echo -e "${RED}✅ Wings Installed!${NC}"
}

# ========== MENU CONTROL (JLPG STYLE) ==========
case $option in

1)
install_panel
;;

2)
install_wings
;;

3)
install_panel
install_wings
;;

4)
cd /var/www/pterodactyl || exit
php artisan p:user:make
;;

5)
# Original JLPG Wingcmd link
bash <(curl -s https://raw.githubusercontent.com/jlpggamerz/Wingcmd/refs/heads/main/install.sh)
;;

6)
bash <(curl -sL https://data.pufferpanel.com/install.sh)
;;

7)
# Ye hai JLPG ka working VPS Creator script
echo -e "${RED}Launching VPS Manager...${NC}"
bash <(curl -s https://raw.githubusercontent.com/jlpggamerz/Vps-cmd-code-/refs/heads/main/install.sh)
;;

8)
echo -e "${RED}===== SYSTEM INFO =====${NC}"
echo -e "${RED}OS:${NC} $(lsb_release -d | cut -f2)"
echo -e "${RED}RAM:${NC} $(free -h | awk '/Mem:/ {print $2}')"
echo -e "${RED}IP:${NC} $(curl -s ifconfig.me)"
;;

9)
exit
;;

*)
echo -e "${RED}Invalid Option!${NC}"
;;

esac
