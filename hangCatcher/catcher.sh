#!/usr/bin/bash

to_exec() {
    count=0

    start="$(date +%s)"
    sleep 2
    sleep 20
    end="$(date +%s)"

    if [[ $((end - start)) -gt 2 ]]; then
        printf "%s\n" "${start}"
        printf "\n\033[1;31m %s\033[0m\n\n" "(${count}) HANG time: $((end - start))"
        printf "%s\n" "${end}"
        ((count++))
    fi
}

main() {
    while true; do
        to_exec
    done
}

main