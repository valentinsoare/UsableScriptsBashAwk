#!/usr/bin/bash

declare input_file invisible_cursor normal_cursor location_for_the_given_file
declare -A converting_references

input_file="${1}"
converting_references=([%2A]="*" [%2B]="+" [%2C]="," [%2D]="-" [%2E]="." [%2F]='/')
invisible_cursor=$(tput civis)
normal_cursor=$(tput cnorm)

exec_find_location() {
    local location="${1}"
    to_find="$(find / -regextype posix-extended -iregex ".*/${location}.*" 2> /dev/null)"
    
    if [[ -z "${to_find}" ]]; then
        printf "%s" "1"
    else
        printf "%s" "${to_find}"
    fi
}

catch_control_c() {
    printf "\n\n%s\n\n" " **Exiting..."
    printf "%s" "${normal_cursor}"
    exit 1
}

printing_header() {
    local msg 
    local edge
    
    msg="|         ${1}         |"
    edge=$(printf "%s" "${msg}" | awk 'gsub(".","-",$0)')
    
    printf "\n %s\n" "${edge}"
    printf "%s\n %s\n" " ${msg}" "|      $(date "+%X %x")      |"
    printf " %s\n\n" "${edge}"
}

checking_arguments() {
    if [[ -z "${input_file}" ]]; then
        sleep 3
        printf "\n%s%s" " ERROR - You need to provide a valid file as an argument with a list of URLs to parse." "${normal_cursor}"
        exit 1
    fi
}

printing_dots() {
    sleep_value="${1}"
    character_type="${2}"

    printf "%s" " Executing"

    while true; do
        printf "%s" "${character_type}"
        sleep "${sleep_value}"
    done

    trap 'kill ${!}' SIGTERM
}

make_bckp() {
    entire_path_file_to_backup="${1}"
    directory_for_backup="${entire_path_file_to_backup%/*}"
    only_file_name="${entire_path_file_to_backup##*/}"

    if [[ -e "${directory_for_backup}/backup_${only_file_name}" ]]; then
        rm -f "${directory_for_backup}/backup_${only_file_name}"
        cp "${entire_path_file_to_backup}" "${directory_for_backup}/backup_${only_file_name}"
    else
        cp "${entire_path_file_to_backup}" "${directory_for_backup}/backup_${only_file_name}"
    fi
    
    printf "%s\n%s\n" "✔ Backup of the given file was made in parent directory." "Location: ${directory_for_backup}/backup_${only_file_name}"
}

execute_task() {
    for i in "${!converting_references[@]}"; do
        sed -i -e "s|${i}|${converting_references[$i]}|g" "${input_file}" 2> /dev/null
    done
}

main() {
    file_location="${1}"

    checking_arguments
    location_for_the_given_file=$(exec_find_location "${file_location}")

    if [[ "${location_for_the_given_file}" != "1" ]]; then
        make_bckp "${location_for_the_given_file}"
        execute_task
    else
        printf "%s" "1"
    fi
}

ending_dots() {               
    { kill "${!}"; wait "${!}"; } 2> /dev/null
    sleep 0.2
    printf "%s\n" "DONE"
    sleep 0.2
}

exec_main() {
    trap "" SIGTSTP
    trap catch_control_c SIGINT
    
    printf "%s" "${invisible_cursor}"

    printing_header "URL decoder v0.1"
    printing_dots "0.5" "." &
    output_from_main=$(main "${input_file}")
    ending_dots

    if [[ ${output_from_main} == "1" ]]; then
        printf "\n\n%s\n\n%s" " ERROR - given file was not found! Please try again." "${normal_cursor}"
        exit 1
    fi
    
    sleep 0.5
    printf "\n%s\n" "${output_from_main}"
    sleep 0.5
    printf "\n%s%s\n\n" "✔ Encoding completed! Check the file." "${normal_cursor}"
}

exec_main
