#!/usr/bin/bash

declare -a array_with_options array_with_messages 
declare time_to_wait how_many_rounds j

array_with_options=('/' '-' '\' '|')
array_with_messages=("Loading..." "Executing..." "Opening in progress...")
time_to_wait=0
how_many_rounds=3
j=0

with_percent() {

    for ((i=0; i<"${how_many_rounds}"; i++)); do
        [[ ${j} -gt "3" ]] && { j=0; }
        tput sc

        printf "\033[1;32m%s\033[0m \033[1;32m%s\033[0m \033[1;32m%s\033[0m" " progress:" "${array_with_options[j]}" "[ ${time_to_wait}% ]"
        
        sleep 0.1
        tput rc
        ((j++))

    done
}

with_messages() {
    local msg

    for ((i=0; i<"${how_many_rounds}"; i++)); do
        [[ ${j} -gt "3" ]] && { j=0; }
        tput sc
        printf "\033[1;32m%s\033[0m \033[1;32m%s\033[0m" " loading files:" "[ ${array_with_options[j]} ]"
        
        if [[ ${time_to_wait} -le "15" ]]; then
            msg="${array_with_messages[0]}"
        elif [[ ${time_to_wait} -le "45" ]]; then  
            msg="${array_with_messages[1]}"        
        else
            msg="${array_with_messages[2]}"        
        fi

        printf "\033[1;32m%s\033[0m" " [ ${msg} ]"
        sleep 0.1
        tput el
        tput rc
        ((j++))
    done
}

main() {

    tput civis
    printf "\n"
    
    while [[ "${time_to_wait}" -le "50" ]]; do 
        with_percent    # two optins available here: 2 functions, with_messages or with_percent - > self-explanatory
        ((time_to_wait++))
        if [[ "${time_to_wait}" -gt "50" ]]; then
            tput el
            printf "\033[1;32m%s\033[0m \033[1;32m%s\033[0m" " progress" "[ COMPLETED ]"
        fi
    done

    tput cnorm
    printf "\n\n"
}

main
