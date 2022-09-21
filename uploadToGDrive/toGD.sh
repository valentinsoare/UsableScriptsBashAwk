#!/usr/bin/bash

# { echo > /dev/tcp/moviesondemand.io/221 && echo "Port Open"; } 2> /dev/null || echo "Port Closed"

location_to_upload="${1}"            # what you want to archive and then upload
location_for_storage="${2}"          # where you want to store the archive

name_of_the_archive="SavedDocuments"
file_full_path="${location_for_storage}${name_of_the_archive}.tar.xz"

print_header() {
    name_of_app="##### Google-Drive Uploader #####"
    bar="$(printf "\n#%31s#\n" " " | tr ' ' '-')"
    
    nr_of_columns="$(tput cols)"
    where_to_put=$(((nr_of_columns - ${#bar}) / 5))
    location_for_name=$(((nr_of_columns - ${#name_of_app}) / 5))

    clear
    tput cup 2 ${where_to_put}
    printf "\033[1;32m%s" ""
    echo ${bar}

    tput cup 3 ${location_for_name}
    echo ${name_of_app}

    tput cup 4 ${where_to_put}
    echo ${bar}
    printf "%s\033[0m" ""
    echo -e "\n"
}

check_if_apps_installed() {
    to_check_apps=('rclone' 'xz')
    #dnf whatprovides "*/rclone" | awk '{print $1}' | grep -E -i -v "last|repo|matched|filename|provide|^$" | uniq | grep -E -i "rclone"
}

check_if_archive_exists() {
    if [[ -e "${file_full_path}" ]]; then
        rm - f "${file_full_path}"
    fi
}

main() {
    print_header
    #check_if_archive_exists
}

main
