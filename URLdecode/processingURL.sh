#!/usr/bin/bash

#######################################################################################################
# Script is made with a sole purpose of decoding URLs into ASCII characters, but only the end of URLs #                                           
# URL enecoding reference is taking from https://www.w3schools.com/tags/ref_urlencode.ASP             #                                                              
#######################################################################################################

declare -a list_with_keys list_with_values                            # lists declaration
declare input_file invisible_cursor normal_cursor number_of_lines directory_for_backup \
            location_file where_to_read characters_count only_file_name entire_path_file_to_backup # declaration of ariables available throughout the entire script

input_file="${1}"
time_to_sleep="${2}"                
normal_cursor=$(tput cnorm)                    # revert the cursor to normal
invisible_cursor=$(tput civis)                 # make the sript invisible
characters_count="None"

# You can add more characters to both lists. Please use this link - https://www.w3schools.com/tags/ref_urlencode.ASP - to see the encoding reference. 
list_with_keys=("%2A" "%2B" "%2C" "%2D" "%2E" "%2F" "%3A" "%3B" "%3C" "%3D" "%3E" "%3F")
list_with_values=('*' '+' ',' '-' '.' '/' ':' ';' '<' '=' '>' '?')

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
        #echo -en "\n \U26D4"
        printf "\033[31m%s\033[0m%s%s\n\n" " ERROR" " You need to use a file with at least one line in it." "${normal_cursor}"
        exit 1
    fi
}

# Print the messag if file is not found.
check_availibility() {
    if [[ "${where_to_read}" == "1" ]]; then
        #echo -en " \n \U26D4"
        printf "\n\033[31m%s\033[0m%s%s\n\n" " ERROR" " Cannot find the file" "${normal_cursor}"
        exit 1
    fi
}

# check the number of lines from the file and set the waiting period between dots
wait_period_from_file() {
    if [[ ${number_of_lines} -ge 2000 ]]; then
        time_to_sleep=2
    elif [[ ${number_of_lines} -ge 1000 ]]; then
        time_to_sleep=1
    elif [[ ${number_of_lines} -ge 700 ]]; then
        time_to_sleep=0.5
    else
        time_to_sleep=0.3
    fi
}

