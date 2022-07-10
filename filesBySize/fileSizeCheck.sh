#!/usr/bin/env bash

validationTargetAndQty() {
    [[ ! -e "${TARGET}" ]] && { printf "\n\e[1;31m%s\e[0m\n\n" "ERROR - Directory does not exists."; exit; }
    [[ ! ${NVALUE} =~ [[:digit:]]{1,} ]] || [[ "${NVALUE}" -lt 1 ]] && { printf "\n\e[1;31m%s\e[0m\n\n" "ERROR - We need at least one file to be extracted for size sorting. Example: maxSize X, where X is the number of files."; exit; }
}

if [[ "${1}" == "-r" ]]; then

    SERVER="${2}"
    USER="${3}"
    PASSWORD="${4}"
    TARGET="${5}"
    NVALUE="${6}"
    INV_CURSOR=$(tput civis)
    NRM_CURSOR=$(tput cnorm)

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

    main() {
        
        validationTargetAndQty

        sshpass -p "${PASSWORD}" ssh -o ConnectTimeout=1 -o StrictHostKeyChecking=no -q "${USER}"@"${SERVER}" 2> /dev/null << EOF

        showProgress() {
            printf "\n\e[1m%s\e[0m" "Searching: ["

            while true; do
                printf "\e[1m%s\e[0m" "#"
                sleep 0.5
            done

            trap 'kill $!' SIGTERM
        }

        printLines() {
            local number="\${1}"
            for ((i=0; i < number; i++)); do
                printf "\e[1;34m%s\e[0m" "-"
            done
        }

        findFiles() {
            #find "${TARGET}" -type f -print0 2> /dev/null | xargs -0 du -h 2> /dev/null | sort -h | tail -n "${NVALUE}" | awk -F " " '{print \$2}'
            find "${TARGET}" -type f -print0 2> /dev/null | xargs --null du -sh | sort -h -k1 | tail -n "${NVALUE}" | awk -F " " '{print \$2}'
        }

        displayFiles() {
            while read -r line; do
                ls -lh "\${line}" 2> /dev/null
                exit_value="\$?"
                
                if [[ "\${exit_value}" -ne 0 ]]; then 
                    printf "\e[1;31m%s\e[0m\n" "-error - Cannot access \${line}, location is a directory, size \$(du -sh \${line}* | cut -f 1 | head -n 1)"
                fi
            done < <(findFiles)
        }

        main() {
            printLines 80;

            printf "\n\e[1;44m%s\e[0m\n" "\${NVALUE} LARGEST FILE(S) IN [${TARGET}] FROM [${SERVER}]"
            showProgress & 

            var=\$(displayFiles)
            printf "\e[1m%s\e[0m\n\n" "] DONE"; kill \$!; wait \$! 2> /dev/null; sleep 0.5;

            printf "%s\n" "\${var}"
            printLines 80; printf "\n"
        }

        printf "%s\n" "${INV_CURSOR}"
        main
        printf "%s" "${NRM_CURSOR}"
        unset USER
        unset PASSWORD
EOF
    }

    if ! checkConnForIssues "${SERVER}" "${USER}" "${PASSWORD}"; then
        exit
    fi    
    
    main
    unset USER
    unset PASSWORD
elif [[ ${1} == "-l" ]]; then

    var=false
    TARGET="${2}"
    declare -x NVALUE="${3}"
    INV_CURSOR=$(tput civis)
    NRM_CURSOR=$(tput cnorm)

    validationTargetAndQty

    printing_lines() {
        local number="${1}"
        local sleepingTime="${2}"
        printf "%${number}s" " " | tr " " "-"
        if [[ -n "${sleepingTime}" ]]; then
            sleep "${sleepingTime}"
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

    findfiles() {
        #find "${TARGET}" -type f -print0 2> /dev/null | xargs -0 du -h 2> /dev/null | sort -h | tail -n "${NVALUE}" | awk -F " " '{print $2}'
        find "${TARGET}" -type f -print0 2> /dev/null | xargs --null du -sh | sort -h -k1 | tail -n "${NVALUE}" | awk -F " " '{print $2}'

    }

    showfiles() {
            while read -r line; do
                ls -lh "${line}" 2> /dev/null
                exit_value="$?"
                
                if [[ "${exit_value}" -ne 0 ]]; then 
                    printf "%s\n" "$(ls -ld ${line}*) -> location type: directory, size: $(du -sh ${line}* | cut -f 1)" || printf "\e[1;31m%s\e[0m\n" "-error - Cannot access ${line}"

                fi
            done < <(findfiles)
    }

    main() {

        printing_lines 80;

        while ! ${var}; do

            QUESTION="***You sure you want to find the largest ${NVALUE} file(s) in ${TARGET} ? [Y/n] "
            printf "\n\e[1;32m"; read -p "${QUESTION}" line; printf "\e[0m\n"

            input=$(printf "%s" "${line}" | tr "[:upper:]" "[:lower:]")

            if [[ "${input}" == "y" ]]; then
                printf "\e[1;41m%s\e[0m\n" "${NVALUE} LARGEST FILE(S) IN [${TARGET}]"
                progress_dots "0.5" "#" "Searching: [" & 
                var=$(showfiles)
                printf "\e[1m%s\e[0m\n\n" "] DONE"; kill $!; wait $! 2> /dev/null; sleep 0.5;
                printf "%s" "${var}"
                var=true
            elif [[ "${input}" == "n" || "${input}" == "quit" ]]; then    
                printf "\e[1;31m%s\e[0m\n" "EXITING..."
                var=true
            else 
                printf "\e[1;31m%s\e[0m\n" "WRONG ANSWER!!"
            fi 
        done

        printf "\n"; printing_lines 80; printf "\n"
    }

    printf "%s\n" "${INV_CURSOR}"
    main
    printf "%s" "${NRM_CURSOR}"
else
    printf "\n\e[1;31m%s\e[0m\n\n" "We need one argument for remote and local and then the necessary info. 
Options: -r for remote or -l for local. 
Example: -> for local: ./fileSizeCheck.sh -l / 5 -> largest 5 files in the whole root partition.
         -> for remote: ./fileSizeCheck.sh -r server user password / 5 -> largest 5 files from the whole root parition in remote server."
fi