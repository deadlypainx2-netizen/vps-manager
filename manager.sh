#!/bin/bash

# ========== COLORS ==========
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# ========== ROOT CHECK ==========
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}❌ Please run as root! (sudo su -)${NC}"
  exit
fi

# Stop on error
set -e

# ========== LOADING FUNCTION ==========
loading() {
echo -ne "${YELLOW}NeoPlayz is Processing"
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
echo "      🎮 NEOPLAYZ ULTIMATE INSTALLER 🎮 "
echo "        Quality & Power Combined        "
echo "========================================"
echo -e "${NC}"

# ========== MENU ==========
echo -e "${GREEN}1) Install Pterodactyl Panel${NC}"
echo -e "${GREEN}2) Install Wings (Node)${NC}"
echo -e "${GREEN}3) Install Panel + Wings (Full Setup)${NC}"
echo -e "${GREEN}4) Create Admin User (Pterodactyl)${NC}"
echo -e "${GREEN}5) Install PufferPanel${NC}"
echo -e "${GREEN}6) System Info & Health${NC}"
echo -e "${RED}7) Exit${NC}"

echo ""
read -p "👉 Select option [1-7]: " option

# ========== PANEL INSTALL ==========
install_panel() {
loading
echo -e "${CYAN}🚀 Installing Pterodactyl Panel...${NC}"

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

# Database Setup (Auto-Generated Password for Security)
DB_PASSWORD=$(openssl rand -base64 12)
mysql -u root <<EOF
CREATE DATABASE panel;
CREATE USER 'ptero'@'127.0.0.1' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON panel.* TO 'ptero'@'127.0.0.1';
FLUSH PRIVILEGES;
EOF

echo -e "${YELLOW}Database Created! User: ptero | Pass: $DB_PASSWORD${NC}"

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

echo -e "${GREEN}✅ NeoPlayz: Panel Installed Successfully!${NC}"
}

# ========== WINGS ==========
install_wings() {
loading
echo -e "${CYAN}🛸 Installing Wings...${NC}"

curl -sSL https://get.docker.com/ | bash
systemctl enable docker
systemctl start docker

mkdir -p /etc/pterodactyl
curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
chmod +x /usr/local/bin/wings

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
systemctl start wings

echo -e "${GREEN}✅ Wings Installed!${NC}"
echo -e "${YELLOW}💡 Hint: Paste your config.yml in /etc/pterodactyl/ and restart wings.${NC}"
}

# ========== PUFFER PANEL ==========
install_puffer() {
loading
echo -e "${CYAN}🌀 Installing PufferPanel...${NC}"
curl -sL https://data.pufferpanel.com/install.sh | sudo bash
sudo systemctl enable --now pufferpanel
echo -e "${GREEN}✅ PufferPanel Installed!${NC}"
echo -e "${YELLOW}🌐 Access via: http://YOUR_IP:8080${NC}"
}

# ========== SYSTEM INFO ==========
system_info() {
clear
echo -e "${CYAN}===== NEOPLAYZ SYSTEM HEALTH =====${NC}"
echo -e "${GREEN}OS:${NC} $(lsb_release -d | cut -f2)"
echo -e "${GREEN}CPU:${NC} $(nproc) Cores"
echo -e "${GREEN}RAM:${NC} $(free -h | awk '/Mem:/ {print $2}')"
echo -e "${GREEN}IP:${NC} $(curl -s ifconfig.me || echo 'No Internet')"
echo -e "${GREEN}Disk:${NC} $(df -h / | awk 'NR==2 {print $4}') Free"
echo -e "${CYAN}==================================${NC}"
}

# ========== MENU CONTROL ==========
case $option in
1) install_panel ;;
2) install_wings ;;
3) install_panel && install_wings ;;
4)
    if [ -d "/var/www/pterodactyl" ]; then
        cd /var/www/pterodactyl && php artisan p:user:make
    else
        echo -e "${RED}❌ Panel not found! Install it first.${NC}"
    fi
    ;;
5) install_puffer ;;
6) system_info ;;
7) 
    echo -e "${RED}👋 Closing NeoPlayz Installer... Bye!${NC}"
    exit 
    ;;
*) echo -e "${RED}❌ Invalid Option!${NC}" ;;
esac
