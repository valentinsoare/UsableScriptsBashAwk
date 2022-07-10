#!/usr/bin/bash

coproc process_execution (
    read -r input_ip
    ping "${input_ip}" -c 10
)

coproc execution (
    read -r input_destination
    ping "${input_destination}" -c 50
)

printf "%s\n" "192.168.122.232" >& "${process_execution[1]}"
printf "%s\n" "192.168.122.231" >& "${execution[1]}"

ping google.ro -c 20 &

while read -r line; do
    printf "%s\n" "${line}"
done <& "${process_execution[0]}" &

to_print="$(while read -r var; do
    printf "%s\n" "${var}"
done <& "${execution[0]}")"

printf "%s" "${to_print}"
