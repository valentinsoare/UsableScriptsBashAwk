#!/usr/bin/bash

declare -a resources  needed_resources \
        resources_to_check array_for_sorting

input_arguments="${*}"
resources=("pid" "user" "%cpu" "%mem" "rss" "vsz" "time")
array_for_sorting=("%cpu" "%mem" "rss" "vsz" "time")
nr_of_cmds=1

catch_control_c() {
    printf "\n\n\033[1;31m%s\033[0m\n\n" " **Exiting..."
    tput cnorm
}

display_header() {
    user_message="User: "
    groups_message="Groups: "
    show_user="$(whoami)"
    display_groups="$(id | cut -f3 -d " " | grep -E -o "[[:digit:]].*")"
    current_date=$(date "+%c")
    local_date="Date: "
    our_uptime="Uptime: "
    find_uptime="$(uptime -p)"
    number_of_columns="$(tput cols)"

    up_size="$((${#our_uptime} + ${#find_uptime}))"
    date_size="$((${#current_date} + ${#local_date}))"

    if [[ "${date_size}" -ge "${up_size}" ]]; then
        our_space=$((number_of_columns - date_size))
    else
        our_space=$((number_of_columns - up_size))
    fi

    tput civis

    clear
    printf "\033[38;5;70m%s\033[0m%s" "${user_message}" "${show_user}"
    
    tput cup 0 "${our_space}"
    printf "\033[38;5;70m%s\033[0m%s\n" "Hostname: " "${HOSTNAME}"

    printf "\033[38;5;70m%s\033[0m%s" "${groups_message}" "${display_groups}"

    tput cup 1 "${our_space}"
    printf "\033[38;5;70m%s\033[0m%s\n" "${local_date}" "${current_date}"

    tput cup 2 "${our_space}"
    printf "\033[38;5;70m%s\033[0m%s\n" "${our_uptime}" "${find_uptime}"
}   

show_error() {
    printf "\033[31m%s\n\n%s\n%s\033[0m\n\n" "*ERROR - Issues with given command, please check further" \
    "How to execute the script: ./chckResources cpu mem rss vsz time- > You need to use at least one of these arguments." \
    "Also if you want to terminate the script sooner, you can use ctrl + c."
    tput cnorm
    exit 1
}

allocate_arguments() {
    for ((i=0; i < ${#input_arguments}; i++)); do
        needed_resources+=( ${input_arguments[$i]} )
    done
}

check_arguments() {
    count=0
    for i in "${needed_resources[@]}"; do  
        if [[ ${i} == "cpu" || ${i} == "mem" ]]; then
            resources_to_check+=( "%${i}" ) 
        elif [[ "${resources[*]}" =~ ${i} ]]; then
            resources_to_check+=( "${i}" )
        fi
        ((count++))
    done
}

to_default_for_resources() {
    if [[ "${count}" -eq 0 ]]; then
        resources_to_check=("${resources[@]}")
    fi
}

check_sanity() {
    if [[ "${#needed_resources[@]}" -gt 7 ]]; then
        show_error
    else
        check_arguments
        to_default_for_resources
    fi
}

#prstat -mL -n "$(ps -ef | wc -l)"" -c 1 1 | ggrep -E -i -v "usr" | sort -k3 -n | ggrep -E -i -v "prstat|grep|sort" | tail -20 | ggrep -v "tail"
#prstat -s rss -c -n 50 1 1 | head -30
#prstat -s rss -c -v -n 20 1 1

print_ps(){
    to_sort_by="${1}"
    value_to_sort="${2}"

    printf "\n\033[31m[\033[0m %s \033[31m]\033[0m\n\n" "- > top 10 sorted by ${to_sort_by}"
    variable_to_print="$(ps -eo "${resources_to_check[*]}")"
    printf "%s\n" "${variable_to_print}" | head -1
    printf "%s\n" "${variable_to_print}" | grep -i -v "${to_sort_by}" | sort -k"${value_to_sort}" -n | tail -10
}

loading_print_ps() {

    printf "\n\n\033[31m(${nr_of_cmds})\033[0m %s \033[31m\033[0m\n\n" "ps -eo ${resources_to_check[*]}" 

    for ((i=0; i<${#resources_to_check[@]}; i++)); do
        if [[ "${array_for_sorting[*]}" =~ ${resources_to_check[$i]} ]]; then
            print_ps "${resources_to_check[$i]}" "$((i + 1))"
        fi
    done

}

main() {
    trap "" SIGTSTP  # ignore ctrl + z
    trap catch_control_c SIGINT  # catch ctrl + c if you want to exit the script sooner

    allocate_arguments
    display_header
    check_sanity
    
    loading_print_ps

    tput cnorm
    echo -e ""
}

main "${@}"