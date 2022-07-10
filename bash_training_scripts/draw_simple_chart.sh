#!/usr/bin/bash

declare i
declare -A given_values
declare -a given_names

i=0
given_names=("Karbosky" "John" "Helen" "Valentine" "Andreea")
given_values=( [Karbosky]="25" [John]="13" [Helen]="44" [Valentine]="14" [Andreea]="13")


printing_chart() {
    printf "\n%40s\n" " " | tr " " "-"

    while ((i < ${#given_names[@]})); do
        name="${given_names[i]}"
        printf "%-11s%-4s " "${name}: " "| ${given_values[${name}]}"
        printf "%s %s" "|" " ["
        printf "%${given_values[${name}]}s" " " | tr " " "#"
        printf "%s\n" "]"
        ((i++))
    done

    printf "%40s\n\n" " " | tr " " "-"

}

printing_chart
