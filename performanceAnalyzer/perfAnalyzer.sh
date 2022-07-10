#!/bin/bash

execute_counting() {
    tput civis
    counting=0

    while [[ counting -le 60 ]]; do
        clear
        command_top=$(top -n 1 -b -o %MEM -E m | head -n 12)
        command_vmstat=$(vmstat -S M)
        command_iostat=$(iostat)

        printf "%s\n" "${command_top}"
        printf "\n%90s\n" " " | tr " " "-"
        printf "\n%s\n" "${command_vmstat}"
        printf "\n%90s\n" " " | tr " " "-"
        printf "\n%s\n" "${command_iostat}"
        printf "%90s" " " | tr " " "-"
        printf "\n%s" "PROGRESS: "

        if [[ ${counting} -ne 0 ]]; then
            printf "%$((counting / 5))s" " " | tr ' ' '#'
        fi    

        calc=$((60 - counting))
        
        if [[ ${calc} -eq 0 ]]; then
            printf "\n\n%s\n" "MONITORING COMPLETED! :P"
            tput cnorm
            printf "\n"
            exit 0
        fi

        printf "\n\n%s %d %s" "[" "${calc}" "second(s) remained for monitoring ]"
        sleep 5
        ((counting += 5))

    done
}

execute_counting