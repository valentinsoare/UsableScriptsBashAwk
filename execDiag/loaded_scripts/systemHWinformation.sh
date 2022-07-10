#!/usr/bin/env bash

generate_banner() {
    local msg
    local edge
    msg="* $* *"
    edge=$(printf "%s\n" "${msg}" | sed 's/./*/g')
    printf "%s\n" "${edge}"
    printf "%s\n" "${msg}"
    printf "%s" "${edge}"
}

printChars() {
    local input
    local type
    input=$1
    type=$2
    for ((i=0; i<input; i++)); do
        printf "\e[38;5;15m%s\e[0m" "${type}"
    done
}

printInterfaces() {
    local j=0
    printf "\e[1;38;5;142m%s\e[0m\n" "*IPs NETWORK INTERFACES:"
    for i in $(ip addr show | grep -E -e '^[[:digit:]].* ' | awk '{print $2}'); do
        VAR=${i%:*}
        if [[ ${j} -ne 0 ]]; then
            printChars 60 "="
        fi
        echo -e "\n\e[1m*INTERFACE:\e[0m\t\t\t\t${VAR} \n$(nmcli device show "${VAR}" | grep -E 'TYPE|HWADDR|MTU|STATE|IP4.(ADDRESS|GATEWAY)')"
        ((j++))
    done
}

printCPUinfo() {
    lscpu | while IFS= read -r line; do 
        echo ${line} | grep -E 'Architecture|op-mode|CPU(s)|On-line|Thread|Core|Socket|Model Name|CPU MHz|Virtua|Hyper|Virtualization type'; 
    done
}

printMem() {
    echo -e "\e[1;38;5;132m*MEMORY INFO:\e[0m"
    while IFS= read -r line; do
        echo ${line} | grep -E 'MemTotal|MemFree|MemAvailable|Buffers|\<Cached:|Active:|Inactive:'
    done < /proc/meminfo
}

CPU_all() {
    CPU_load=$(uptime | grep -Eo 'load average.*')
    
    echo -e "\e[1;38;5;111m*CPU INFO:\e[0m"
    printCPUinfo
    echo -e "\n\e[1;38;5;34m*CPU LOAD:\e[0m \n${CPU_load}"
}

printNetwork() {
    local k
    k=0

    echo -e "\e[1;38;5;165m*NETWORK INFO:\e[0m"
    lshw | grep -A10 'network' | while IFS= read -r line; do
        if [[ ${k} -eq 14 ]]; then
            echo ${line} | grep -E 'configuration' | head -n 1 | cut -d " " -f1,2,4,6,7,12,13,14
        fi
        echo -e ${line} | grep -E 'description|product|vendor|logical name|serial'
        ((k++))
    done

    printf "\n%s\n" "**Kernel drivers and modules per network controller: "
    lshw | grep -A15 'network' | grep -E 'product' | awk 'BEGIN {FS=": "} {print $2}' | while read -r line; do 
        printf "%s\n" "$(lspci -k | grep -E -A3 -i "${line}" | grep -E -i '(Ethernet|Network)|Kernel')"
    done
}

loadingSystemInformation() {
    printf "\n"
    generate_banner "                   SYSTEM INFORMATION                   " 
    printf "\n\n\e[1;38;5;203m%s\e[0m%s\n" "*DEVICES MOUNTED:" "${STORAGE_DEVICE}"
    df -hT
    printChars 60 "-"; printf "\n";
    printMem
    printChars 60 "-"
    printf "\n"; CPU_all
    printChars 60 "-"; printf "\n"
    printNetwork
    printChars 60 "-"; printf "\n"
    printInterfaces
    printChars 60 "-"; printf "\n"
}