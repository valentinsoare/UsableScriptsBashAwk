#!/usr/bin/bash

declare -a elements
usage="$0 [-k KEY (UID)] [-v (USER)] input"
declare -a input_keysOrValues=("$@")

pupulateUIDandVALUES() {
    for i in $(awk 'BEGIN {FS=":"} {print $1":"$3}' /etc/passwd) ; do
       elements[${i#*:}]=${i%:*}
    done
}

getValueAndKeys() {
    local given_input="${1}"
    local counting=0
    local -a error_array

    for ((j=1;j<${#input_keysOrValues[@]};j++)); do
        counting=0
        for i in "${!elements[@]}"; do
            if [[ ${given_input} == "k" && ${input_keysOrValues[j]} == "${i}" ]]; then
                    printf "\e[1;32m%s \e[1;34m%s\e[0m \e[1;33m%s\e[0m\n" "${i}" "->" "${elements[i]}"
            elif [[ ${given_input} == "v" && ${input_keysOrValues[j]} == "${elements[i]}" ]]; then
                    printf "\e[1;32m%s\e[0m \e[1;34m%s\e[0m \e[1;33m%s\e[0m\n" "${i}" "->" "${elements[i]}"
            else
                ((counting++))        
            fi        
        done

        if [[ ${counting} -eq ${#elements[@]} ]]; then
            error_array+=("${input_keysOrValues[j]}")
        fi
    done

    if [[ ${#input_keysOrValues[@]} -gt 0 ]]; then
          for ((k=0;k<${#error_array[@]};k++)); do
                printf "\e[1;31mERROR %s %s\e[0m\n" "[ ${error_array[k]} ]" "not found"
          done
    else
        printf "\e[1;31m\nERROR %s\e[0m\n\n" "${usage}"        
    fi
}

checkValidityKeysAndValues() {
    local count=0
    local opt="$1"

    for ((i=1;i<${#input_keysOrValues[@]};i++)); do
        if [[ ! "${input_keysOrValues[i]}" =~ [0-9]{1,} && ${opt} == "k" ]]; then
            ((count++))
        elif [[ ! "${input_keysOrValues[i]}" =~ [a-z]{1,} && ${opt} == "v" ]]; then
            ((count++))
        fi    
    done

    if [[ ${count} -ne 0 ]]; then
        printf "\e[1;31m%s\e[0m\n" "ERROR -> ${usage}"
        printf "%30s\n" " " | tr ' ' '-'
        exit 1
    fi
}

main() {
    pupulateUIDandVALUES
    while getopts ":kv" option; do
        case "${option}" in
            k)  checkValidityKeysAndValues "k"
                getValueAndKeys "k"
               ;;
            v)  checkValidityKeysAndValues "v" 
                getValueAndKeys "v"
               ;;   
            \?) printf "\e[1;31m%s\e[0m\n" "ERROR ${usage}"
                printf "%30s\n" " " | tr ' ' '-'
                exit 1
        esac
    done
}

printf "%30s\n" " " | tr ' ' '-'
main "$@"
printf "%30s\n" " " | tr ' ' '-'