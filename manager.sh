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
  exit
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

# ========== HEADER ==========
clear
echo -e "${CYAN}"
echo "========================================"
echo "    🚀 NEOPLAYX ULTIMATE INSTALLER 🚀"
echo "========================================"
echo -e "${NC}"

# ========== MENU ==========
echo -e "${GREEN}1) Install Pterodactyl Panel${NC}"
echo -e "${GREEN}2) Install Wings${NC}"
echo -e "${GREEN}3) Install Panel + Wings${NC}"
echo -e "${GREEN}4) Create Admin User${NC}"
echo -e "${GREEN}5) Wings Auto Config${NC}"
echo -e "${GREEN}6) Install PufferPanel (NEW)${NC}"
echo -e "${GREEN}7) NEOPLAYX VM Manager${NC}"
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
    server_name _;

    root /var/www/pterodactyl/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOF

ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/
systemctl restart nginx

echo -e "${GREEN}✅ Panel Installed Successfully!${NC}"
}

# ========== WINGS ==========
install_wings() {
loading
echo -e "${CYAN}Installing Wings...${NC}"

curl -sSL https://get.docker.com/ | bash
systemctl enable docker
systemctl start docker

mkdir -p /etc/pterodactyl

curl -L -o /usr/local/bin/wings
