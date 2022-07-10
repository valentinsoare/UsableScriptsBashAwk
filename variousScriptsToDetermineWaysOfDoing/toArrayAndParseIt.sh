#!/usr/bin/bash

declare -a network_interfaces
declare -a processed_interfaces
declare -a interfaces_with_traffic

prepare_network_interfaces() {
    network_interfaces=(/sys/class/net/*)

    for i in ${network_interfaces[*]}; do
        processed_interfaces+=("${i##*/}")
    done
}

active_interfaces_with_traffic() {
    oldIFS="${IFS}"
    IFS=$'\n'
    interfaces_with_traffic+=("$(oldIFS="${IFS}"; IFS=$'\n'; ip addr show | grep -E "state UP" | cut -f2 -d ":" | xargs; IFS="${oldIFS}")")
}

IPs_for_active_interf() {
    local cmd
    printf "\033[1m%s\033[0m\n" "**IPs V4 on Active Interfaces:"
    printf "%40s\n" " " | tr ' ' '-'
    for interf in ${interfaces_with_traffic[*]}; do
        cmd="$(ip -c addr show "${interf}" | grep -E -A1 "global")"
        printf "\033[1m%8s:\033[0m\n%s\n\n" "${interf}" "${cmd}"
    done
}

stats_on_active_interfaces() {
    local cmd
    printf "\033[1m%s\033[0m\n" "***STATS on Active Interfaces:"
    printf "%40s\n" " " | tr ' ' '-'
    for k in ${interfaces_with_traffic[*]}; do
        cmd="$(ip -s -c link show "${k}")"
        printf "\033[1m%s\033[0m\n" "${cmd}"
    done
}

all_interfaces() {
    local exec_command
    printf "\033[1m%s\033[0m\n" "*ALL Network Interfaces on this Machine:"
    printf "%40s\n" " " | tr ' ' '-'
    for i in ${processed_interfaces[*]}; do
        exec_command="$(ip -c addr show "${i}")"
        printf "%s\n\n" "${exec_command}"
    done
}

main() {
    prepare_network_interfaces
    active_interfaces_with_traffic
    printf "\n"
    all_interfaces
    sleep 1
    IPs_for_active_interf
    sleep 1
    stats_on_active_interfaces
    printf "\n"
}

main