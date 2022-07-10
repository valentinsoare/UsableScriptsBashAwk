#!/usr/bin/bash

sanity_checks() {
   if [[ "${#}" -ne 1 || "${1}" -le 0 ]]; then
    printf "\n\033[1;31m%88s\033[0m" " " | tr ' ' '-'
    printf "\033[1;31m\n%s\033[0m" "## ERROR you need to give an input argument for this script as the number of repetitions."
    printf "\n\033[1;31m%88s\033[0m\n\n" " " | tr ' ' '-'
    exit 1
   fi
}

cpu_stress() {
    how_many_reps="${1}"
    value_a="${RANDOM}"
    value_b="${RANDOM}"

    for ((i=0; i<"${how_many_reps}"; i++)); do
        echo -e "${value_a} * ${value_b}" | bc
        value_a=$((value_a + "${RANDOM}"))
        value_b=$((value_b + "${RANDOM}"))
    done
}

main() {
    sanity_checks "${@}"
    cpu_stress "${@}"
}

main "${@}"
