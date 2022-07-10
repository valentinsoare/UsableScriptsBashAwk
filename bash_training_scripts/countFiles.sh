#!/usr/bin/bash

main() {
    count=0
    printf "\n%s\n\n" " *We have the following shell scripts: "
    sleep 1

    while read -r line; do
        if [[ "${line}" == *\.sh ]]; then
            printf "%s\n" "${line}"
            ((count++))
        fi
    done <<< "$(ls -lhaR | awk '{print $NF}' | tail -n +2)"    # or find . -type f -name '*.sh' :D

    sleep 1 
    printf "\n%s" " **Number of shell scripts: "
    sleep 1
    printf "%s\n\n" "${count}"
}

main