# Check if valid arguments were given when the script was lunched. If not, an error will appear. Also here we set the wait period from the numbeer of fils.
check_arguments() {
    if [[ ${#} -lt 1 ]]; then
        #echo -en " \U26D4"
        printf "\033[31m%s\033[0m%s\n%s\n" "    ERROR" '  You need to use two arguments for this script.
           First is the file with urls and the next is how many seconds to wait beetween progress dots. 

           Now if the second argument is not given or is not a number, then script will set wait time to a specific value
           taking into consideration the number of lines in the given file. If the file is not find, then an error will appear.
           URLs encoding reference from https://www.w3schools.com/tags/ref_urlencode.ASP. ' "${normal_cursor}"
        exit 1
    fi

    if [[ -z "${time_to_sleep}" || ! "${time_to_sleep}" =~ ^([[:digit:]]{1,}||[[:digit:]]{1,}\.[[:digit:]]{1,})$ ]]; then
        time_to_sleep=0.5       # time to sleep (0.3 seconds) between dots when searcing in case user doesn't give the second argument.
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
make_backup() {
    entire_path_file_to_backup="${where_to_read}"
    directory_for_backup="${entire_path_file_to_backup%/*}"
    only_file_name="${entire_path_file_to_backup##*/}"

    if [[ -e "${directory_for_backup}/backup_${only_file_name}" ]]; then
        rm -f "${directory_for_backup}/backup_${only_file_name}"
        cp "${entire_path_file_to_backup}" "${directory_for_backup}/backup_${only_file_name}"
    else
        cp "${entire_path_file_to_backup}" "${directory_for_backup}/backup_${only_file_name}"
    fi
    
    
    sleep 0.5
    #echo -en "\n \U2705"
    printf "\n - > %s\n%s\n" "Backup of the given file was made in parent directory." "     Location: ${directory_for_backup}/backup_${only_file_name}"
}

# Print dots whil all the magic happens in the background.
progress_dots() {
    local sleepTime="${1}"
    local typeP="${2}"
    local message="${3}"
    #local in_front="${4}"

    #if [[ ${in_front} -eq 0 ]]; then                   # this part was made for unicode characters, but on RHEL 7 servers saw that we do not have them. Script was made on Fedora 35.
    #    echo -en " \U1F50E"                            # where you will see '\U' you should know that I'm trying to print a unicode character.
    #else                                               # saw that I cannot print a unicode with printf, only with echo was working, but in Fedora.
    #    echo -en " \U1FA9B"
    #fi

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

# Printing None if no activit was done
action_when_no_activity_for_logs() {
    if [[ ${characters_count} -eq 0 ]]; then
        printf "%s" "None" >> "${directory_for_backup}"/url_processing.log
    fi
}

# Check if log file exists and if not, it will be created.
check_for_log_file() {
      if [[ ! -e ${directory_for_backup}/url_processing.log ]]; then
        touch "${directory_for_backup}"/url_processing.log
        printf "\n%s\n" " *How many lines we have and how many characters per each type we replaced: " >> "${directory_for_backup}"/url_processing.log
        printf "%100s\n" " " | tr ' ' '-' >> "${directory_for_backup}"/url_processing.log
    fi
}

# Execute the main task on the given file using the entire path and print the success message and create/populate logs. Where we have # at the end of the line in function
# that message will appear in logs. Also at the end of the script some messages will appear and are printed with this function.
execute_task_and_logging() {


    check_for_log_file

    printf "%s" " - > $(date)" >> "${directory_for_backup}"/url_processing.log                 

    length_of_list_keys="${#list_with_keys[@]}"

    printf "\n%s" " *To be replaced: " >> "${directory_for_backup}"/url_processing.log

    for ((j=0; j<length_of_list_keys; j++)); do
        if grep -q -i "${list_with_keys[j]}" "${where_to_read}"; then
            sed -i "s_${list_with_keys[j],,}_${list_with_keys[j]}_g" "${where_to_read}" 2> /dev/null
            ((characters_count++))
            printf "%s" "" " ${list_with_keys[j]} |" >> "${directory_for_backup}"/url_processing.log
        fi
    done

    action_when_no_activity_for_logs

    printf "\n%s" " **Characters that were converted: " >> "${directory_for_backup}"/url_processing.log

    for (( i=0; i<length_of_list_keys; i++ )); do
        value_count=$(grep -E -c -i "${list_with_keys[i]}" "${where_to_read}")
        if [[ ${value_count} -ne 0 ]]; then
            sed -i -e "s_${list_with_keys[i]}_${list_with_values[i]}_g" "${where_to_read}" 2> /dev/null
            printf "%s" " [${list_with_keys[i]}]=${value_count} |" >> "${directory_for_backup}"/url_processing.log
        fi
    done

    action_when_no_activity_for_logs

    printf "\n%s" " ***From file, lines: ${number_of_lines}, characters type replaced: ${characters_count}" >> "${directory_for_backup}"/url_processing.log
    printf "\n%100s\n" " " | tr ' ' '-' >> "${directory_for_backup}"/url_processing.log

    #echo -en "\n \U2705"
    printf "\n%s\n%118s\n\n" " - > All lines were processed with success." "Please access the file: ${where_to_read}"

    #echo -en " \U2705"
    printf "%s\n\n" " - > For logs see: ${directory_for_backup}/url_processing.log"
}

# Moving the cursor down in the terminal
moving_down_the_line() {
    input_value="${1}"

    for ((i=0; i<=input_value; i++)); do
        tput cud1
    done
}

# Main function where we call all the entire script logic.
main() {
    trap "" SIGTSTP                  # trap CTRL - Z and ignore it.
    trap catch_control_c SIGINT      # trap CTRL - C and exit the script printing exit message.
    printf "%s" "${invisible_cursor}"      # cursor will be invisible.

    clear                # when we execute the script the screen is cleared first then the script will run.

    printing_header "URL decoder v0.2"         # print the header 
    check_arguments "${@}"                     # sanity checks on given arguments when lunching the script
    
    tput sc               # save position.
    
    # Part where searching is executed.
    # Searching bar with dots and time to sleep is given by the user. 
    # This is run in the bg, but as you now if you print something from background will appear in foreground. 
    # And at the same time as you can see I search for the file
    progress_dots "${time_to_sleep}" "." "Searching" & # 0 was forth argument but now we have only three for this function due to mssing unicode on Pdck serveres                   
    sleep 3                                                              # # here this sleep is used in order to increase thee number of dots for executing phase. For effect.
    where_to_read="$(locate_the_file)"                                   # command substitution and execute the function "locate_the_file" and save the restu in variabl where_to_read
    ending_dots                                                          # here will end the progress with dots and this will happen after search is executed. We will kill the process from background
    check_availibility                                                   # if where_to_read will be 1 then file was not found and a message will appear and script will exit with code 1.
    checking_nr_lines                                                    # check the number of lines from a file. If there are no line an error will appear.
    make_backup                                                          # make a backup of the file with URLs
    wait_period_from_file                                                # determin time to sleep taking into consideration the number of lines from the file when "executing phase" is starting.
    
    tput rc               # restore position.
    tput el               # delete from the cursor to the end of the line.
    
    # Here we execute the main task. Like replace the end of each URL from the given file.
    progress_dots "${time_to_sleep}" "." "Executing" "1" &
    sleep 3                      # here this sleep is used in order to increase thee number of dots for executing phase. For effect.
    complete_main_task=$(execute_task_and_logging)                # use command substitution to execute the task and logging and store the output in a variable.
    ending_dots                                                   # after the task is completed progress bar will be complete with a DONE message.
    moving_down_the_line 2       # move down the cursor.          # this is to move down the cursor
    printf "%s" "${complete_main_task}"                           # to print the output of th main task that is stored in complete_main_task variable

    printf "%s\n\n" "${normal_cursor}"                            # restore the cursor to visible.
    sleep 0.5                                                          
}

# Execute main function.
main "${@}"
