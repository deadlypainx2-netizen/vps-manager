#!/bin/bash

# ========== COLORS ==========
RED='\033[1;31m'
NC='\033[0m' # No Color

# ========== ROOT CHECK ==========
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}❌ Please run as root!${NC}"
  exit 1
fi

# ========== LOADING ==========
loading() {
  echo -ne "${RED}Processing"
  for i in {1..5}; do
      echo -ne "."
      sleep 0.2
  done
  echo -e "${NC}"
}

# ========== HEADER ==========
clear
echo -e "${RED}========================================"
echo "    🚀 NEOPLAYZ ULTIMATE INSTALLER 🚀"
echo "========================================${NC}"

# ========== MENU ==========
echo -e "${RED}1) Install Pterodactyl Panel"
echo "2) Install Wings"
echo "3) Install Panel + Wings"
echo "4) Create Admin User"
echo "5) Wings Auto Config"
echo "6) Install PufferPanel (NEW)"
echo "7) NEOPLAYZ VM Manager"
echo "8) System Info"
echo "9) Exit${NC}"

echo ""
echo -ne "${RED}👉 Select option [1-9]: ${NC}"
read option

# ========== FUNCTIONS ==========

install_panel() {
    loading
    echo -e "${RED}Installing Pterodactyl Panel...${NC}"
    apt update -y && apt upgrade -y
    apt install nginx mysql-server redis-server curl tar unzip git software-properties-common -y
    add-apt-repository ppa:ondrej/php -y
    apt update
    apt install php8.1 php8.1-cli php8.1-fpm php8.1-mysql php8.1-gd php8.1-mbstring php8.1-bcmath php8.1-xml php8.1-curl php8.1-zip -y
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    mkdir -p /var/www/pterodactyl
    cd /var/www/pterodactyl
    curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
    tar -xzvf panel.tar.gz
    chmod -R 755 storage/* bootstrap/cache/
    cp .env.example .env
    composer install --no-dev --optimize-autoloader
    php artisan key:generate
    echo -e "${RED}✅ Panel Files Ready!${NC}"
}

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

# ========== MENU CONTROL ==========
case $option in
    1)
        install_panel
