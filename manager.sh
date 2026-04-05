#!/bin/bash

# ========== COLORS (Updated to Blue) ==========
RED='\033[1;31m'
BLUE='\033[1;34m'
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

# ========== PANEL INSTALL (FIXED) ==========
install_panel() {
loading
echo -e "${BLUE}Installing Pterodactyl Panel...${NC}"

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

# Database Setup (Rebranded User)
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS panel;
CREATE USER IF NOT EXISTS 'neoplayz'@'127.0.0.1' IDENTIFIED BY 'StrongPassword123';
GRANT ALL PRIVILEGES ON panel.* TO 'neoplayz'@'127.0.0.1';
FLUSH PRIVILEGES;
EOF

# Migration & Seeding
php artisan migrate --seed --force

# Permissions
chown -R www-data:www-data /var/www/pterodactyl/*

echo -e "${BLUE}✅ Panel Installed Successfully!${NC}"
}

# ========== WINGS ==========
install_wings() {
loading
echo -e "${BLUE}Installing Wings...${NC}"

curl -sSL https://get.docker.com/ | bash
systemctl enable --now docker

mkdir -p /etc/pterodactyl
curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
chmod +x /usr/local/bin/wings

# Systemd Service Fix
cat <<EOF > /etc/systemd/system/wings.service
[Unit]
Description=Pterodactyl Wings
After=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
ExecStart=/usr/local/bin/wings
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable wings
echo -e "${BLUE}✅ Wings Installed!${NC}"
}

# ========== SYSTEM INFO ==========
system_info() {
echo -e "${BLUE}===== SYSTEM INFO =====${NC}"
echo -e "${BLUE}OS:${NC} $(hostnamectl | grep "Operating System" | cut -d: -f2)"
echo -e "${BLUE}CPU:${NC} $(nproc) cores"
echo -e "${BLUE}RAM:${NC} $(free -h | awk '/Mem:/ {print $2}')"
echo -e "${BLUE}IP:${NC} $(curl -s ifconfig.me)"
}

# ========== MENU CONTROL ==========
case $option in
1) install_panel ;;
2) install_wings ;;
3) install_panel && install_wings ;;
4) cd /var/www/pterodactyl && php artisan p:user:make ;;
5) bash <(curl -s https://raw.githubusercontent.com/neoplayz/Wingcmd/main/install.sh) || echo "Script not found" ;;
6) bash <(curl -sSL https://raw.githubusercontent.com/MrRangerXD/puffer-panel/main/install) ;;
7) # VPS Manager logic
   echo -e "${BLUE}Opening VPS Manager...${NC}"
   bash <(curl -s https://raw.githubusercontent.com/neoplayz/Vps-cmd-code-/main/install.sh) || echo "VPS Manager script not found" ;;
8) system_info ;;
9) exit ;;
*) echo -e "${RED}Invalid Option!${NC}" ;;
esac
