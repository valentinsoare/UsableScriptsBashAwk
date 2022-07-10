#!/usr/bin/bash

declare SAVE_POSITION
declare RESTORE_POSITION
declare HIDE_CURSOR
declare SHOW_CURSOR
declare -A list_of_colors

SAVE_POSITION="$(tput sc)"
RESTORE_POSITION="$(tput rc)"
HIDE_CURSOR="$(tput civis)"
SHOW_CURSOR="$(tput cnorm)"
list_of_colors=(["black"]="0" ["red"]="1" ["green"]="2" ["yellow"]="3" ["blue"]="4" ["purple"]="5"
                ["lightBlue"]="6" ["grey"]="8" ["orange"]="9" ["greenBold"]="10")

prepare_for_running() {
    local color_given="${1}"
    local percent="${2}"
    local sleep_time="${3}"
    local message_to_print="${4}"

    printf "%s" "${HIDE_CURSOR}"
    tput setaf "${list_of_colors[$color_given]}"

    while [[ "${percent}" -le 100 ]]; do
        printf "%s" "${SAVE_POSITION}"
        printf "%5s" " ${message_to_print}...[${percent}%] "
        
        if [[ "${percent}" -ne 100 ]]; then
            printf "%s" "${RESTORE_POSITION}"
        fi

        sleep "${sleep_time}"
        ((percent++))
    done

    trap 'kill $!' SIGTERM
}

end_running() {
    local type_of_end
    type_of_end="${1}"
    sleep 0.1
    echo -e "${type_of_end}"
    sleep 0.6
    
    tput cud1
    printf "%s" "${SHOW_CURSOR}"
}

banner_color() {
    local edge
    local msg="${3} ${1} ${3}"
    local color_given="${2}"
    edge=$(printf "%40s" " " | tr " " "${3}")

    tput setaf "${list_of_colors[$color_given]}"
    printf "\n%s\n%31s\n%s\n\n" "${edge}" "${msg}" "${edge}"
    tput sgr 0
    sleep 0.1
}