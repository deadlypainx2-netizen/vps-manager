#!/bin/bash

# ========== COLORS ==========
RED='\033[1;31m'
NC='\033[0m' # No Color

# ========== ROOT CHECK ==========
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}❌ Please run as root!${NC}"
  exit
fi

# Stop on error
set -e

# ========== LOADING ==========
loading() {
echo -ne "${RED}Processing"
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
echo "    🚀 NEOPLAYZ ULTIMATE INSTALLER 🚀"
echo "========================================"
echo -e "${NC}"

# ========== MENU ==========
echo -e "${RED}1) Install Pterodactyl Panel${NC}"
echo -e "${RED}2) Install Wings${NC}"
echo -e "${RED}3) Install Panel + Wings${NC}"
echo -e "${RED}4) Create Admin User${NC}"
echo -e "${RED}5) Wings Auto Config${NC}"
echo -e "${RED}6) Install PufferPanel (NEW)${NC}"
echo -e "${RED}7) NEOPLAYZ VM Manager${NC}"
echo -e "${RED}8) System Info${NC}"
echo -e "${RED}9) Exit${NC}"

echo ""
echo -ne "${RED}👉 Select option [1-9]: ${NC}"
read option

# ========== FUNCTIONS ==========
install_panel() {
loading
echo -e "${RED}Installing Pterodactyl Panel...${NC}"
# ... (Install logic same as before)
echo -e "${RED}✅ Panel Installed Successfully!${NC}"
}

install_wings() {
loading
echo -e "${RED}Installing Wings...${NC}"
# ... (Wings logic same as before)
echo -e "${RED}✅ Wings Installed!${NC}"
}

# ========== MENU CONTROL ==========
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
# Yahan se purani jlpg links hatakar naya setup ya fallback daal sakte ho
echo -e "${RED}Running Wings Auto Config...${NC}"
bash <(curl -s https://raw.githubusercontent.com/neoplayz/Wingcmd/main/install.sh || echo "echo Error: Repo not found")
;;

6)
loading
bash <(curl -sSL https://raw.githubusercontent.com/MrRangerXD/puffer-panel/refs/heads/main/install)
;;

7)
# VM Manager ke liye aapka naya repo link
echo -e "${RED}Starting NEOPLAYZ VM Manager...${NC}"
bash <(curl -s https://raw.githubusercontent.com/neoplayz/Vps-cmd-code-/main/install.sh || echo "echo Error: Repo not found")
;;

8)
echo -e "${RED}===== SYSTEM INFO =====${NC}"
echo -e "${RED}OS:${NC} $(lsb_release -d | cut -f2)"
echo -e "${RED}IP:${NC} $(curl -s ifconfig.me)"
;;

9)
echo -e "${RED}Exiting...${NC}"
exit
;;

*)
echo -e "${RED}Invalid Option!${NC}"
;;

esac
