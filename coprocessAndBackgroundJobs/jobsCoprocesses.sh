#!/usr/bin/bash

declare input_command="${1}"

running() {
    coproc mainProc (
        read -r input; 
        ping "${input}" -c 10; 
    )

    coproc secondProc ( 
        to_input="localhost" 

        printf "%s\n" "${to_input}" >& "${mainProc[1]}";

        while read -r line; do
            printf "%s\n" "${line}"
        done <& "${mainProc[0]}" 
    )

    coproc final (
        i=0

        while read -r line; do
            printf "${i}.\t%s\n" "${line}"
            ((i++))
        done <& "${secondProc[0]}"
    )

    command_to_execute() {
        local command_for_exec
        command_for_exec="${1}"

        eval "${command_for_exec}" &
    }
    
    command_to_execute "${input_command}"

    for ((wait_time=0; wait_time<=6; wait_time++)); do
        
        if [[ "${wait_time}" -eq 5 ]]; then
            printf "\n\n"
            while read -r lines; do
                printf "%s\n" "${lines}"
            done <& "${final[0]}"
        fi

        sleep 1
    done
}

running 2> /dev/null