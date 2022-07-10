#!/usr/bin/bash

declare message_type
declare to_execute
declare command_to_execute="${1}"
declare time_to_wait=1
source "$(dirname "${BASH_SOURCE[0]}")"/loaded_scripts/visualFeatures.sh

executing_tasks() {
    eval "${command_to_execute}"    
}

loading_tasks() {
    local progress_color="${1}"
    local percent_value="${2}"
    local sleep_between="${3}"
    local given_message="${4}"

    message_type="COMPLETED!"

    prepare_for_running "${progress_color}" "${percent_value}" "${sleep_between}" "${given_message}" &
    
    if ! to_execute="$(executing_tasks 2> /dev/null)"; then
        message_type="\033[31mFAILED!"
        to_execute="**Issues with input command, something went wrong. Please check!\033[0m"
    fi
    
    { kill "${!}"; wait "${!}"; } 2> /dev/null

    tput el
}

main() {
    local output_color="${1}"
    local before_exec
    local after_exec
    local variable_to_continue

    banner_color "Command Execution" "${output_color}" "-"

    before_exec="$(date +%s)"
    loading_tasks "${output_color}" "0" "${time_to_wait}" "**executing"
    after_exec="$(date +%s)"

    variable_to_continue=$(((after_exec - before_exec)/time_to_wait))
    prepare_for_running "${output_color}" "${variable_to_continue}" "0.02" "**executing"

    end_running "${message_type}"

    echo -e "${to_execute}\n"
    tput sgr 0
}

main "green"