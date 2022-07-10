#!/usr/bin/bash

declare -a directories=("$@")
usage="Usage: $0 [-d] [-t] directories/files"
declare -a for_parsing
declare -a options_validity=("-d" "-t")

totalSize() {
    for ((i=1;i<"${#directories[@]}";i++)); do
        if [[ ! -e ${directories[i]} ]]; then
            printf "\n\e[1;31m%s\e[0m\n" "ERROR - ${directories[i]} doesn't exists"
        else
            size_to_check="$(du -s "${directories[i]}" 2> /dev/null | cut -f1)"
            if [[ "${size_to_check}" -ge $((1024**2)) ]]; then
                size_to_print=$(printf "%.2f" "${size_to_check}" | awk '{printf "%.2f", $1/1024^2}')
                printf "\n\e[32m%s\e[0m  \e[33m%s\e[0m\n" "${directories[i]}" "${size_to_print} G"
            elif [[ "${size_to_check}" -gt 1024 ]]; then
                size_to_print=$(printf "%.2f" "${size_to_check}" | awk '{printf "%.2f", $1/1024}')
                printf "\n\e[32m%s\e[0m  \e[33m%s\e[0m\n" "${directories[i]}" "${size_to_print} M"
            else
                printf "\n\e[32m%s\e[0m  \e[33m%s\e[0m\n" "${directories[i]}" "${size_to_check} K"
            fi
        fi
    done

    printf "\n"
}

detailSize() {
    printf "\n"
    for ((i=1;i< "${#directories[@]}";i++)); do
        if [[ ! -e ${directories[i]} ]]; then
            printf "\n\e[1;31m%s\e[0m\n\n" "ERROR - ${directories[i]} doesn't exists"
        else
            while read -r parsed_arr; do
                for_parsing+=("${parsed_arr}")
            done <<< "$(du "${directories[i]}" 2> /dev/null)"
        fi  
    done

    for ((j=0;j<"${#for_parsing[@]}";j++)) do
        size="$(printf "%s" "${for_parsing[j]}" | cut -f1)"
        if [[ "${size}" -gt $((1024**2)) ]]; then
            size_to_print=$(printf "%.2f" "${size}" | awk '{printf "%.2f", $1/1024^2}')
            printf "\n\e[32m%s\e[0m  \e[33m%s\e[0m\n" "${for_parsing[i]}" "${size_to_print} G"
        elif [[ "${size}" -gt 1024 ]]; then
            printing_size=$(printf "%.2f" "${size}" | awk '{printf "%.2f", $1/1024}')
            printf "\e[32m%s\e[0m  \e[33m%s\e[0m\n" "$(printf "%s" "${for_parsing[j]}" | cut -f 2)" "${printing_size} M"
        else
            printf "\e[32m%s\e[0m  \e[33m%s\e[0m\n" "$(printf "%s" "${for_parsing[j]}" | cut -f 2)" "${size} K"
        fi
    done
    printf "\n"
}

check_opt_validity() {
    local count=0
    for ((i=0;i<"${#options_validity[@]}";i++)); do
        if [[ $1 != "${options_validity[i]}" ]]; then
            ((count++))
        fi
    done

    if  [[ ${count} -eq ${#options_validity[@]} ]]; then
            printf "\n\e[1;31m%s\e[0m\n\n" "${usage}"
            exit 1
    fi
}

main() {
    check_opt_validity "$@"
    while getopts ":dt" option; do
        case "${option}" in
            d) detailSize
               ;;
            t) totalSize
               ;;
            \?) printf "\n\e[1;31m%s\e[0m\n\n" "ERROR - no files/directories mentioned. ${usage}"
                ;;
        esac
    done
}

main "$@"