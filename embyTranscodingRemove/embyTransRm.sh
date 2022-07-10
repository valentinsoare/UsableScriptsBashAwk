#!/bin/bash

SERVER="${1}"
USR="${2}"
PASSWORD="${3}"

checkConnForIssues() {
    SERVER="${1}"
    USR="${2}"
    PASSWORD="${3}"

    if ! host -W 1 "${SERVER}" > /dev/null 2>&1; then
        printf "\n\e[1;31m%s\e[0m\n\n" "ERROR - domain \"${SERVER}\" doesn't exists."
        return 1
    else
        if ! sshpass -p "${PASSWORD}" ssh -o ConnectTimeout=1 -o StrictHostKeyChecking=no \
                -q "${USR}"@"${SERVER}" 'exit' > /dev/null 2>&1; then
            printf "\n\e[1;31m%s\e[0m\n\n" "ERROR - ssh connection to ${SERVER} is not possible."
            return 1
        fi
    fi 
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

endProgress_dots() {
    local printed_message="${1}"
    kill "${!}"
    wait "${!}" 2> /dev/null
    sleep 0.1
    printf "\e[1m%s\e[0m\n" "DONE"
    sleep 0.5
    printf "%s\n" "${printed_message}"
}

runOnRemote() {

sshpass -p "${PASSWORD}" ssh -o ConnectTimeout=1 -o StrictHostKeyChecking=no -q "${USR}@${SERVER}" << EOF
    LOCATION="/var/lib/emby/transcoding-temp"
    EXECUTION=\$(du -sh "\${LOCATION}" 2> /dev/null | grep -E '\<[0-9]{1,}G\>' | cut -f 1 -d "G")
    COMMAND=\$(echo -e "\${EXECUTION} >= 2" | bc -l 2> /dev/null)
    linux_family=\$(awk -F "=" '/ID_LIKE/{print \$2}' /etc/*release | grep -Eio -e "rhel" -e "debian")
    linux_distro=\$(awk -F "=" '/PRETTY_NAME/{print \$2}' /etc/*release | head -n 1 | awk -F "\"" '{print \$2}')

    getDistro() {
        printf "\n\e[1mHost:\e[0m \e[1;31m%s\e[0m\n" "${SERVER}"

        if [[ "\${linux_family}" == "rhel" ]]; then
            printf "\e[1mLinux family:\e[0m \e[1;31m%s\e[0m\n" "Red Hat"
        elif [[ "\${linux_family}" == "debian" ]]; then
            printf "\e[1mLinux family:\e[0m \e[1;31m%s\e[0m\n" "Debian"
        fi

        printf "\e[1mLinux distribution:\e[0m \e[1;31m%s\e[0m\n" "\${linux_distro}" 
    }

    main() {
        if [[ "\${COMMAND}" -eq 1 ]]; then
            local INITIAL_SIZE=\$(du -sh "\${LOCATION}" | awk '{print \$1}')
            printf "\n* Initial size for Emby temp: %s" "\${INITIAL_SIZE}"
            printf "%s\n" "${PASSWORD}" | sudo -S rm -rf "\${LOCATION}" 2> /dev/null
            printf "\n\e[1m\n** Status:\e[0m %s\n" "Emby temp files were deleted"
        else
            printf "\n%s\n" "* Files are not larger than 2 GB."
            local CURRENT_SIZE=\$(du -sh "\${LOCATION}" 2> /dev/null | awk '{print \$1}')  
            printf "\n** Current size for Emby temp: %s\n\n" "\${CURRENT_SIZE}"
        fi
    }

    checkAvailability() {
        reqInfo() {
            code_Avlb="\${1}"
            if [[ ! -d "\${LOCATION}" ]] && [[ "\${code_Avlb}" -ne 0 ]] ; then
                printf "\n\e[1;31m%s\n\e[0m" "ERROR - Emby server package is not installed in given host."
                exit
            fi
        }

        if [[ "\${linux_family}" == "debian" ]]; then
            checkValue=\$(dpkg -l emby-server)
            reqInfo \${?}
        elif [[ "\${linux_family}" == "rhel" ]]; then
            checkValue=\$(rpm -q emby-server)
            reqInfo \${?}
        fi    
    }

    getDistro
    checkAvailability
    main
    unset USR
    unset PASSWORD
EOF
}

progress_dots "0.2" "." "Removing Emby temp files from ${SERVER}" &

if ! executed_checkConnection=$(checkConnForIssues "${SERVER}" "${USR}" "${PASSWORD}"); then
    endProgress_dots "${executed_checkConnection}"
else
    executed_function="$(runOnRemote)"
    endProgress_dots "${executed_function}"
fi
unset USR
unset PASSWORD