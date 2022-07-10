#!/usr/bin/bash

declare time_to_wait commands_for_exec

commands_for_exec="${*}"
time_to_wait="8"
invisible_cursor="$(tput civis)"
normal_cursor="$(tput cnorm)"

printing_header() {

    #declare measuring_height 
    declare desired_text_hostname desired_text_user desired_text_groups exec_date \
            catch_uid catch_groups_id catch_hostname catch_date space_right size_dates \
            measuring_width

    desired_text_hostname="Hostname: "
    desired_text_user="User: "
    desired_text_groups="Groups: "
    exec_date="Local time: "
    command_info="${time_to_wait} seconds interval: "
    catch_uid="$(id | cut -f1 -d " " | grep -E -o  "[[:digit:]].*")"
    catch_groups_id="$(id | cut -f3 -d " " | grep -E -o "[[:digit:]].*")"
    catch_hostname="$(hostname)"
    catch_date="$(date "+%D %X")"
    #measuring_height="$(tput lines)"
    measuring_width="$(tput cols)"

    size_dates=$((${#exec_date} + ${#catch_date}))
    size_commands=$((${#commands_for_exec} + ${#command_info}))

    if [[ "${size_dates}" -ge "${size_commands}" ]]; then
        space_right=$((measuring_width - size_dates))
    else
        space_right=$((measuring_width - size_commands))
    fi

    clear
    printf "\033[38;5;70m%s\033[0m%s" "${desired_text_user}" "${catch_uid}"

    tput cup "0" "${space_right}"
    echo -e "$(tput setaf 1)${desired_text_hostname}$(tput sgr0)${catch_hostname}"

    printf "\033[38;5;70m%s\033[0m%s\n" "${desired_text_groups}" "${catch_groups_id}"

    tput cup "1" "${space_right}"
    echo -e "$(tput setaf 2)${exec_date}$(tput sgr0)${catch_date}"
      
    tput cup "2" "${space_right}"
    echo -e "$(tput setaf 3)${command_info}$(tput sgr0)${commands_for_exec}\n"
}

display_error() {
    printing_header
    printf "\033[31m%s\033[0m\n" "*ERROR - issues with given command(s), please check further. Proper input: ./enw.sh command name or a flow of commands using pipes or &&, but in this case you need to use double quotes for given command. Example: ./enw.sh ip route, ./enw.sh \"ip -c route | grep -E 'default'\", ./enw.sh \"ip route && ip addr show\"."
    printf "%s\n" "${normal_cursor}"
    exit
}

checking_command_availability() {
    if [[ -z "${commands_for_exec}" ]]; then
        display_error
    elif ! eval "${commands_for_exec}" >& /dev/null ; then
        display_error
    fi
}
    
execute_commands() {
    oldIFS="${IFS}"

    IFS=$'&&'
        
    for i in ${commands_for_exec[*]}; do
        if [[ -z ${i} ]]; then
            continue
        fi

        printf "\n\033[1;31m[\033[0m %s \033[1;31m]\033[0m\n\n" "${i# }"
        eval "${i}"
    done

    IFS="${oldIFS}"
}

main() {
    printf "%s\n" "${invisible_cursor}"
    
    checking_command_availability

    while true; do
        printing_header   

        execute_commands

        printf "\n\033[38;5;172m%110s\033[0m\n" " " | tr " " "-"
        read -r -t "${time_to_wait}" -p "*Session is ongoing. If you want to exit or continue with another print, please type q/quit or c/continue. 
**Also you can wait ${time_to_wait} seconds for the new output -> " answer

        answer="${answer,,}"

        if [[ -z "${answer:0:1}" || "${answer:0:1}" == "c" ]]; then
            continue
        elif [[ "${answer:0:1}" == "q" ]]; then
            printf "\n\033[31m%s\033[0m\n\n" "**Quiting.."
            sleep 0.5 
            printf "%s" "${normal_cursor}"
            exit
        else
            printf "\n\033[31m%s\033[0m\n" "**Wrong answer, only q/quit or c/continue."
            sleep 0.5
        fi
                            
    done

    printf "%s\n" "${normal_cursor}"
}
                                    
main
