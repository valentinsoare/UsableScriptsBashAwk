#!/usr/bin/bash

declare initial_content_form
declare multiplePhrases
declare -a onePhrase
declare final_text

initial_content_form=${1}

generateFormatedText() {
    local input_lines="${1}"
    input_lines="$(awk '!/^$/' "${1}")"

    while read -r line; do
        printf "%s" "${line}" | awk '{gsub(/[[:space:]]{2,}/," "); print $0}'
    done <<< "${input_lines}"
}

printingText() {
    local toPrint="${1}"

    while read -r line; do
        onePhrase+=("${line}")
    done <<< "${toPrint}"

    for i in "${!onePhrase[@]}"; do
        printf "%s " "${onePhrase[i]}"
    done

    printf "\n"
}

logging() {
    given_content_before="${1}"
    given_content_after="${2}"

    if [[ ! -d /var/log/onePhrase ]]; then
        mkdir -p /var/log/onePhrase
    elif [[ ! -e /var/log/onePhrase/execPhrase.log ]]; then
        touch /var/log/onePhrase/execPhrase.log
    fi

    printf "%29s%s%29s\n\n" " " "BEFORE CONVERSION" " " | tr ' ' '-' >> /var/log/onePhrase/execPhrase.log
    
    while read -r line; do
        printf "%s\t\t%s\n" "$(date)" "${line}" >> /var/log/onePhrase/execPhrase.log
    done < "${given_content_before}"

    { printf "%29s%s%29s\n" " " "AFTER CONVERSION" " " | tr ' ' '-'; printf "$(date)\t\t%s\n" "${given_content_after}";
     printf "%75s\n" " " | tr ' ' '-'; } >> /var/log/onePhrase/execPhrase.log 
}

multiplePhrases="$(generateFormatedText "${initial_content_form}")"
final_text=$(printingText "${multiplePhrases}")
printf "%s\n" "${final_text}"
logging "${initial_content_form}" "${final_text}"