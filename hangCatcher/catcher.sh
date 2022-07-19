#!/usr/bin/bash

to_exec() {
    count=0

    start="$(date +%s)"
    sleep 2
    sleep 5
    end="$(date +%s)"

    if [[ $((end - start)) -gt 2 ]]; then
        printf "%s\n" "$(date -ud @${start})"
        printf "\n\033[1;31m %s\033[0m\n\n" "(${count}) HANG time: $((end - start))"
        printf "%s\n" "$(date -ud @${end})"
        ((count++))
    fi
}

main() {
    while true; do
        to_exec
    done
}

main