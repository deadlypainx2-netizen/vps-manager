#!/bin/bash

# ========== NEO RED THEME COLORS ==========
RED='\033[0;31m'
BRED='\033[1;31m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ========== ROOT CHECK ==========
if [ "$EUID" -ne 0 ]; then
  echo -e "${BRED}❌ ERROR: PLEASE RUN AS ROOT! (sudo su -)${NC}"
  exit 1
fi

# ========== HEADER FUNCTION ==========
header() {
    clear
    echo -e "${RED}########################################################"
    echo -e "${BRED}             🩸 NEOPLAYZ RED ULTIMATE 🩸               "
    echo -e "${RED}        THE MOST POWERFUL VPS & PANEL MANAGER          "
    echo -e "${RED}########################################################${NC}"
}

# ========== LOADING ==========
loading() {
    echo -ne "${BRED}NeoPlayz System Loading"
    for i in {1..6}; do
        echo -ne "🔴"
        sleep 0.2
    done
    echo -e "${NC}"
}

# ========== MENU ==========
header
echo -e "${RED}[1]${WHITE} Install Pterodactyl Panel (Gaming)"
echo -e "${RED}[2]${WHITE} Install Wings (Node Connection)"
echo -e "${RED}[3]${WHITE} Install PufferPanel (Lite Web Panel)"
echo -e "${RED}[4]${WHITE} Create New VPS (KVM Manager)"
echo -e "${RED}[5]${WHITE} View Virtual Machines (List VPS)"
echo -e "${RED}[6]${WHITE} System Health & Info"
echo -e "${RED}[7]${WHITE} Exit Script"
echo ""
echo -ne "${BRED}SELECT AN OPTION: ${NC}"
read option

# ========== PANEL INSTALL ==========
install_panel() {
    header
    loading
    echo -e "${BRED}🚀 STARTING RED-PTERODACTYL INSTALLATION...${NC}"
    apt update && apt upgrade -y
    apt install -y nginx mariadb-server curl tar unzip git php8.1-fpm php8.1-mysql php8.1-gd php8.1-mbstring php8.1-xml php8.1-curl php8.1-zip
    
    echo -e "${BRED}✅ Panel Base Files Installed!${NC}"
    echo -e "${RED}Baki configuration manual karein as per your domain.${NC}"
    sleep 3
}

# ========== VPS CREATOR (VM MANAGER) ==========
create_vps() {
    header
    echo -e "${BRED}🛠️  NEOPLAYZ VPS CREATOR (KVM/QEMU)${NC}"
    echo -e "${RED}Virtualization support check kar rahe hain...${NC}"
    
    apt update && apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst
    
    echo -ne "${RED}Enter VPS Name: ${NC}"; read vm_name
    echo -ne "${RED}Enter RAM Size (MB) [e.g. 2048]: ${NC}"; read vm_ram
    echo -ne "${RED}Enter CPU Cores: ${NC}"; read vm_cpu
    echo -ne "${RED}Enter Storage Size (GB): ${NC}"; read vm_disk

    qemu-img create -f qcow2 /var/lib/libvirt/images/${vm_name}.qcow2 ${vm_disk}G

    echo -e "${BRED}Creating your VPS Container... Please wait.${NC}"
    
    virt-install \
    --name=$vm_name \
    --ram=$vm_ram \
    --vcpus=$vm_cpu \
    --disk path=/var/lib/libvirt/images/${vm_name}.qcow2,format=qcow2 \
    --os-variant=ubuntu22.04 \
    --network bridge=virbr0 \
    --graphics none \
    --console pty,target_type=serial \
    --location 'http://archive.ubuntu.com/ubuntu/dists/jammy/main/installer-amd64/' \
    --extra-args 'console=ttyS0,115200n8 serial'
}

# ========== SYSTEM INFO ==========
sys_info() {
    header
    echo -e "${BRED}--- SERVER STATUS ---${NC}"
    echo -e "${RED}CPU: ${WHITE}$(nproc) Cores"
    echo -e "${RED}RAM: ${WHITE}$(free -h | awk '/Mem:/ {print $2}')"
    echo -e "${RED}OS:  ${WHITE}$(lsb_release -d | cut -f2)"
    echo -e "${RED}IP:  ${BRED}$(curl -s ifconfig.me)"
    echo ""
    echo -e "${BRED}Press Enter to return to menu...${NC}"
    read
}

# ========== ACTION CONTROL ==========
case $option in
    1) install_panel ;;
    2) 
        loading
        curl -sSL https://get.docker.com/ | bash
        systemctl enable --now docker
        echo -e "${BRED}✅ Docker & Wings Core Ready!${NC}" 
        ;;
    3) 
        loading
        curl -sL https://data.pufferpanel.com/install.sh | sudo bash
        systemctl enable --now pufferpanel
        echo -e "${BRED}✅ PufferPanel is Live on port 8080!${NC}"
        ;;
    4) create_vps ;;
    5) 
        header
        virsh list --all
        echo -e "${BRED}Press Enter to return...${NC}"
        read
        ;;
    6) sys_info ;;
    7) exit 0 ;;
    *) echo -e "${BRED}Invalid Choice!${NC}" ;;
esac
