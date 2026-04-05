#!/bin/bash

# ========== COLORS ==========
RED='\033[1;31m'
NC='\033[0m'

# Sabko RED assign kar diya taaki poori script red dikhe
GREEN='\033[1;31m'
YELLOW='\033[1;31m'
CYAN='\033[1;31m'

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
echo "      NEOPLAYX INSTALLER "
echo "========================================"
echo -e "${NC}"

# ========== MENU ==========
echo -e "${RED}1) Install Pterodactyl Panel${NC}"
echo -e "${RED}2) Install Wings${NC}"
echo -e "${RED}3) Install Panel + Wings${NC}"
echo -e "${RED}4) Create Admin User${NC}"
echo -e "${RED}5) Wings Auto Config${NC}"
echo -e "${RED}6) Install PufferPanel${NC}"
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
CREATE DATABASE panel;
CREATE USER 'ptero'@'127.0.0.1' IDENTIFIED BY 'StrongPassword';
GRANT ALL PRIVILEGES ON panel.* TO 'ptero'@'127.0.0.1';
FLUSH PRIVILEGES;
EOF

# Env Setup
php artisan p:environment:setup
php artisan p:environment:database
php artisan p:environment:mail

# Migration
php artisan migrate --seed --force

# Permissions
chown -R www-data:www-data /var/www/pterodactyl/*

# Nginx Config
rm -f /etc/nginx/sites-enabled/default

cat <<EOF > /etc/nginx/sites-available/pterodactyl.conf
server {
    listen 80;
