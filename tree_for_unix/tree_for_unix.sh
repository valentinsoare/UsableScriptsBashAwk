#!/usr/bin/bash

#emulated tree command for Solaris x86 systems V1.
#You can use this output for comparison with another output from a different machine in order to solve an issue.
#made by Valentin Soare, email: soarevalentinn@gmail.com

declare type_of_content
declare location
declare command
declare counting_elements
declare -x type_of_element

location="${1}"
type_of_content="${2}"
command="$(find "${location}" -type "${type_of_content}" -print 2> /dev/null | sed -e 's;[^/]*/;|____;g;s;____|; |;g')"
type_of_element=""

printing_error() {
        printf "\n\033[1;31m%110s\033[0m\n" " " | tr " " "-"
        printf "\033[1;31m%s\033[0m\n" "  ERROR - two arguments needed. 
          First one is the location where to search, see the hierarchy, 
          and the second one is what type to search, like files [f] or directories [d]. 
          Example: /simulating_tree.sh /etc f or /simulating_tree.sh /etc d"
        printf "\033[1;31m%110s\033[0m\n\n" " " | tr " " "-"
}

determine_type() {

        if [[ "${type_of_content}" == "d" ]]; then
            type_of_element="directories"
            counting_elements="$(find "${location}" -type "${type_of_content}" 2> /dev/null | tail -n +2 | wc -l)"
        elif [[ "${type_of_content}" == "f" ]]; then
            type_of_element="files"
            counting_elements="$(find "${location}" -type "${type_of_content}" 2> /dev/null | wc -l)"
        fi
}

health_checks() {
        [[ "${#}" != "2" || ! -e "${location}" || ("${type_of_content}" != "d" && "${type_of_content}" != "f") ]] \
        && { printing_error; exit; }
}

printing_header() {
        printf "\n\033[32m%s\033[0m" "treeForUnix"
        printf "\n%35s\n" " " | tr " " "-"
        printf "\033[32m%s\033[0m" "DIRECTORY for SEARCHING: ${location} "
        printf "\n%35s\n" " " | tr " " "-"
}


printing_footer() {
        if [[ "${counting_elements}" -eq "0" ]]; then
                printf "\033[31m%s\033[0m" " No ${type_of_element} found in ${location}"
                printf "\n%30s\n\n" " " | tr " " "-"
        else
                printf "\n%30s\n" " " | tr " " "-"
                printf "%s\n\n" "Number of ${type_of_element}: ${counting_elements}"
        fi
}

main() {
        determine_type
        health_checks "${@}"
        printing_header
        [[ "${counting_elements}" -ne "0" ]] && { printf "%s" "${command}"; }
        printing_footer           
}

main "${@}"