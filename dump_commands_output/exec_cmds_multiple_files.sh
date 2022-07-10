#!/usr/bin/bash

declare time_to_sleep
declare -a commands_given
declare how_many

how_many="${1}"
time_to_sleep="${2}"
commands_given=("top -b -n 1 -o +TIME" "ip -s link")

welcome_message() {
    printf "\n\033[1;32m%s %s\033[0m\n" "    *The following commands will be executed ${how_many} times with ${time_to_sleep} seconds time to sleep between a series of commands." "
    **Output will be put in /tmp directory and each command will have a separate log files. Example: ./exec_cmds_multiple_files.sh 2 2"
    printf "\033[1;31m\t%s" "--->Commands:"

    for ((z=0; z<${#commands_given[@]}; z++)); do
        if [[ ${z} -eq $((${#commands_given[@]}-1)) ]]; then 
            printf "%s" " ${commands_given[z]}."
        else    
            printf "%s" " ${commands_given[z]},"
        fi
    done

    printf "\033[0m\n\n"
}

create_headers() {
    for ((k=0; k<${#commands_given[@]}; k++)); do
        processed_name=$(printf "%s\n" "${commands_given[k]}" | awk '{ gsub(/[[:blank:]]{1,}/, "_"); print $0 }')
        printf "\n %s \n" "${commands_given[k]}" >> /tmp/"${processed_name}.txt"
    done
}

output() {
    local i
    i="${1}"

    printf "\n%s" "[ $((j+1)) iteration ]"
    printf "\n%70s\n\n" " " | tr " " "-"
    eval "${i}"
}

printing() {
    for ((i=0; i<${#commands_given[@]}; i++)); do
        processed_name=$(printf "%s\n" "${commands_given[i]}" | awk '{ gsub(/[[:blank:]]{1,}/, "_"); print }')
        output "${commands_given[i]}" >> /tmp/"${processed_name}.txt"
    done
}

main() {
    local j
    j=0

    welcome_message
    create_headers "${@}"

    while [[ "${j}" -le "${how_many}" ]]; do
        printing "${@}"
        sleep "${time_to_sleep}"
        ((j++))
    done

    printf "\033[1;31m%s\033[0m\n\n" "COMPLETED!"
}

main "${@}" 
