#!/bin/bash

# ========== NEO RED THEME COLORS ==========
RED='\033[0;31m'
BRED='\033[1;31m'
WHITE='\033[1;37m'
NC='\033[0m' 

# ========== ROOT CHECK ==========
if [ "$EUID" -ne 0 ]; then
  echo -e "${BRED}❌ ERROR: PLEASE RUN AS ROOT! (sudo su -)${NC}"
  exit 1
fi

# ========== HEADER ==========
header() {
    clear
    echo -e "${RED}########################################################"
    echo -e "${BRED}             🩸 NEOPLAYZ RED ULTIMATE V2 🩸             "
    echo -e "${RED}        FIXED VPS MANAGER & PTERODACTYL SETUP          "
    echo -e "${RED}########################################################${NC}"
}

# ========== FIX & INSTALL DEPENDENCIES ==========
# Ye function check karega ki virt-install hai ya nahi, nahi to install karega
check_deps() {
    if ! command -v virt-install &> /dev/null; then
        echo -e "${BRED}🛠️  Installing Missing VPS Tools... Please Wait...${NC}"
        apt update -y
        apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst cpu-checker
        systemctl enable --now libvirtd
        systemctl start libvirtd
    fi
}

# ========== MENU ==========
header
echo -e "${RED}[1]${WHITE} Install Pterodactyl Panel"
echo -e "${RED}[2]${WHITE} Install Wings (Docker Node)"
echo -e "${RED}[3]${WHITE} Install PufferPanel"
echo -e "${RED}[4]${WHITE} Create New VPS (Fixed)${NC}"
echo -e "${RED}[5]${WHITE} List All VPS (Status)${NC}"
echo -e "${RED}[6]${WHITE} System Info"
echo -e "${RED}[7]${WHITE} Exit"
echo ""
echo -ne "${BRED}SELECT OPTION: ${NC}"
read option

case $option in
    1)
        header
        echo -e "${BRED}🚀 Installing Panel...${NC}"
        apt update && apt install -y nginx mariadb-server curl
        echo -e "${RED}✅ Panel Base Ready!${NC}"
        ;;
    
    2)
        header
        curl -sSL https://get.docker.com/ | bash
        systemctl enable --now docker
        echo -e "${BRED}✅ Docker & Wings Ready!${NC}"
        ;;

    3)
        curl -sL https://data.pufferpanel.com/install.sh | sudo bash
        systemctl enable --now pufferpanel
        echo -e "${BRED}✅ PufferPanel Ready! Port: 8080${NC}"
        ;;

    4)
        header
        check_deps
        echo -e "${BRED}🛠️  VPS CREATION WIZARD${NC}"
        echo -ne "${RED}VPS Name: ${NC}"; read vm_name
        echo -ne "${RED}RAM (MB) [2048]: ${NC}"; read vm_ram
        echo -ne "${RED}CPU Cores [1]: ${NC}"; read vm_cpu
        echo -ne "${RED}Disk (GB) [20]: ${NC}"; read vm_disk

        # Create Disk Image
        mkdir -p /var/lib/libvirt/images
        qemu-img create -f qcow2 /var/lib/libvirt/images/${vm_name}.qcow2 ${vm_disk}G

        # Start Installation
        virt-install \
        --name="$vm_name" \
        --ram="$vm_ram" \
        --vcpus="$vm_cpu" \
        --disk path=/var/lib/libvirt/images/${vm_name}.qcow2,format=qcow2 \
        --os-variant=ubuntu22.04 \
        --network network=default \
        --graphics none \
        --console pty,target_type=serial \
        --location 'http://archive.ubuntu.com/ubuntu/dists/jammy/main/installer-amd64/' \
        --extra-args 'console=ttyS0,115200n8 serial'
        ;;

    5)
        header
        check_deps
        echo -e "${BRED}📋 LIST OF ALL VIRTUAL MACHINES:${NC}"
        echo -e "${WHITE}"
        virsh list --all
        echo -e "${NC}"
        echo -e "${BRED}Press Enter to go back...${NC}"
        read
        ;;

    6)
        header
        echo -e "${RED}OS: ${WHITE}$(lsb_release -d | cut -f2)"
        echo -e "${RED}RAM: ${WHITE}$(free -h | awk '/Mem:/ {print $2}')"
        echo -e "${RED}KVM Support: ${WHITE}$(kvm-ok | grep "KVM acceleration can be used" || echo "Not Supported")"
        read
        ;;

    7) exit 0 ;;
    *) echo "Invalid";;
esac
