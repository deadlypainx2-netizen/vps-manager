#!/bin/bash

# ========== RED THEME COLORS ==========
RED='\033[1;31m'
BRED='\033[1;31m'
WHITE='\033[1;37m'
NC='\033[0m'

# ========== ROOT CHECK ==========
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}❌ Please run as root! (sudo su -)${NC}"
  exit
fi

# Stats for Header
RAM_Usage=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
Uptime=$(uptime -p | sed 's/up //')
CPU_Load=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')

# ========== HEADER ==========
header() {
clear
echo -e "${RED} HOST: $(hostname)   ▐█ $Uptime   ▐█ RAM: $RAM_Usage%   ▐█ NEOPLAYZ: ACTIVE${NC}"
echo -e "${BRED}"
echo "      ███╗   ██╗███████╗ ██████╗ ██████╗ ██╗      █████╗ ██╗   ██╗███████╗"
echo "      ████╗  ██║██╔════╝██╔═══██╗██╔══██╗██║     ██╔══██╗╚██╗ ██╔╝╚══███╔╝"
echo "      ██╔██╗ ██║█████╗  ██║   ██║██████╔╝██║     ███████║ ╚████╔╝   ███╔╝ "
echo "      ██║╚██╗██║██╔══╝  ██║   ██║██╔═══╝ ██║     ██╔══██║  ╚██╔╝   ███╔╝  "
echo "      ██║ ╚████║███████╗╚██████╔╝██║     ███████╗██║  ██║   ██║   ███████╗"
echo "      ╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝"
echo -e "                       POWERED BY NEOPLAYZ RED                         "
echo -e "${RED}──────────────────────────────────────────────────────────${NC}"
}

# ========== MENU FUNCTION ==========
menu() {
header
echo -e "${RED} ❑ ACTIVE NEOPLAYZ NODES${NC}"
echo -e "${WHITE} NAME           | STATUS   | SSH PORT | RAM${NC}"
echo -e "${RED} ---------------|----------|----------|--------${NC}"
echo -e "   Checking Nodes... [Option 7 to Manage]"
echo ""
echo -e "${RED} System Health: CPU: $CPU_Load%  RAM: $RAM_Usage%  Disk: $(df -h / | awk 'NR==2 {print $5}')${NC}"
echo ""

echo -e "${RED} ❑ DEPLOYMENT SERVICES${NC}"
echo -e "  [1] Install Panel      [2] Install Wings"
echo -e "  [3] Create Admin       [4] Install PufferPanel"
echo ""
echo -e "${RED} ❑ NEOPLAYZ VM ENGINE${NC}"
echo -e "  [7] DIRECT VPS MANAGER [8] SYSTEM INFO"
echo -e "  [9] EXIT SCRIPT${NC}"
echo ""
read -p "👉 Select Option: " option

case $option in
1)
    header
    echo -e "${RED}🚀 Installing Pterodactyl...${NC}"
    apt update -y && apt install nginx mysql-server curl tar unzip git software-properties-common -y
    add-apt-repository ppa:ondrej/php -y && apt update
    apt install php8.1 php8.1-cli php8.1-fpm php8.1-mysql php8.1-gd php8.1-mbstring php8.1-bcmath php8.1-xml php8.1-curl php8.1-zip -y
    echo -e "${RED}✅ Panel Base Ready!${NC}"
