#!/usr/bin/bash

count=0
number_of_hangs_to_exit="${1}"

to_exec() {
    start="$(date +%s)"
    sleep 2
    sleep 5     # to simulate hang
    end="$(date +%s)"

    if [[ $((end - start)) -gt 2 ]]; then
        printf "%s" "$(date -ud @${start})"
        printf "\n\033[1;31m %s\033[0m\n" "(${count}) HANG time: $((end - start)) seconds"
        printf "%s\n\n" "$(date -ud @${end})"
        ((count++))
    fi
}

main() {
    while true; do
        to_exec

        if [[ "${count}" -eq "${number_of_hangs_to_exit}" ]]; then
            exit
        fi
    done
}

main "${@}"