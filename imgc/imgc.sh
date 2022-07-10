#!/usr/bin/bash

declare -a filename=("$@")

checkingSw() {
    if ! cmdChk="$(yum list installed ImageMagick 2> /dev/null)"; then
        printf "%s\n\n" "Software (ImageMagick) used for image processing is not istalled. We gonna install it."
        yum install ImageMagick -y 2> /dev/null
        printf "%60s\n" " " | tr ' ' '-'
        printf "%s\n" "${cmdChk}"
        printf "%60s\n" " " | tr ' ' '-'
    fi
}

converting() {
   local desired_extension="$1"

    if [[ ! ${#desired_extension} -ne 3 ]]; then
        printf "\n\e[1;31m%s\e[0m\n\n" "ERROR - You need to mentioned a desired extension for output."
        exit 1
    fi

   printf "%60s\n" " " | tr ' ' '-'
   
   for ((i=2;i<${#filename[@]};i++)); do
        extension="${filename[i]#*.}"
        output_name="${filename[i]%.*}"

        if [[ "${extension}" == "${desired_extension}" ]]; then
            printf "\n\e[1;31m%s\e[0m\n\n" "*Image is already in ${desired_extension} format."
        else
            convert "${filename[i]}" "${output_name}.${desired_extension}"
            printf "\e[1;32m%s\e[0m\n" "*${filename[i]} converted to ${output_name}.${desired_extension}"
        fi
    done
    printf "%60s\n" " " | tr ' ' '-'
}

identifiying() {
    printf "%60s\n" " " | tr ' ' '-'
    for ((i=1;i<${#filename[@]};i++)) {
        printf "\e[32m%s\e[0m\n" "$(identify "${filename[i]}")"
    }
    printf "%60s\n" " " | tr ' ' '-'
}

main() {
    local usage="Usage: $0 [-i] [-c extension] imagefiles"
    checkingSw
    while getopts ":ic:" option_given; do
        case "${option_given}" in
            i)  identifiying
                ;;
            c)  converting "${OPTARG}"
                ;;     
            \?) printf "\n\e[1;31m%s\e[0m\n\n" "${usage}"
                exit 1
                ;;
        esac
    done
}

main "$@"