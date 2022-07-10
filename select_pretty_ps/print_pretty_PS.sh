#!/usr/bin/bash

needed_output="${1}"
given_ps_command="$(ps -eo user,pid,pri,nice,pcpu,time,pmem,rss,s,comm)"

main() {
    local -i matching
    i=0
    matching=0

    while read -r line; do
        if [[ "${i}" -eq "0" ]]; then
            printf "\n\033[1;32m%s\033[0m\n" "${line}"
            printf "\033[1;32m%62s\033[0m\n" " " | tr " " "-"
        else
            if [[ "${line}" =~ ${needed_output} ]]; then
                printf "\033[1;32m%s\033[0m\n" "${line}"
                ((matching++))
            fi
        fi
        ((i++))
done <<< "${given_ps_command}"

    if [[ "${matching}" -eq "0" ]]; then
        printf "\t\t\033[1;31m%s\033[0m\n" "##### Zero matched lines. #####"
        printf "\033[1;32m%62s\033[0m\n\n" " " | tr " " "-"
    else
        printf "\033[1;32m%62s\033[0m\n" " " | tr " " "-"
        printf "\033[1;32m%62s\033[0m\n\n" "matched: ${matching} lines"
    fi
}

main "${@}" 
