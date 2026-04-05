#!/bin/bash

# ========== COLORS ==========
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# ========== ROOT CHECK ==========
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}❌ Please run as root!${NC}"
  exit 1
fi

# Stop on error
set -e

# ========== LOADING ==========
loading() {
echo -ne "${YELLOW}Processing"
for i in {1..5}; do
    echo -ne "."
    sleep 0.3
done
echo -e "${NC}"
}

# ========== HEADER (NEOPLAYZ) ==========
clear
echo -e "${CYAN}========================================"
echo "     🚀 NEOPLAYZ ULTIMATE INSTALLER 🚀"
echo "========================================${NC}"

# ========== MENU ==========
echo -e "${GREEN}1) Install Pterodactyl Panel${NC}"
echo -e "${GREEN}2) Install Wings${NC}"
echo -e "${GREEN}3) Install Panel + Wings${NC}"
echo -e "${GREEN}4) Create Admin User${NC}"
echo -e "${GREEN}5) Wings Auto Config${NC}"
echo -e "${GREEN}6) Install PufferPanel (NEW)${NC}"
echo -e "${GREEN}7) NEOPLAYZ VM Manager${NC}"
echo -e "${GREEN}8) System Info${NC}"
echo -e "${GREEN}9) Exit${NC}"

echo ""
read -p "👉 Select option [1-9]: " option

# ========== PANEL INSTALL ==========
install_panel() {
    loading
    echo -e "${CYAN}Installing Pterodactyl Panel...${NC}"

    apt update -y && apt upgrade -y
    apt install nginx mysql-server redis-server curl tar unzip git software-properties-common -y

    add-apt-repository ppa:ondrej/php -y
    apt update
    apt install php8.1 php8.1-cli php8.1-fpm php8.1-mysql php8.1-gd php8.1-mbstring php8.1-bcmath php8.1-xml php8.1-curl php8.1-zip -y

    # Composer
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer

    # Setup Panel
    mkdir -p /var/www/pterodactyl
    cd /var/www/pterodactyl

    curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
    tar -xzvf panel.tar.gz

    chmod -R 755 storage/* bootstrap/cache/
    cp .env.example .env

    composer install --no-dev --optimize-autoloader
    php artisan key:generate

    # Database Setup
    mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS panel;
CREATE USER IF NOT EXISTS 'ptero'@'127.0.0.1' IDENTIFIED BY 'StrongPassword';
GRANT ALL PRIVILEGES ON panel.* TO 'ptero'@'127.0.0.1';
FLUSH PRIVILEGES;
EOF

    # Migration
    php artisan p:environment:setup
    php artisan p:environment:database
    php artisan p:environment:mail
    php artisan migrate --seed --force

    # Permissions
