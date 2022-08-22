#!/usr/bin/bash

count=1
number_of_hangs_to_exit="${1}"
logging_location="${2}"
if_using_logging=0
file_for_output="freezes.out"


control_c() {
    printf "\n   %s\n\n" "**Script was ended by the user..."
    exit 0
}

sanity_checks() {
    if [[ -z "${number_of_hangs_to_exit}" ]]; then
        number_of_hangs_to_exit=30                       # number of hangs default to catch in case there is no input parameter
    fi
}

to_exec() {
    start="$(date +%s)"
    sleep 1
    sleep 3     # simulate hang 3 seconds. You need to remove this line in production.
    end="$(date +%s)"

    if [[ $((end - start)) -gt 1 ]]; then
        printf "  %s" "$(date -ud @${start})"
        printf "\n    %s\n" "(${count}) freeze duration: $((end - start - 1)) seconds"
        printf "  %s\n\n" "$(date -ud @${end})"
        printf "%35s\n\n" " " | tr ' ' '-'
        ((count++))
    fi
}

use_logging() {
    if [[ -n "${logging_location}" ]]; then 
        if [[ -d "${logging_location}" ]]; then
            if_using_logging=1
        else
            printf "\n%35s\n" " " | tr ' ' '-'
            printf "\n%s\n\n" "  **Output directory doesn't exists."
            printf "%35s\n\n" " " | tr ' ' '-'
            exit 1
        fi
    fi
}


execute_script() {
    trap "" SIGTSTP
    trap control_c SIGINT

    sanity_checks
    
    printf "\n%25s" "**FREEZE CATCHER**"
    
    if [[ "${if_using_logging}" -eq 1 ]]; then
        printf "\n%25s\n%26s\n" "logging location:" "${logging_location}/${file_for_output}"
    else
        printf "\n%24s\n" "output to screen"
    fi

    printf "%20s\n" "reps: ${number_of_hangs_to_exit}"
    printf "\n%35s\n\n" " " | tr ' ' '-'
    
    while true; do
        to_exec

        if [[ "${count}" -eq "${number_of_hangs_to_exit}" ]]; then
            printf "  %s\n\n" "**Script completed..."
            exit 0
        fi
    done
}


main() {
    use_logging "${@}"
    complete_path="${logging_location}/${file_for_output}"

    if [[ "${if_using_logging}" -eq 1 ]]; then
        if [[ -e "${complete_path}" ]]; then
            execute_script "${@}" | tee -a "${complete_path}"
        else
            execute_script "${@}" | tee "${complete_path}"  
        fi
    else
        execute_script "${@}"
    fi
}


main "${@}"
