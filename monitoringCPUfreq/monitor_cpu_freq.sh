#!/usr/bin/bash

sanity_checks() {
    value_for_input="${1}"

    if [[ ! ${value_for_input} -gt 0 ]]; then
        printf "\n\033[1;31m%s\033[0m\n\n" " **ERROR - you need to specify how many checks you want!"
        tput cnorm
        exit 1
    fi
}

main() {
    declare -i number_of_measurements="${1}"
    declare -i count=0
    declare -i second_count=0

    clear
    printf "\n\n\033[1m%s\033[0m\n\n" " < Starting..${number_of_measurements}..measurements... >"
    sleep 1

    while true; do
        printf " %s" "${count}. CPU MHz: "
        lscpu | grep -E -i "cpu mhz" | awk '{print $NF}'
        sleep 1
        ((count++))
        ((second_count++))

        if [[ "${second_count}" -eq 5 ]]; then
            if [[ "${count}" -eq "${number_of_measurements}" ]]; then
                break
            else
                clear
            fi
            
            printf "\n\n\033[1m%s\033[0m\n\n" " < Continuing... >"
            second_count=0
        
        elif [[ "${count}" -eq "${number_of_measurements}" ]]; then
            break
        fi
    done

    printf "\n\033[1m%s\033[0m\n\n" " Completed!"
}

tput civis
given_input_value="${1}"
sanity_checks "${given_input_value}"
main "${given_input_value}"
tput cnorm
