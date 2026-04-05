#!/bin/bash

# ========== RED THEME COLORS ==========
RED='\033[1;31m'
BRED='\033[1;31m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# ========== ROOT CHECK ==========
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}❌ Please run as root! (sudo su -)${NC}"
  exit 1
fi

# Stats for Header
RAM_Usage=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
Uptime=$(uptime -p | sed 's/up //')
CPU_Load=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')

# ========== LOADING ==========
loading() {
echo -ne "${RED}NeoPlayz Processing"
for i in {1..5}; do
    echo -ne "."
    sleep 0.2
done
echo -e "${NC}"
}

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

# ========== PANEL INSTALL ==========
install_panel() {
loading
echo -e "${RED}🚀 Installing Pterodactyl Panel...${NC}"
apt update -y && apt upgrade -y
apt install nginx mysql-server redis-server curl tar unzip git software-properties-common -y
add-apt-repository ppa:ondrej/php -y && apt update
apt install php8.1 php8.1-cli php8.1-fpm php8.1-mysql php8.1-gd php8.1-mbstring php8.1-bcmath php8.1-xml php8.1-curl php8.1-zip -y

curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

mkdir -p /var/www/pterodactyl && cd /var/www/pterodactyl
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/
cp .env.example .env
composer install --no-dev --optimize-autoloader
php artisan key:generate

echo -e "${RED}✅ Panel Base Ready!${NC}"
}

# ========== MENU CONTROL ==========
menu() {
header
echo -e "${RED} ❑ ACTIVE NEOPLAYZ NODES${NC}"
echo -e "${WHITE} NAME           | STATUS   | SSH PORT | RAM${NC}"
echo -e "${RED} ---------------|----------|----------|--------${NC}"
echo -e "   Checking Nodes... [Option 7 to Manage]"
echo ""
echo -e "${RED} System Health: CPU: $CPU_Load%  RAM: $RAM_Usage%  Disk: $(df -h / | awk 'NR==2 {print $5}')${NC}"
echo ""
echo -e "${RED}1) Install Panel         2) Install Wings${NC}"
echo -e "${RED}3) Install Panel+Wings   4) Create Admin User${NC}"
echo -e "${RED}5) Wings Auto Config     6) Install PufferPanel${NC}"
echo -e "${RED}7) NEOPLAYZ VM MANAGER   8) System Info${NC}"
echo -e "${RED}9) Exit Script${NC}"
echo ""
read -p "👉 NeoPlayz Select: " option

case $option in
    1) install_panel; sleep 2; menu ;;
    2)
        loading
        curl -sSL https://get.docker.com/ | bash
        systemctl enable --now docker
        mkdir -p /etc/pterodactyl
        curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
        chmod +x /usr/local/bin/wings
        echo -e "${RED}✅ Wings Installed!${NC}"
        sleep 2; menu ;;
    3) install_panel; curl -sSL https://get.docker.com/ | bash; menu ;;
    4)
        if [ -d "/var/www/pterodactyl" ]; then
            cd /var/www/pterodactyl && php artisan p:user:make
        else
            echo -e "${RED}❌ Panel Not Found!${NC}"
        fi
        sleep 2; menu ;;
    5) bash <(curl -s https://raw.githubusercontent.com/jlpggamerz/Wingcmd/refs/heads/main/install.sh); menu ;;
    6) bash <(curl -sL https://data.pufferpanel.com/install.sh); menu ;;
    7)
        header
        echo -e "${RED}🚀 Launching NeoPlayz VM Engine...${NC}"
        sleep 1
        bash <(curl -s https://raw.githubusercontent.com/jlpggamerz/Vps-cmd-code-/refs/heads/main/install.sh) ;;
    8)
        header
        echo -e "${RED}OS:${NC} $(lsb_release -d | cut -f2)"
        echo -e "${RED}RAM:${NC} $(free -h | awk '/Mem:/ {print $2}')"
        echo -e "${RED}IP:${NC} $(curl -s ifconfig.me)"
        read -p "Press Enter..."
        menu ;;
    9) exit 0 ;;
    *) menu ;;
esac
}

# Start
menu
