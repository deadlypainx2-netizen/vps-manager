#!/bin/bash

# ========== COLORS ==========
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

# ========== FUNCTIONS (Original Logic) ==========
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

install_wings() {
    loading
    echo -e "${RED}🚀 Installing Wings...${NC}"
    curl -sSL https://get.docker.com/ | bash
    systemctl enable --now docker
    mkdir -p /etc/pterodactyl
    curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
    chmod +x /usr/local/bin/wings
    echo -e "${RED}✅ Wings Core Ready!${NC}"
}

# ========== MAIN MENU LOOP ==========
main_menu() {
    header
    echo -e "${RED} ❑ DEPLOYMENT SERVICES${NC}"
    echo -e "  [1] Install Panel      [2] Install Wings"
    echo -e "  [3] Install P+W Full   [4] Create Admin User"
    echo -e ""
    echo -e "${RED} ❑ NEOPLAYZ VM ENGINE${NC}"
    echo -e "  [5] WINGS AUTO CONFIG  [6] INSTALL PUFFERPANEL"
    echo -e "  [7] VM MANAGER ENGINE  [8] SYSTEM INFO"
    echo -e "  [9] EXIT SCRIPT${NC}"
    echo ""
    read -p "👉 NeoPlayz Select [1-9]: " option

    case $option in
        1) install_panel; sleep 2; main_menu ;;
        2) install_wings; sleep 2; main_menu ;;
        3) install_panel; install_wings; sleep 2; main_menu ;;
        4) 
            if [ -d "/var/www/pterodactyl" ]; then
                cd /var/www/pterodactyl && php artisan p:user:make
            else
                echo -e "${RED}❌ Panel not found!${NC}"
            fi
            sleep 2; main_menu ;;
        5) bash <(curl -s https://raw.githubusercontent.com/jlpggamerz/Wingcmd/refs/heads/main/install.sh); main_menu ;;
        6) bash <(curl -sL https://data.pufferpanel.com/install.sh); main_menu ;;
        7)
            header
            echo -e "${RED}🚀 Launching NeoPlayz VM Manager...${NC}"
            sleep 1
            bash <(curl -s https://raw.githubusercontent.com/jlpggamerz/Vps-cmd-code-/refs/heads/main/install.sh) ;;
        8)
            header
            echo -e "${RED}--- SYSTEM INFO ---${NC}"
            echo -e "OS: $(lsb_release -d | cut -f2)"
            echo -e "RAM: $(free -h | awk '/Mem:/ {print $2}')"
            echo -e "IP: $(curl -s ifconfig.me)"
            echo ""
            read -p "Press Enter to return..."
            main_menu ;;
        9) echo -e "${RED}Exiting...${NC}"; exit 0 ;;
        *) main_menu ;;
    esac
}

# START
main_menu
