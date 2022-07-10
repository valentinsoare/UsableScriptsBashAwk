#!/bin/bash

declare -a rsync_options=("rsync_client" "rsync_full_access")
declare -A position
dot="."
hash="#"
j=1
SERVER=${1}
USR="${2}"
PASSWORD="${3}"
SOURCE_BACKUP="${4}"
DESTINATION_BACKUP="${5}"
HIDE_CURSOR=$(tput civis)
SHOW_CURSOR=$(tput cnorm)

checking() {
    if [[ "${#}" -eq 1 ]] && [[ "${1}" =~ [[:digit:]]{1,} && ! "${1}" =~ [[:alpha:]]{1,} ]]; then
        time=$1
    elif [[ $# -eq 2 ]]; then
        if [[ "${1}" =~ [[:alpha:]]{1,} ]] && [[ ("${2}" =~ [[:digit:]]{1,} && ! "${2}" =~ [[:alpha:]]{1,}) ]]; then
            message=" [ ${1} ]" 
            time=$2
        elif [[ "${2}" =~ [[:alpha:]]{1,} ]] && [[ ("${1}" =~ [[:digit:]]{1,} && ! "${1}" =~ [[:alpha:]]{1,}) ]]; then
            message=" [ ${2} ]" 
            time="${1}"
        fi     
    fi
}             

cursorPosition() {
    local position
    IFS='[;' read -p $'\e[6n' -d R -a position -rs
    printf "%s\n" "${position[1]} ${position[2]}"
}

displayProgress() {
    printf "%s" "  Progress: ["
    position[begin_line]=$(($(cursorPosition | cut -f 1 -d " ")-1)); position[begin_column]=$(($(cursorPosition | cut -f 2 -d " ")-1)) 

    for ((i=1;i<=25;i++)); do
        printf "%s" "${dot}"
    done

    printf "%s" "]"; [[ -n "${message}" ]] && { printf "%s" "${message}"; }

    position[afterBracket_line]=$(($(cursorPosition | cut -f 1 -d " ")-1)); position[afterBracket_column]=$(cursorPosition | cut -f 2 -d " ")
    tput cup ${position[begin_line]} ${position[begin_column]}

    while [[ "${j}" -le 20 ]]; do
        printf "%s" "${hash}"; position[progress_line]=$(($(cursorPosition | cut -f 1 -d " ")-1)); position[progress_column]=$(($(cursorPosition | cut -f 2 -d " ")-1)); 
        printf " %s" "$((j*5))%"  
        tput cup ${position[progress_line]} ${position[progress_column]}
        sleep "${time}"
        ((j++))
    done

    tput cup ${position[afterBracket_line]} ${position[afterBracket_column]}
    printf "%s\n" "DONE"
}

progress_dots() {
    local sleepTime="${1}"
    local typeP="${2}"
    local message="${3}"
    printf "\n\e[1m %s\e[0m" "${message}"
    while true; do
        printf "\e[1m%s\e[0m" "${typeP}"
        sleep "${sleepTime}"
    done
    trap 'kill $!' SIGTERM
}

checkConnForIssues() {
    SERVER="${1}"
    USR="${2}"
    PASSWORD="${3}"

    if ! host -W 1 "${SERVER}" > /dev/null 2>&1; then
        printf "\n\e[1;31m%s\e[0m\n" "ERROR - domain \"${SERVER}\" doesn't exists."
        return 1
    else        
        if ! sshpass -p "${PASSWORD}" ssh -o ConnectTimeout=1 -o StrictHostKeyChecking=no \
                -q "${USR}"@"${SERVER}" 'exit' > /dev/null 2>&1; then
            printf "\n\e[1;31m%s\e[0m\n" "ERROR - ssh connection to ${SERVER} is not possible."
            return 1
        fi
    fi 
}

checkSecRsync() {
    printf "\n\e[1m%s\e[0m\n" "Rsync status: "
    for i in "${!rsync_options[@]}"; do
        checkRsync="$(getsebool "${rsync_options[$i]}" | awk -F "> " '{print $2}')"
        sleep 0.5
        if [[ "${checkRsync}" == "off" ]]; then
            printf "*%s: \e[31m%s\e[0m\n" "${rsync_options[$i]}" "disabled"
            setsebool "${rsync_options[$i]}" 1
            sleep 0.5
            printf "%s -> \e[32m%s\e[0m\n" "---${rsync_options[$i]}" "activated"
        else
            printf "%s -> \e[32m%s\e[0m\n" "${rsync_options[$i]}" "enabled"
        fi
    done
}

printing_lines() {
    local number="${1}"
    local sleepingTime="${2}"
    printf "%${number}s" " " | tr " " "-"
    if [[ -n "${sleepingTime}" ]]; then
        sleep "${sleepingTime}"
    fi
}

uploadBackup() {
        if ! main_command=$(sshpass -p "${PASSWORD}" rsync -u --stats -e 'ssh -o StrictHostKeyChecking=no' -r -p \
                "${SOURCE_BACKUP}" "${USR}@${SERVER}:${DESTINATION_BACKUP}" --delete-before 2> /dev/null) ; then
            output_stats="$(printf "\n\e[31m%s\e[0m" "**ERROR - Exporting failed due to ssh/rsync issues.")"
        else
            output_stats="${main_command}"
        fi
}

printOutput() {
    printf "\n\e[1m%s\e[0m%s\n" "****${SERVER}****" "${output_stats}"
    printing_lines "55" "0.5"
}

main() {
    if ! checkConnForIssues "${SERVER}" "${USR}" "${PASSWORD}"; then
        return 1
    fi    
    printf "\n\e[1mDestination:\e[0m %s\n\n\e[1mUser:\e[0m %s\n" "${SERVER}" "${USR}"
    checkSecRsync 2> /dev/null
    progress_dots "0.5" "." " Exporting scripts" &
    uploadBackup
    kill "${!}"; wait "${!}" 2> /dev/null; sleep 0.5
    printf "\e[1m%s\e[0m\n\n" "DONE"
    printf "\e[1m%s\e[0m\n" "OUTPUT RESULTS:"; sleep 0.5
    transfer_var=$(printOutput)
    printf "%s" "${transfer_var}"
    printf "**$(date)\n SOURCE FILE/FOLDER: ${SOURCE_BACKUP}\n REMOTE DESTINATION FILE/FOLDER: ${DESTINATION_BACKUP}\n%s\n"
             "${transfer_var}" >> /var/log/backupIsEasy/easyBackup.log
    printf "\n%s\n" "SCRIPT COMPLETED!"
}

logging_backup_info() {
    [[ ! -d /var/log/backupIsEasy ]] && { mkdir -p /var/log/backupIsEasy; }
    [[ ! -e /var/log/backupIsEasy ]] && { touch /var/log/backupIsEasy/easyBackup.log; }
}

printf "%s\n" "${HIDE_CURSOR}"
logging_backup_info
checking "Script loading.." "0.1"
displayProgress
main
printf "%s\n" "${SHOW_CURSOR}"
unset USR
unset PASSWORD