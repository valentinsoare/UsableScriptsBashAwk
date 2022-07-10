#!/usr/bin/bash

declare hide_cursor show_cursor save_position restore_position command_given \
        time_to_sleep_between  number_of_loops qty_percent

hide_cursor="$(tput civis)"
show_cursor="$(tput cnorm)"
save_position="$(tput sc)"
restore_position="$(tput rc)"
command_given="${1}"
time_to_sleep_between="${2}"
number_of_loops="${3}"
qty_percent=0

printing_error() {
    printf "\n\033[1;31m%s\033[0m\n\n" "ERROR -> { As first argument you need to enter desired commands in double quotes and put a \";\" after
        each command; last one included. Also on second argument you need time to sleep between each sign repetition
        and third one contains number of repetitions for all four signs.
        Ex: ./newTypeLoading.sh \"ping localhost -c 5; ip route; ip addr show; \"0.25\" \"1\" -> if you need to cancel comands from input
        use CTRL+C and commands will be canceled and progress bar will move faster and exits after a few seconds. }"
    exit
}

define_env_checks() {
    local counter
    counter="$(printf "%s\n" "${command_given}" | grep -E -o ";" | wc -l)"

    if [[ "${#}" -ne 3 ]]; then
        printing_error
    elif [[ "${counter}" -eq 0 ]]; then
        printing_error
    fi
    
    trap '' SIGINT SIGTSTP
    exec 3> "$(dirname "${BASH_SOURCE[0]}")"/percenting; exec 4< "$(dirname "${BASH_SOURCE[0]}")"/percenting
}

print_sign() {
    local type_of_sign="${1}"

    printf "%s" "${restore_position}" 
    printf "%s" "${save_position}"
    printf "\033[1m%s%s %s%s\033[0m" "[" "${type_of_sign}" "${qty_percent}%" "]"
    printf "%s\n" "${qty_percent}" >&3
}

sign_loop() {
    local time_to_sleep
    local number_qty

    time_to_sleep="${1}"
    number_qty="${2}"

    for i in "${type_of_signs[@]}"; do
        print_sign "${i}"
        sleep "${time_to_sleep}"
    done

    ((number++))

    if [[ "${number}" -lt "${number_qty}" ]]; then
        sign_loop "${time_to_sleep}" "${number_qty}"
    else
        return 0
    fi
}

fnc_to_exec() {
    local i
    local oldIFS 
    
    i=1
    oldIFS="${IFS}"
    IFS=";"

    for i in ${command_given% }; do
        if output_command="$(eval "${i}" 2> /dev/null)"; then
            printf "\033[32m****Given-Command:%s\033[0m\n%s\n\n" " ${i# }" "${output_command}"
        else
            printf "\033[32m****Given-command:%s\033[0m\n\033[1;31m%s\033[0m\n\n" " ${i# }" " ->Task did not run as planned, errors were encountered."
        fi
    done

    IFS="${oldIFS}"
}

exec_loading() {
    local qty_sleep
    local qty_reps
    local -a type_of_signs
    local number

    qty_sleep="${1}"
    qty_reps="${2}"
    qty_percent="${3}"
    type_of_signs=("-" "\\" "|" "/")

    printf "%s\033[1m  %s\033[0m%s" "${hide_cursor}" "**loading " "${save_position}"

    while [[ "${qty_percent}" -le 100 ]]; do
        number=0
        sign_loop "${qty_sleep}" "${qty_reps}"
        ((qty_percent++))
    done

    printf "%s\033[1m%s\033[0m\033[1;32m%s\033[0m\033[1m%s\033[0m\n" "${restore_position}" "[" " completed " "]"
    printf "%s\n" "${show_cursor}"
}

print_output() {
    local line
    local error_colors
    local errors_encountered

    printf "%80s" " " | tr ' ' '-'
    printf "\n"
    errors_encountered=$(printf "%s\n" "${output_to_print}" | grep -o "planned" | wc -l)

    while read -r line; do
        printf "%s\n" "${line}"
        sleep 0.1
    done <<< "${output_to_print}"

    if [[ "${errors_encountered}" -eq 0 ]]; then
        error_colors="\033[32m"
    else
        error_colors="\033[31m"
    fi

    printf "%80s\n" " " | tr ' ' '-'
    printf "${error_colors}%s%s\033[0m\n\n" "[ Failed commands: " "${errors_encountered} ]"
    exec 3>&-; exec 4<&-; rm -f "$(dirname "${BASH_SOURCE[0]}")"/percenting
}

main() {
    local output_to_print
    local bg_process

    define_env_checks "${@}"

    printf "\n"
    exec_loading "${time_to_sleep_between}" "${number_of_loops}" "0" &
    bg_process="${!}"
    
    output_to_print="$(fnc_to_exec)"

    printf "\r"
    kill -15 "${bg_process}" 2> /dev/null

    time_to_continue_from="$(tail -n 1 "$(dirname "${BASH_SOURCE[0]}")"/percenting)"
    exec_loading "0.01" "1" "${time_to_continue_from}"

    sleep 0.6
    print_output
}

main "${@}"