#!/bin/bash

# ─────────────────────────────────────────
#  sysmon.sh — System Monitor
#  Autor: Maksymilian Kaczmarek
# ─────────────────────────────────────────

# KOLORY
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'
#to sa kody ansi - \033 poprzedza instrukcję -
# [0 oznacza niepogrubiona czcionke ;31 kolor
#czerwony a np 30 czarny - m to zakonczenie.

# ─── FUNKCJE METRYK ───────────────────────

get_cpu() {
    cpu=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | tr -d '%')
    echo "$cpu"
}

#top - pokazuje procesu - -l 1 oznacza zrob jeden odczyt procesu i zakoncz
#td -d '%' - usuwa podany znak - tutaj %

get_ram() {
    ram=$(top -l 1 | grep "PhysMem" | awk '{print $2}' | tr -d 'M')
    echo "$ram"
}

get_ram_percent() {
    local used=$(top -l 1 | grep "PhysMem" | awk '{print $2}' | tr -d 'M')
    local total=8192
    local percent=$(echo "$used $total" | awk '{printf "%.0f", $1 * 100 / $2}')
    echo "$percent"
}
# potrzebujemy jeszcze jednej funkcji dla RAMu zeby móc obliczyć procent ram w alercie a nie tylko wyswietlac MB.

get_disk() {
    disk=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
    echo "$disk"
}

# ─── WYŚWIETLANIE ─────────────────────────

print_header() {
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD}   SYSMON — $(date '+%H:%M:%S')${RESET}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

print_metric() {
    local name=$1
    local value=$2
    local unit=$3

    if [ "$value" -gt 80 ] 2>/dev/null; then
        color=$RED
    elif [ "$value" -gt 60 ] 2>/dev/null; then
        color=$YELLOW
    else
        color=$GREEN
    fi

    echo -e "  ${BOLD}${name}:${RESET} ${color}${value}${unit}${RESET}"
}

show_stats() {
    print_header
    print_metric "CPU " "$(get_cpu)" "%"
    print_metric "RAM " "$(get_ram)" " MB"
    print_metric "DISK" "$(get_disk)" "%" 
    echo ""
}

check_alerts() {
    local threshold=$1
    local cpu=$(get_cpu | awk '{printf "%.0f", $1}')
    local ram=$(get_ram_percent)
    local disk=$(get_disk)
    local alerted=0

    if [ "$cpu" -gt "$threshold" ]; then
        echo -e "${RED}ALERT: CPU przekroczył próg! (${cpu}%)${RESET}"
        alerted=1
    fi

    if [ "$ram" -gt "$threshold" ]; then
        echo -e "${RED}ALERT: RAM przekroczył próg! (${ram}%)${RESET}"
        alerted=1
    fi

    if [ "$disk" -gt "$threshold" ]; then
        echo -e "${RED}ALERT: DISK przekroczył próg! (${disk}%)${RESET}"
        alerted=1
    fi

    if [ "$alerted" -eq 0 ]; then
        echo -e "${GREEN}Wszystko w porządku - nic nie przekroczyło progu ${threshold}%${RESET}"
    fi
}

save_report(){
    local filename="/Users/tux/documents/cloud-learning/sysmon/reports/report_$(date '+%Y-%m-%d_%H:%M').txt"

    {
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  SYSMON REPORT — $(date '+%Y-%m-%d %H:%M:%S')"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  CPU: $(get_cpu)%"
        echo "  RAM: $(get_ram)%"
        echo "  DISK: $(get_disk)%"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    } > "$filename"

    echo -e "${GREEN}✅ Raport zapisany → ${filename}${RESET}"
}

# ─── MAIN ─────────────────────────────────

usage() {
    echo -e "${BOLD}Użycie:${RESET}"
    echo -e "  ./sysmon.sh              — jednorazowy snapshot"
    echo -e "  ./sysmon.sh --watch      — live monitoring co 5 sekund"
    echo -e "  ./sysmon.sh --alert <n>  — alert gdy metryka > n%"
    echo -e "  ./sysmon.sh --report     — zapisz raport do pliku"
    echo ""
    echo -e "${YELLOW}Przykład:${RESET}"
    echo -e "  ./sysmon.sh --alert 80"
}

if [ "$1" == "--watch" ]; then
    while true; do
        clear
        show_stats
        sleep 5
    done
elif [ "$1" == "--alert" ]; then

    if [ -z "$2" ]; then
        echo -e "${RED} Błąd: podaj próg alertu${RESET}"
        echo ""
        usage
        exit 1
    fi 

    if ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo -e "${RED} Błąd: próg musi być liczbą (np. 80)${RESET}"
        echo ""
        usage
        exit 1
    fi

    check_alerts "$2"
elif [ "$1" == "--report" ]; then
    save_report
elif [ -z "$1" ]; then
    show_stats
else
    echo -e "${RED}❌ Nieznana flaga: $1${RESET}"
    echo ""
    usage
    exit 1
fi
