Bilkul, maine script mein saare JLPG Ultimate references ko NEOPLAYX se replace kar diya hai aur header/menu ka primary colour Red kar diya hai.

Yahan rahi aapki updated script:

Bash
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
echo "         🚀 NEOPLAYX INSTALLER 🚀       "
echo "========================================"
echo -e "${NC}"

# ========== MENU ==========
echo -e "${RED}1) Install Pterodactyl Panel${NC}"
echo -e "${RED}2) Install Wings${NC}"
echo -e "${RED}3) Install Panel + Wings${NC}"
echo -e "${RED}4) Create Admin User${NC}"
echo -e "${RED}5) Wings Auto Config${NC}"
echo -e "${RED}6) Install PufferPanel (NEW)${NC}"
echo -e "${RED}7) NEOPLAYX VM Manager${NC}"
echo -e "${RED}8) System Info${NC}"
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

echo -e "${RED}✅ Panel Installed Successfully!${NC}"
}

# ========== WINGS ==========
install_wings() {
loading
echo -e "${RED}Installing Wings...${NC}"

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

systemctl daemon-reexec
systemctl enable wings
systemctl start wings

echo -e "${RED}✅ Wings Installed!${NC}"
echo -e "${YELLOW}⚠️ Config Panel se generate karke /etc/pterodactyl/config.yml me daalo${NC}"
}

# ========== NEW PUFFER PANEL ==========
install_puffer() {
loading
echo -e "${RED}Installing PufferPanel (NEW)...${NC}"

read -p "Install PufferPanel? (y/n): " confirm
if [[ $confirm != "y" ]]; then
    echo "Cancelled"
    return
fi

bash <(curl -sSL https://raw.githubusercontent.com/MrRangerXD/puffer-panel/refs/heads/main/install)

echo -e "${RED}✅ PufferPanel Installed!${NC}"
echo -e "${YELLOW}🌐 Open: http://YOUR_IP:8080${NC}"
}

# ========== SYSTEM INFO ==========
system_info() {
echo -e "${RED}===== SYSTEM INFO =====${NC}"
echo -e "${RED}OS:${NC} $(lsb_release -d | cut -f2)"
echo -e "${RED}CPU:${NC} $(nproc) cores"
echo -e "${RED}RAM:${NC} $(free -h | awk '/Mem:/ {print $2}')"
echo -e "${RED}IP:${NC} $(curl -s ifconfig.me)"
}

# ========== MENU CONTROL ==========
case $option in

1)
install_panel
;;

2)
install_wings
;;

3)
install_panel
install_wings
;;

4)
cd /var/www/pterodactyl || exit
php artisan p:user:make
;;

5)
bash <(curl -s https://raw.githubusercontent.com/jlpggamerz/Wingcmd/refs/heads/main/install.sh)
;;

6)
install_puffer
;;

7)
bash <(curl -s https://raw.githubusercontent.com/jlpggamerz/Vps-cmd-code-/refs/heads/main/install.sh)
;;

8)
system_info
;;

9)
echo -e "${RED}Exiting...${NC}"
exit
;;

*)
echo -e "${RED}Invalid Option!${NC}"
;;

esac
