#!/bin/bash

if [[ ${1} == "-r" ]]; then
    remote_server="$2"
    USER="${3}"
    PASSWORD="${4}"

    checkConnForIssues() {
        SERVER="${1}"
        USR="${2}"
        PASSWORD="${3}"

        if ! host -W 1 "${SERVER}" > /dev/null 2>&1; then
            printf "\n\e[1;31m%s\e[0m\n\n" "ERROR - domain \"${SERVER}\" doesn't exists."
            exit
        else
            if ! sshpass -p "${PASSWORD}" ssh -o ConnectTimeout=1 -o StrictHostKeyChecking=no \
                     -q "${USR}"@"${SERVER}" 'exit' > /dev/null 2>&1; then
                printf "\n\e[1;31m%s\e[0m\n\n" "ERROR - ssh connection to ${SERVER} is not possible."
                exit
            fi
        fi 
    }

    checkConnForIssues "${remote_server}" "${USER}" "${PASSWORD}"

        sshpass -p "${PASSWORD}" ssh -o ConnectTimeout=1 -o StrictHostKeyChecking=no -q "${USER}"@"${remote_server}" << EOF

        linux_family=\$(awk -F "=" '/ID_LIKE/{print \$2}' /etc/*release | grep -Eio -e "rhel" -e "debian")
        linux_distro=\$(awk -F "=" '/PRETTY_NAME/{print \$2}' /etc/*release | head -n 1 | awk -F "\"" '{print \$2}')

        printLines() {
            for ((i=1; i<=\$1; i++)); do
                printf "%s" "-"
            done
            printf "\n"
        }

        getDistro() {
            printf "\e[1mHost:\e[0m \e[1;31m%s\e[0m\n" "${remote_server}"

            if [[ \${linux_family} == "rhel" ]]; then
                printf "\e[1mLinux family:\e[0m \e[1;31m%s\e[0m\n" "Red Hat"
            elif [[ \${linux_family} == "debian" ]]; then
                printf "\e[1mLinux family:\e[0m \e[1;31m%s\e[0m\n" "Debian"
            fi

            printf "\e[1mLinux distribution:\e[0m \e[1;31m%s\e[0m\n" "\${linux_distro}" 
        }

        updatingOS() {
            printf "\n\e[1m%s\e[0m\n" "UPDATING and CLEANING:"

            printLines 80

            if [[ "\${linux_family}" == "rhel" ]]; then
                printf "%s\n" "${PASSWORD}" | sudo -S yum update -y && sudo -S yum upgrade -y && sudo -S yum clean packages -y
            elif [[ "\${linux_family}" == "debian" ]]; then
                printf "%s\n" "${PASSWORD}" | sudo -S apt-get update -y && sudo -S apt-get upgrade -y && \ 
                sudo -S apt-get dist-upgrade -y && sudo -S apt-get autoremove -y
            fi 2> /dev/null    
        }

        getDistro
        updatingOS

        printLines 80
        unset USER
        unset PASSWORD
EOF

    unset USER
    unset PASSWORD

elif [[ "${1}" == "-l" ]]; then
    HIDE_CURSOR=$(tput civis)
    SHOW_CURSOR=$(tput cnorm)

    input1=$(printf "%s" "${2}" | tr '[:upper:]' '[:lower:]') 

    print_error() {
        local message_input="${1}"
        printf "\n\e[38;5;196m%s\e[0m\n\n" "$message_input"
    }

    check_input() {
        if [[ (-n "${input1}") && (("${input1}" != "-s") && ("${input1}" != "--show")) ]]; then
            print_error "**Issues with input argument - (-s or -show needed or no arguments)"; return 1;
        elif [[ $(whoami) != "root" ]]; then
            print_error "**You need to be root to run this script."; return 1;
        fi
    }

    upgrades() {
        printf "\e[1m%s\n\e[0m" " * yum update"
        yum update -y

        printf "\e[1m\n%s\n\e[0m" " ** yum upgrade" 
        yum upgrade -y

        printf "\n\e[1m%s\n\e[0m" " *** yum clean packages"
        yum clean packages -y
    }

    progress_dots() {
        local sleepTime="${1}"
        local typeP="${2}"
        local message="${3}"
        printf "\n\e[1m %s\e[0m" "${message}"
        while true; do
            printf "\e[1m%s\e[0m" "${typeP}"
            sleep "${sleepTime}"
        done
        trap 'kill $!' SIGTERM
    }

    main() {
 
         printf "%s" "${HIDE_CURSOR}"
    
        check_input

        if [[ "${?}" -ne 0 ]]; then
            return 1;
        fi

        progress_dots "0.5" "." " Executing updates" &
        var=$(upgrades)

        if [[ (-n "${input1}") && (("${input1}" == "--show") || ("${input1}" == "-s")) ]]; then
            printf "\e[1m%s\e[0m\n\n" "DONE"; kill $!; sleep 1;
            printf "%s\n\n" "${var}"
        else
            printf "\e[1m%s\e[0m\n\n" "DONE"; kill "${!}"; sleep 1;
        fi 2> /dev/null
    
        sleep 0.5
        printf "\e[1m %s\e[0m\n" " COMPLETED!!"
        printf "%s\n" "${SHOW_CURSOR}"
    }

    main
else
    printf "\n\e[1;31m%s\e[0m\n\n" "We need one argument for remote and local and then the necessary info. 
Options: -r for remote or -l for local. 
Example: -> for local: ./shortUpdate -l -s|--show -> If -l is mentioned is local and with -s or --show we can see the update and remove of junk process. 
                        Also on local we can update with only -l without details only progress bar.
         -> for remote: ./shortUpdate -r server user password ->updating the server mentioned."
fi