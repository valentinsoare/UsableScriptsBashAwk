#!/usr/bin/bash

coproc aiurea (
    read -r line
    ping "${line}" -c 5
)

printf "%s\n" "localhost" >& "${aiurea[1]}"


deSefi=$(while read -r our_output <& "${aiurea[0]}"; do
    printf "%s\n" "${our_output}"
done)

printf "\n\n%s\n\n" "${deSefi}"