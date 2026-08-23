FROM ubuntu:latest

# Install SSH server, neofetch, cURL, & utilitas sistem
RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    lsb-release \
    procps \
    net-tools \
    && rm -rf /var/lib/apt-get/lists/*

# Konfigurasi SSH Server
RUN mkdir -p /var/run/sshd /run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# Matikan MOTD bawaan Ubuntu yang ramai
RUN chmod -x /etc/update-motd.d/* 2>/dev/null || true
RUN echo "" > /etc/motd

# Buat Skrip MOTD Dinamis Bergaya SamuDev VPS
RUN echo '#!/bin/bash\n\
clear\n\
GREEN="\033[1;32m"\n\
CYAN="\033[1;36m"\n\
YELLOW="\033[1;33m"\n\
NC="\033[0m"\n\
\n\
HN=$(hostname)\n\
IP=$(curl -s --max-time 2 ifconfig.me || echo "152.55.185.168")\n\
OS=$(lsb_release -ds 2>/dev/null || echo "Ubuntu 24.04.4 LTS")\n\
KERN=$(uname -r)\n\
UPTIME=$(uptime -p | sed "s/up //")\n\
CPU=$(lscpu | grep "Model name:" | sed "s/Model name:[ \t]*//" | head -n1)\n\
[ -z "$CPU" ] && CPU="AMD EPYC 9655P 96-Core Processor (48 Core)"\n\
RAM_TOTAL=$(free -h | awk "/Mem:/ {print \$2}")\n\
RAM_USED=$(free -h | awk "/Mem:/ {print \$3}")\n\
DISK_TOTAL=$(df -h / | awk "NR==2 {print \$2}")\n\
DISK_USED=$(df -h / | awk "NR==2 {print \$3}")\n\
DISK_PERC=$(df -h / | awk "NR==2 {print \$5}")\n\
LOAD=$(uptime | awk -F"load average:" "{print \$2}")\n\
PORTS=$(netstat -tuln 2>/dev/null | awk "/LISTEN/ {print \$4}" | awk -F":" "{print \$NF}" | sort -u | tr "\n" "," | sed "s/,$//")\n\
[ -z "$PORTS" ] && PORTS="22,2307,6379,8080,11434,20128,20241,20242"\n\
\n\
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"\n\
echo -e "${CYAN}║            ${GREEN}SamuDev VPS${NC} ${YELLOW}• ONLINE${NC}                             ${CYAN}║${NC}"\n\
echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════╣${NC}"\n\
echo -e "${CYAN}║${NC} ${GREEN}Hostname${NC}   : $HN"\n\
echo -e "${CYAN}║${NC} ${GREEN}Username${NC}   : root"\n\
echo -e "${CYAN}║${NC} ${GREEN}IP PubLiK${NC}  : $IP"\n\
echo -e "${CYAN}║${NC} ${GREEN}OS${NC}         : $OS"\n\
echo -e "${CYAN}║${NC} ${GREEN}KerneL${NC}     : $KERN"\n\
echo -e "${CYAN}║${NC} ${GREEN}Uptime${NC}     : $UPTIME"\n\
echo -e "${CYAN}║${NC} ${GREEN}CPU${NC}        : $CPU"\n\
echo -e "${CYAN}║${NC} ${GREEN}RAM${NC}        : $RAM_USED / $RAM_TOTAL"\n\
echo -e "${CYAN}║${NC} ${GREEN}Storage${NC}    : $DISK_USED / $DISK_TOTAL ($DISK_PERC)"\n\
echo -e "${CYAN}║${NC} ${GREEN}Load Avg${NC}   : $LOAD"\n\
echo -e "${CYAN}║${NC} ${GREEN}TunneL${NC}     : Tidak ada"\n\
echo -e "${CYAN}║${NC} ${GREEN}Port Aktif${NC} : ,$PORTS,"\n\
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"\n\
echo -e " ${YELLOW}✦ Selamat datang, root! ✦${NC}\n"\n\
' > /etc/profile.d/samudev_motd.sh && chmod +x /etc/profile.d/samudev_motd.sh

EXPOSE 22

# Booting Script
CMD bash -c " \
  PASS=\${ROOT_PASSWORD:-password123} && \
  echo \"root:\$PASS\" | chpasswd && \
  exec /usr/sbin/sshd -D \
"
