#!/usr/bin/bash

declare INV_CURSOR
declare NORM_CURSOR
INV_CURSOR=$(tput civis)
NORM_CURSOR=$(tput cnorm)
source "${PWD}"/loaded_scripts/bar.sh 

loadingFeaturesScripts() {
    source "${PWD}"/loaded_scripts/systemHWinformation.sh
    source "${PWD}"/loaded_scripts/performanceChecker.sh
}

generate_banner() {
    local msg
    local edge
    
    msg="*${1}*"
    edge=$(printf "%s" "${msg}" | sed 's/./*/g')
    printf "%s\n" "${edge}"
    printf "%s\n" "${msg}"
    printf "%s\n" "${edge}"
}

catch_input() {
    local -a menu_options
    menu_options=('Please select: ' '1. System Information' '2. Performance checking' '0. Quit')

    clear
    generate_banner "Diagnostic Tools"
 
    for i in "${!menu_options[@]}"; do
        case "${i}" in
            0)  printf "\n\n\t%s\n\n" "${menu_options[i]}"
                ;;
            3)  printf "\t%s\n\n" "${menu_options[i]}"
                ;;
            *)  printf "\t%s\n" "${menu_options[i]}"
                ;;      
        esac
    done

    read -r -p " Enter selection [0-2] > " selection; printf "\n"
}

main() {
    loadingFeaturesScripts
    printf "%s\n" "${INV_CURSOR}"; clear; printf "\n\n"
    checking "loading.." 0.03
    displayProgress; sleep 0.3

    while true; do
        catch_input
        tput cup 11 0

        case "${selection}" in
            1)  loadingSystemInformation
                ;;
            2)  runningCheckers
                ;;
            0)  break
                ;;
            *)  printf "\n%s\n" "Invalid entry"
                ;;
        esac

        printf "\n%s" "Press any key to continue"
        read -r -n 1
    done

    printf "%s" "${NORM_CURSOR}"
    printf "\n \033[31m%s\e[0m\n\n" "Session ended - $(timedatectl show | grep -E -i '\<timeusec' | awk 'BEGIN {FS="="} {printf "%s\n", $2}')"  
}

main
