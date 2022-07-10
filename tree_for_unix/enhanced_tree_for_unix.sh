#!/usr/bin/bash

#Emulated tree command for Solaris x86 systems V2.
#You can use this output for comparison with another output from a different machine in order to solve an issue.
#Made by Valentin Soare, contact info, email: soarevalentinn@gmail.com

declare counting_dirs
declare counting_files
declare USR

counting_dirs=0
counting_files=0
USR="$(id -un)"

print_header() {
    printf "\n%s" "current user: ${USR}"
    printf "\n%95s" " " | tr " " "-"
    printf "\n\033[1;31m%56s\033[0m" "UNIX - Tree Command"
    printf "\n%95s\n" " " | tr " " "-"
}

print_footer() {
    printf "%95s\n" " " | tr " " "-"
    printf "%s%76s \033[31m%s\033[0m\n%s%87s\n\n" "Directories: ${counting_dirs}" "Made with" "LOVE" "Files: ${counting_files}" "by Valentin S."
}

print_error() {
    print_header
    printf "\033[31m%s\033[0m\n" "ERROR: |--> we need a directory that exists as argument to print its hierarchy (folders and files).
       |--> Also user that executes the script need to be root or with sudoers privileges 
       |     to have access to all folders and files in order to execute ls and cd commands."
    print_footer
}

check_existance() {
    if [[ ! -e "${1}" ]]; then
        print_error
        exit
    fi
}

check_user() {
    if [[ "${USR}" != "root" ]]; then
        print_error
        exit
    fi
}

request_dir() {
    tab="${tab}${singletab}"

    for file in "${@}"; do
        echo -e "${tab}${file}"
        thisfile=${thisfile}/${file}

        if [ -d "${thisfile}" ]; then
            ((counting_dirs++))
            request_dir $(command ls ${thisfile})
        else
            ((counting_files++))
        fi

        thisfile="${thisfile%/*}"
    done

    tab=${tab%"$singletab"}
}

exec_ls() {
    singletab="|__"
    for tryfile in "${@}"; do
        printf "\033[1m%s\033[0m\n" "${tryfile}"
        if [ -d "${tryfile}" ]; then
            thisfile=${tryfile}
            request_dir $(command ls "${tryfile}")
        fi
    done
    unset dir singletab tab
}

main() {
    check_user
    check_existance "${@}"
    print_header
    exec_ls "${@}"
    print_footer
}

main "${@}"
