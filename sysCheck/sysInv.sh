#!/bin/bash

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

option_quit_or_continue() {

    while read -p "*Type q/quit or c/ontinue: " line; do
        line="${line,,}"
        if [[ "${line:0:1}" == "q" ]]; then
            printf "\n\e[31m%s\e[0m\n\n" "Script terminated!"
            i=1
            break
        elif [[ "${line:0:1}" == "c" ]]; then
            i=0
            break
        else
            tput civis
            printf "\e[31m\n%s\e[0m\n\n" "You need to enter only q/quit or c/continue..."
            sleep 1
            tput cnorm
            continue   
        fi
    done
}

main() {
    
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

        printf "\e[1m\n**%s\n\e[0m" "VMstats"
        printf "%90s\n" " " | tr ' ' '-'
        vmstat

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

main
