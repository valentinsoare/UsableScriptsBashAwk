#!/usr/bin/bash

declare -A converting_references
declare input_file invisible_cursor normal_cursor location_for_the_given_file

input_file="${1}"
time_to_sleep="${2}"

invisible_cursor=$(tput civis)
normal_cursor=$(tput cnorm)

# you need to add more characters to this dictionary.
converting_references=([%2A]="*" [%2B]='+' [%2C]=',' [%2D]='-' [%2E]='.' [%2F]='/' [%3A]=':' [%3B]=';' [%3C]='<' [%3D]='=' [%3E]='>' [%3F]='?')

# Check if valid arguments were given when the script was lunched. If not, an error will appear.
check_arguments() {
    if [[ ${#} -ne 2 || -z "${time_to_sleep}" ]]; then
        printf "\n%s%s\n" " ERROR - you need to use two arguments for this script. 
        First is the file and second is the how many seconds to wait betwheen progress dots" "${normal_cursor}"
        exit 1
    fi
}

#header with namee of the script and current date, hour
printing_header() {                                                       
    local msg 
    local edge
    
    msg="|         ${1}         |"
    edge=$(printf "%s" "${msg}" | awk 'gsub(".","-",$0)')
    
    printf "\n %s\n" "${edge}"
    printf "%s\n %s\n" " ${msg}" "|      $(date "+%X %x")      |"
    printf " %s\n\n" "${edge}"
}

# if you will close the script before it finishes, then exiting message will appear.
# ths function is used along with trap command to catch "CTRL C"
catch_control_c() {                                                                                      
    printf "\n\n%s\n\n" " **Exiting..."                                                                   
    printf "%s" "${normal_cursor}"
    exit 1
}

main() {
    trap "" SIGTSTP
    trap catch_control_c SIGINT
    
    printf "%s" "${invisible_cursor}"

    printing_header "URL decoder v0.1"
    check_arguments "${@}"

}

main "${@}"
