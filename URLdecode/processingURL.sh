#!/usr/bin/bash

declare -A converting_references
declare input_file invisible_cursor normal_cursor location_for_the_given_file number_of_lines

input_file="${1}"
time_to_sleep="${2}"
normal_cursor=$(tput cnorm)
invisible_cursor=$(tput civis)

# you need to add more characters to this dictionary.
converting_references=([%2A]="*" [%2B]='+' [%2C]=',' [%2D]='-' [%2E]='.' [%2F]='/' [%3A]=':' [%3B]=';' [%3C]='<' [%3D]='=' [%3E]='>' [%3F]='?')

info_about_file_and_time() {
    number_of_lines="$(wc -l "${input_file}" | cut -f1 -d " ")"

    if [[ ${number_of_lines} -le 0 ]]; then
        echo -en "\U26D4"
        printf "\033[31m%s\033[0m%s%s\n" " ERROR" " You need to use a file with at least one line in it." "${normal_cursor}"
        exit 1
    fi

    if [[ -z "${time_to_sleep}" || ! "${time_to_sleep}" =~ ^([[:digit:]]{1,}||[[:digit:]]{1,}\.[[:digit:]]{1,})$ ]]; then
        wait_period_from_file
    fi

    printf "%s%s\n%s%s\n\n" " file: ${input_file}" ", number of lines: ${number_of_lines}" " sleep time:" " ${time_to_sleep} second(s)" 
}

# check the number of lines from the file and set the waiting period between dots
wait_period_from_file() {
    if [[ ${number_of_lines} -ge 1000 ]]; then
        time_to_sleep=1
    elif [[ ${number_of_lines} -ge 700 ]]; then
        time_to_sleep=0.7
    elif [[ ${number_of_lines} -ge 400 ]]; then
        time_to_sleep=0.5
    else
        time_to_sleep=0.3
    fi
}

# Check if valid arguments were given when the script was lunched. If not, an error will appear. Also here we set the wait period from the numbeer of fils.
check_arguments() {
  
    if [[ ${#} -lt 1 ]]; then
        echo -en "\U26D4"
        printf "\033[31m%s\033[0m%s\n%s\n" " ERROR" '   You need to use two arguments for this script.
           First is the file with urls and the next is how many seconds to wait beetween progress dots. 

           Now if the second argument is not given or is not a number, then script will set wait time to a specific value
           taking into consideration the number of lines in the given file.' "${normal_cursor}"
        exit 1
    fi

    info_about_file_and_time
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

progress_dots() {
    local sleepTime="${1}"
    local typeP="${2}"
    local message="${3}"
    
    echo -en  " \U1FA9B ${message}"

    while true; do
        printf "%s" "${typeP}"
        sleep "${sleepTime}"
    done

    trap 'kill $!' SIGTERM
}

ending_dots() {               
    { kill "${!}"; wait "${!}"; } 2> /dev/null
    sleep 0.2
    printf "%s\n" "DONE"
    sleep 0.2
}

main() {
    trap "" SIGTSTP
    trap catch_control_c SIGINT
    
    printf "%s" "${invisible_cursor}"

    printing_header "URL decoder v0.1"
    check_arguments "${@}"

    progress_dots "${time_to_sleep}" "." " Executing" &
    sleep 3
    ending_dots
    tput cnorm
}

#echo -e "\U2705"        - check
# echo -e "\U26D4"      - failed

main "${@}"
