#!/usr/bin/bash

count=0
number_of_hangs_to_exit="${1}"

control_c() {
    printf "\n\033[1;31m%s\033[0m\n\n" "**Script completed..."
    exit 0
}

to_exec() {
    start="$(date +%s)"
    sleep 1
    sleep 4     # simulate hang 4 seconds
    end="$(date +%s)"

    if [[ $((end - start)) -gt 1 ]]; then
        printf " %s" "$(date -ud @${start})"
        printf "\n\033[31m %s\033[0m\n" "(${count}) HANG time: $((end - start)) seconds"
        printf " %s\n\n" "$(date -ud @${end})"
        ((count++))
    fi
}

main() {
    trap "" SIGTSTP
    trap control_c SIGINT

    while true; do
        to_exec

        if [[ "${count}" -eq "${number_of_hangs_to_exit}" ]]; then
            printf "\n\033[1;31m%s\033[0m\n\n" "Script completed..."
            exit 0
        fi
    done
}

main "${@}"