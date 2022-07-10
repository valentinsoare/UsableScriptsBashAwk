#!/usr/bin/env/bash

get_temperature() {
    local temp_files="/sys/class/thermal/thermal_zone*"
    local -A allTemp
    
    for i in ${temp_files}; do
        if get_tempCalc="$(cat "${i}"/temp 2> /dev/null)" ; then
            get_tempCalc=$((get_tempCalc / 1000))
            get_type=$(cat "${i}"/type)
            allTemp["${get_type}"]="${get_tempCalc}"
        fi
    done 

    for i in "${!allTemp[@]}"; do
        printf "%s: %d%s\n" "${i}" "${allTemp[$i]}" "°C"
    done
}

cpuFreq() {
    declare number_core
    number_core=1

    while read -r values; do

        lines="$(printf "%.0f" "${values}")"
    
        if [[ "${lines}" -gt 3700 ]]; then
            printf "\033[1;31m%s\t\t%s\033[0m\n" "CORE: ${number_core}" "${values} - we need to cool it down."
        elif [[ "${lines}" -gt 3500 ]]; then
            printf "\033[1;33m%s\t\t%s\033[0m\n" "CORE: ${number_core}" "${values} - it's getting hot."
        else   
            printf "%s\t\t%s\n" "CORE: ${number_core}" "${values} mhz"
        fi

        ((number_core++))

    done <<< "$(grep -E 'MHz' /proc/cpuinfo | awk 'BEGIN {FS=":"} {printf "%s\n", $2}')"
}

option_quit_or_continue() {
    
    while read -r -p "*Type q/quit or c/ontinue: " line; do
        line="${line,,}"

        if [[ "${line:0:1}" == "q" ]]; then
            printf "\n\e[31m%s\e[0m\n" "closing performance checker.."
            sleep 0.3
            i=1
            break
        elif [[ "${line:0:1}" == "c" ]]; then
            i=0
            break
        else
            tput civis
            printf "\e[31m\n%s\e[0m\n\n" "You need to enter only q/quit or c/continue..."
            sleep 0.1
            tput cnorm
            continue   
        fi
    done
}

runningCheckers() {
    i=0

    while [[ "${i}" -eq 0 ]]; do

        printf "\e[1m\n**%s\n\e[0m" "Uptime"
        printf "%90s\n" " "  | tr ' ' '-'
        uptime

        printf "\e[1m\n**%s\n\e[0m" "Memory Usage"
        printf "%90s\n" " " | tr ' ' '-'
        free -mh

        printf "\e[1m\n**%s\n\e[0m" "Disk space and inodes usage"
        printf "%90s\n" " " | tr ' ' '-'
        df -hT
        printf "%90s\n" " " | tr ' ' '-'
        df -iT

        printf "\e[1m\n**%s\n\e[0m" "Current temperature"
        printf "%90s\n" " " | tr ' ' '-'
        get_temperature
        
        printf "\n"
        printf "\e[1m**%s\n\e[0m" "Top 10 processes with high CPU utilization"
        printf "%90s\n" " " | tr ' ' '-'
        top -b -n 1 | head -n 20

        printf "\n\e[1m**%s\n\e[0m" "CPU Cores Frequency"
        printf "%90s\n" " " | tr ' ' '-'
        cpuFreq

        printf "\e[1m\n**%s\n\e[0m" "VMstats"
        printf "%90s\n" " " | tr ' ' '-'
        vmstat -w

        printf "\e[1m\n**%s\n\e[0m" "I/Ostats"
        printf "%90s\n" " " | tr ' ' '-'
        iostat

        printf "\e[1m**%s\n\e[0m" "System Activity Information"
        printf "%90s\n" " " | tr ' ' '-'
        sar
        
        printf "\n"
        option_quit_or_continue
    done
}
