#!/bin/bash

# ========== COLORS (Blue Theme) ==========
RED='\033[1;31m'
BLUE='\033[1;34m'
NC='\033[0m'

# ========== ROOT CHECK ==========
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}❌ Please run as root!${NC}"
  exit
fi

set -e

# ========== LOADING ==========
loading() {
echo -ne "${BLUE}Processing"
for i in {1..5}; do
    echo -ne "."
    sleep 0.3
done
echo -e "${NC}"
}

# ========== HEADER ==========
clear
echo -e "${BLUE}"
echo "========================================"
echo "         🚀 NEOPLAYZ INSTALLER 🚀"
echo "========================================"
echo -e "${NC}"

# ========== MENU ==========
echo -e "${BLUE}1) Install Pterodactyl Panel${NC}"
echo -e "${BLUE}2) Install Wings${NC}"
echo -e "${BLUE}3) Install Panel + Wings${NC}"
echo -e "${BLUE}4) Create Admin User${NC}"
echo -e "${BLUE}5) Wings Auto Config${NC}"
echo -e "${BLUE}6) Install PufferPanel (NEW)${NC}"
echo -e "${BLUE}7) VPS Manager${NC}"
echo -e "${BLUE}8) System Info${NC}"
echo -e "${BLUE}9) Exit${NC}"

echo ""
read -p "👉 Select option [1-9]: " option

# ========== FUNCTIONS ==========

install_panel() {
  loading
  echo -e "${BLUE}Installing Pterodactyl Panel...${NC}"
  apt update -y && apt upgrade -y
  # ... (Rest of your install logic)
  echo -e "${BLUE}✅ Panel Installed!${NC}"
}

install_wings() {
  loading
  echo -e "${BLUE}Installing Wings...${NC}"
  # ... (Docker & Wings setup)
  echo -e "${BLUE}✅ Wings Installed!${NC}"
}

# ========== MENU CONTROL ==========
case $option in

1) install_panel ;;
2) install_wings ;;
3) install_panel && install_wings ;;
4) cd /var/www/pterodactyl && php artisan p:user:make ;;

5) 
   # Yaha check karo ki ye link tumhare GitHub pe sahi hai ya nahi
   bash <(curl -sSL https://raw.githubusercontent.com/neoplayz/Wingcmd/main/install.sh) || echo -e "${RED}Error: Wingcmd script nahi mili GitHub pe!${NC}"
   ;;

6) 
   bash <(curl -sSL https://raw.githubusercontent.com/MrRangerXD/puffer-panel/main/install)
   ;;

7) 
   # Yaha bhi check karo ki repository ka naam 'Vps-cmd-code-' hi hai na?
   echo -e "${BLUE}Launching VPS Manager...${NC}"
   bash <(curl -sSL https://raw.githubusercontent.com/neoplayz/Vps-cmd-code-/main/install.sh) || echo -e "${RED}Error: VPS Manager script nahi mili! Check your GitHub repo.${NC}"
   ;;

8) 
   echo -e "${BLUE}OS: $(hostnamectl | grep 'Operating System' | cut -d: -f2)${NC}"
   echo -e "${BLUE}RAM: $(free -h | awk '/Mem:/ {print $2}')${NC}"
   ;;

9) exit ;;
*) echo -e "${RED}Invalid Option!${NC}" ;;
esac
