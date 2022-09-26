#!/usr/bin/bash

declare -A converting_references
declare input_file invisible_cursor normal_cursor number_of_lines location_file where_to_read

input_file="${1}"
time_to_sleep="${2}"
normal_cursor=$(tput cnorm)
invisible_cursor=$(tput civis)

# You need to add more characters to this dictionary.
converting_references=([%2A]="*" [%2B]='+' [%2C]=',' [%2D]='-' [%2E]='.' [%2F]='/' [%3A]=':' [%3B]=';' [%3C]='<' [%3D]='=' [%3E]='>' [%3F]='?')

# Search for the file and print entire path if found and 1 if it is not.
locate_the_file() {
    location_file="$(find / -regextype posix-extended -iregex ".*/${input_file}.*" 2> /dev/null)"
    
    if [[ -z "${location_file}" ]]; then
        printf "%s" "1"
    else
        printf "%s" "${location_file}"
    fi
}

# Check the number of lines in file and then if it is 0 print the errror message.
checking_nr_lines() {
    number_of_lines="$(wc -l "${where_to_read}" | cut -f1 -d " ")"
    
    if [[ ${number_of_lines} -le 0 ]]; then
        echo -en " \U26D4"
        printf "\033[31m%s\033[0m%s%s\n" " ERROR" " You need to use a file with at least one line in it." "${normal_cursor}"
    fi
}

# Print the messag if file is not found.
check_availibility() {
    if [[ "${where_to_read}" == "1" ]]; then
        echo -en " \n \U26D4"
        printf "\033[31m%s\033[0m%s%s\n\n" " ERROR" " Cannot find the file" "${normal_cursor}"
        exit 1
    fi
}

# check the number of lines from the file and set the waiting period between dots
wait_period_from_file() {
    if [[ ${number_of_lines} -ge 1000 ]]; then
        time_to_sleep=1
    elif [[ ${number_of_lines} -ge 700 ]]; then
        time_to_sleep=0.7
    else
        time_to_sleep=0.5
    fi
}

# Check if valid arguments were given when the script was lunched. If not, an error will appear. Also here we set the wait period from the numbeer of fils.
check_arguments() {
  
    if [[ ${#} -lt 1 ]]; then
        echo -en " \U26D4"
        printf "\033[31m%s\033[0m%s\n%s\n" " ERROR" '  You need to use two arguments for this script.
           First is the file with urls and the next is how many seconds to wait beetween progress dots. 

           Now if the second argument is not given or is not a number, then script will set wait time to a specific value
           taking into consideration the number of lines in the given file. If the file is not find, then' "${normal_cursor}"
        exit 1
    fi

    if [[ -z "${time_to_sleep}" || ! "${time_to_sleep}" =~ ^([[:digit:]]{1,}||[[:digit:]]{1,}\.[[:digit:]]{1,})$ ]]; then
        time_to_sleep=0.5
    fi
}

# Header with namee of the script and current date, hour
printing_header() {                                                       
    local msg 
    local edge

    msg="|         ${1}         |"
    edge=$(printf "%s" "${msg}" | awk 'gsub(".","-",$0)')
   
    printf "\n %s\n" "${edge}"
    printf "%s\n %s\n" " ${msg}" "|      $(date "+%X %x")      |"
    printf " %s\n\n" "${edge}"
}

# If you will close the script before it finishes, then exiting message will appear.
# This function is used along with trap command to catch "CTRL C"
catch_control_c() {                                                                                      
    printf "\n\n%s\n\n" " **Exiting..."                                                                   
    printf "%s" "${normal_cursor}"
    exit 1
}

# Make a backup of the initial file. In case already exists, then delete the backup and create another one.
make_bckp() {
    entire_path_file_to_backup="${where_to_read}"
    directory_for_backup="${entire_path_file_to_backup%/*}"
    only_file_name="${entire_path_file_to_backup##*/}"

    if [[ -e "${directory_for_backup}/backup_${only_file_name}" ]]; then
        rm -f "${directory_for_backup}/backup_${only_file_name}"
        cp "${entire_path_file_to_backup}" "${directory_for_backup}/backup_${only_file_name}"
    else
        cp "${entire_path_file_to_backup}" "${directory_for_backup}/backup_${only_file_name}"
    fi
    
    echo -en "\n \U2705"
    printf "%s\n%s\n\n" " Backup of the given file was made in parent directory." "    Location: ${directory_for_backup}/backup_${only_file_name}"
}

# Print dots whil all the magic happens in the background.
progress_dots() {
    local sleepTime="${1}"
    local typeP="${2}"
    local message="${3}"
    
    echo -n " ${message}"

    while true; do
        printf "%s" "${typeP}"
        sleep "${sleepTime}"
    done

    trap 'kill $!' SIGTERM
}

# Ending the background proceess and then print DONE.
ending_dots() {             
    { kill "${!}"; wait "${!}"; } 2> /dev/null
    sleep 0.2
    printf "%s\n" "DONE"
    sleep 0.2
}

# Main function where we call all the entire script logic,
main() {
    trap "" SIGTSTP
    trap catch_control_c SIGINT
    
    printf "%s" "${invisible_cursor}"

    printing_header "URL decoder v0.1"
    check_arguments "${@}"
    echo -en " \U1F50E"
    progress_dots "${time_to_sleep}" "." "Searching" &
    where_to_read="$(locate_the_file)"
    ending_dots
    check_availibility
    make_bckp

    checking_nr_lines
    wait_period_from_file
    echo -en " \U1FA9B"
    progress_dots "${time_to_sleep}" "." "Executing" &
    sleep 10
    ending_dots

    printf "%s" "${normal_cursor}"
}

main "${@}"
