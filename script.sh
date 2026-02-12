#!/bin/bash

if [ -t 1 ]; then
    PURPLE='\033[0;35m'
    BLUE='\033[0;34m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    NC='\033[0m'
else
    PURPLE=''; BLUE=''; GREEN=''; YELLOW=''; CYAN=''; NC=''
fi

scan_adb_rapido() {
    local network_prefix="192.168.3"
    local start=1
    local end=30
    
    (
        local spinner=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
        local i=0
        while true; do
            echo -ne "\r${PURPLE}[${BLUE}${spinner[i]}${PURPLE}]${YELLOW} Escaneando...${NC}"
            i=$(( (i+1) % 10 ))
            sleep 0.1
        done
    ) & 
    local spin_pid=$!
    
    local results=$(seq $start $end | xargs -P 50 -I{} bash -c '
        if timeout 0.3 nc -w 1 -z "192.168.3.{}" 5555 2>/dev/null; then
            echo "192.168.3.{}"
        fi
    ')
    
    kill $spin_pid 2>/dev/null
    echo -ne "\r\033[K" 
    
    if [[ -n "$results" ]]; then
        echo "$results" | while read ip; do
            echo -e "${GREEN}[+]${NC} $ip:5555"
        done
        echo -e "${CYAN}[*]${NC} Total: $(echo "$results" | wc -l) dispositivos"
    else
        echo -e "${YELLOW}[-]${NC} Nenhum dispositivo encontrado"
    fi
}

clear
echo -e "${CYAN}=== Android Debug Bridge  ===${NC}"
scan_adb_rapido
