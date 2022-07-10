#!/usr/bin/bash

declare -a commands
declare print_line generating_output USR GRP
declare log_folder number_of_passes sleep_time_between_commands options

define_input_variables() {
    #Needed commands will be defined in array bellow like we can see in this definition. This version of the script doesn't support
    #piping inside an element of this array, but can support linking commands with AND(&&) inside an element.
    
    commands=("ip -c route" "ip -c -s link")

    print_line="$(printf "%70s\n" " " | tr " " "-")"
    USR="$(id -un)"
    GRP="$(id -ng)"
    options="${1}"
    log_folder="${2}"
    number_of_passes="${3}"
    sleep_time_between_commands="${4}"
    number_of_arguments="${#}"
}

executing_health_checks() {
    
    if [[ "${number_of_arguments}" -ne "4" ]]; then
        printf "\n\033[1;31m%s\033[0m\n\n" "  ERROR - we need an option (-f or -b), a directory to generate the log in, with output from the commands given
          also a number of repetitions and a sleep time between passes. Exemple: ./execCmds -f /tmp 5 10"; exit
    elif [[ ! -d "${log_folder}" ]]; then
        printf "\n\033[1;31m%s\033[0m\n\n" "ERROR - directory \"${log_folder#*/}\" doesn't exists"; exit
    elif [[ ! "${sleep_time_between_commands}" -gt "0" ]]; then
        printf "\n\033[1;31m%s\033[0m\n\n" "ERROR - sleep time, fourth argument needs to be greater than 0"; exit
    elif [[ "${USR}" != "root" ]]; then
        printf "\n\033[1;31m%s\033[0m\n\n" "ERROR - issues encountered, you run this script as user \"${USR}\". You need to be root."; exit
    fi
}

executing_tasks() {
    for ((i=0; i<"${#commands[@]}"; i++)); do
        printf "%s\n" "${print_line}"
        printf "\n\033[1m\t[ %s ]\033[0m\n\n" "${commands[i]}"
        eval "${commands[i]}"
    done
}

create_output_log() {
     touch /"${log_folder}"/output_cmds.log 
     chown "${USR}":"${GRP}" /"${log_folder}"/output_cmds.log 
     chmod 440 /"${log_folder}"/output_cmds.log
}

content() {
    local i
    i=0

    while [[ "${i}" -lt "${number_of_passes}" ]]; do
        
        generating_output=$(executing_tasks)

        printf "%s\n" "${generating_output}"
        printf "%s\n" "${print_line}"
        printf "\033[42;1;1m%s" " Executing "
        printf "%s\033[0m\n\n\n" "$((i+1)) pass...DONE "
        
        if [[ $((i+1)) -eq "${number_of_passes}" ]]; then
            sleep 1
        else
            sleep "${sleep_time_between_commands}"
        fi

        ((i++))
    done
}

main() {

    define_input_variables "${@}"
    executing_health_checks
    create_output_log

    case "${options}" in
        "-f" | "--foreground")
            content "${@}" | tee -a /"${log_folder}"/output_cmds.log
            tput cuu1; tput el
            printf "\n\033[41;5;1m%s\033[0m\n\n" " COMPLETED! "
            ;;
        "-b" | "--background")
            printf "\033[1;32m\n%s\n\n\033[0m" " Given commands [${commands[*]}] will run in the background and a file will be created."
            content "${@}" >  /"${log_folder}"/output_cmds.log &
            ;;
        *)
            printf "\n\033[1;31m%s\033[0m\n\n" "ERROR - you need as first argument -f|--foreground or -b|--background"
            ;;
    esac
}

main "${@}"
