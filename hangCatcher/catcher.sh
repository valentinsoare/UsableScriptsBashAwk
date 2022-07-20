#!/usr/bin/bash

count=1
number_of_hangs_to_exit="${1}"

control_c() {
    printf "\n\033[1;31m%s\033[0m\n\n" "**Script completed..."
    exit 0
}

sanity_checks() {
    if [[ -z "${number_of_hangs_to_exit}" ]]; then
        number_of_hangs_to_exit=10
    fi
}

to_exec() {
    start="$(date +%s)"
    sleep 1
    sleep 3     # simulate hang 3 seconds
    end="$(date +%s)"

    if [[ $((end - start)) -gt 1 ]]; then
        printf " %s" "$(date -ud @${start})"
        printf "\n\033[31m %s\033[0m\n" "(${count}) HANG time: $((end - start - 1)) seconds"
        printf " %s\n\n" "$(date -ud @${end})"
        ((count++))
    fi
}

main() {
    trap "" SIGTSTP
    trap control_c SIGINT

    sanity_checks

    while true; do
        to_exec

        if [[ "${count}" -eq "${number_of_hangs_to_exit}" ]]; then
            printf "\n\033[1;31m%s\033[0m\n\n" "Script completed..."
            exit 0
        fi
    done
}

main "${@}"