#!/usr/bin/env bash

j=0
dot="."
hash="#"
declare -A position

checking() {
    if [[ "${#}" -eq 1 ]] && [[ "${1}" =~ [[:digit:]]{1,} && ! "${1}" =~ [[:alpha:]]{1,} ]]; then
        time="${1}"
    elif [[ "${#}" -eq 2 ]]; then
        if [[ "${1}" =~ [[:alpha:]]{1,} ]] && [[ ("${2}" =~ [[:digit:]]{1,} && ! "${2}" =~ [[:alpha:]]{1,}) ]]; then
            message=" [ ${1} ] " 
            time="${2}"
        elif [[ "${2}" =~ [[:alpha:]]{1,} ]] && [[ ("${1}" =~ [[:digit:]]{1,} && ! "${1}" =~ [[:alpha:]]{1,}) ]]; then
            message=" [ ${2} ]" 
            time="${1}"
        else
            printf "\n\e[31m%s\e[0m\n" "ERROR - we need a message and a number which represents time to wait during progress. Or only time to wait during progress."
            printf "%s" "${SHOW_CURSOR}"
            exit
        fi
    else
        printf "\e[31m%s\e[0m\n\n" "ERROR - we can run this script with one or two arguments only. A message and a number which represents time to sleep on current progress, or only time."
        printf "%s" "${SHOW_CURSOR}"
        exit  
    fi
}             

cursorPosition() {
    local position
    IFS='[;' read -p $'\e[6n' -d R -a position -rs
    printf "%s\n" "${position[1]} ${position[2]}"
}

cursor_placement() {
    local width
    local height
    local needed_height
    local needed_width
    local length_of_progress_output
    
    length_of_progress_output="${1}"
    width=$(tput cols)
    height=$(tput lines)
    needed_height=$((height / 2))
    needed_width=$(((width - length_of_progress_output) / 2))
    tput cup ${needed_height} ${needed_width}
}

displayProgress() {
    cursor_placement 57

    printf "%s" " Progress: ["
    position[begin_line]=$(($(cursorPosition | cut -f 1 -d " ")-1))
    position[begin_column]=$(($(cursorPosition | cut -f 2 -d " ")-1)) 

    for ((i=1;i<=25;i++)); do
        printf "%s" "${dot}"
    done

    printf "%s" "]"
    [[ -n "${message}" ]] && { printf "%s" "${message}"; }

    position[afterBracket_line]=$(($(cursorPosition | cut -f 1 -d " ")-1))
    position[afterBracket_column]=$(cursorPosition | cut -f 2 -d " ")
    tput cup ${position[begin_line]} ${position[begin_column]}

    while [[ "${j}" -le 100 ]]; do
        printf "%s" "${hash}" 
        position[progress_line]=$(($(cursorPosition | cut -f 1 -d " ")-1))
        position[progress_column]=$(($(cursorPosition | cut -f 2 -d " ")-1)) 
        printf "%4s" "${j}%"  
        tput cup ${position[progress_line]} ${position[progress_column]}
        sleep "${time}"
        ((j+=5))
    done

    tput cup ${position[afterBracket_line]} ${position[afterBracket_column]}
    printf "%s" "DONE"
}