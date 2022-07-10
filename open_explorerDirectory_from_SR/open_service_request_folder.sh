#!/usr/bin/bash

target_SR="${1}"
default_term="${TERM}"
TERM="screen-256color"
export TERM
inv_cursor="$(tput civis)"
norm_cursor="$(tput cnorm)"
save_position="$(tput sc)"
restore_position="$(tput rc)"

printing_dots() {
    sleep_value="${1}"
    character_type="${2}"

    printf "\n\033[1;32m%s" " loading"

    while true; do
        printf "\033[1;32m%s" "${character_type}"
        sleep "${sleep_value}"
    done

    trap 'kill ${!}' SIGTERM
}

printing_signs() {
    time_to_wait="${1}"
    i="0"
    array_options=('/' '-' '\' '|')

    while true; do
        [[ ${i} -gt "3" ]] && { i=0; }
        printf "%s" "${save_position}"
        printf "\033[1;32m%s %s\033[0m" " loading:" "[ ${array_options[i]} ]"
        sleep "${time_to_wait}"
        printf "%s" "${restore_position}"
        ((i++))
    done

   trap 'kill ${!}' SIGTERM
}

exec_printing_signs() {
    printf "\n"
    printing_signs "0.2" &
    #findfile_command="$(findfile "${target_SR}" | tail -1 | awk 'BEGIN {FS=" "} {print $2}')"   # only for cores3 server Solaris
    findfile_command="${target_SR}"            # server Linux
    { kill "${!}"; wait "${!}"; } 2> /dev/null
    printf "%s" "${restore_position}"
    printf "\033[1;32m%s %s\n\n" " loading:" "[ completed ]"
    sleep "0.2"
    printf "%s\033[0m\n\n" " Opening right now!"
}

exec_printing_dots() {
    printing_dots "1" "." &
    #findfile_command="$(findfile "${target_SR}" | tail -1 | awk 'BEGIN {FS=" "} {print $2}')"    # only for cores3 server Solaris
    findfile_command="${target_SR}"        # server Linux
    { kill "${!}"; wait "${!}"; } 2> /dev/null
    printf "%s\n\n" "completed"
    sleep "0.2"
    printf "%s\033[0m\n\n" " Opening right now!"
}

main() {
    printf "%s" "${inv_cursor}"

    #First type of graphical output at the beginning while the findfile command is doing his work.
    exec_printing_signs

    #Second version like the one from above.
    #exec_printing_signs

    #Open the SR
    cd "${findfile_command}"

    printf "%s" "${norm_cursor}"

    TERM="${default_term}"
    export TERM
}

main "${@}" 2> /dev/null
