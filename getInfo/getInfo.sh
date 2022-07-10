#!/usr/bin/bash

declare -a arrInput=("$@")

cnt() {
    local counting="${1}"
    
    if [[ ${counting} -eq "${#arrInput[@]}" ]]; then
        printf "\e[31m%s\e[0m\n\n" " All elements from input doesn't exists"
    elif [[ "${counting}" -gt 0 ]]; then
        printf "\e[31m%s\e[0m\n\n" " ${count} element(s) from input doesn't exists"
    elif [[ ${counting} -eq 0 ]]; then
        printf "\e[32m%s\e[0m\n\n" " All input elements are present."
    fi
}

checkingType() {
    local desired_file="${1}"

    if [[ -f "${desired_file}" ]]; then
        printf "%s" "[file] with permissions:"
    elif [[ -h "${desired_file}" ]]; then
        printf "%s" "[symlink] with permissions:"
    elif [[ -d "${desired_file}" ]]; then
        printf "%s" "[directory] with permissions:"
    else
        printf "%s" "[special type of file] with permissions:"
    fi
}

permissions() {
    local given="${1}"
    j=0

    while [[ "${j}" -le 2 ]]; do
        [[ -r "${given}" && "${j}" -eq 0 ]] && { printf "%s" " read;"; }
        [[ -w "${given}" && "${j}" -eq 1 ]] && { printf "%s" " write;"; }

        if [[ "${j}" -eq 2 ]]; then
            if [[ -x "${given}" ]]; then
                [[ -d "${given}" ]] && { printf "%s" " searchable;"; }
                [[ -f "${given}" || -h "${given}" ]] && { printf "%s" " exec;"; }
                [[ -h "${given}" || -h "${given}" ]] && { printf "%s" " exec;"; }
            fi
        fi
        ((j++))
    done

    chk="$(ls -ld "${given}")"
    ownr="$(printf "%s" "${chk}" | cut -f3 -d " ")"
    printf "%s" " Owner: ${ownr}" 
    printf "\n%s\n" "[ ${chk} ]"
}

main() {
    local count=0

    if [[ ${UID} -ne 0 ]]; then
        find_user=$(grep -E "${UID}" /etc/passwd | cut -f1 -d ":")
        printf "\n%s" "Script is running under ${find_user} login shell"
    else
        printf "\n%s" "Script is running under root"
    fi

    printf "\n%41s\n" " " | tr ' ' '-'
    printf "\e[1m\t%s\e[0m\n" " Checking input status"
    printf "%41s" " " | tr ' ' '-'

    for ((i=0;i<${#arrInput[@]};i++)); do
        if [[ ! -e ${arrInput[i]} ]]; then
            printf "\n\e[31m%s\e[0m %s %s\n" "✘" "${arrInput[i]}"  "doesn't exists"
            ((count++))
        else
            printf "\n\e[32m%s\e[0m %s %s" "✔" "${arrInput[i]}" "exists -> "
            checkingType "${arrInput[i]}"
            permissions "${arrInput[i]}"
        fi
    done

    printf "%41s\n" " " | tr ' ' '-'

    cnt "${count}"
}

main