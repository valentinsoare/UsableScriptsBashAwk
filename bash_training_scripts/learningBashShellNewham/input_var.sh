#!/usr/bin/bash

declare -a extracted_arr

oldIFS=$IFS
IFS=','

#### $(*) and ${@} and some working lessons with arrays
all_variables_single_string="${*}"    ###one single string with IFS between elements
extracted_arr+=( "${@}" )    #### array with elements as strings

printf "%s " "${extracted_arr[@]:0:3}" ### printing the first three elements
printf "\n%s %s\n" "number of elements:" "${#extracted_arr[@]}"   ### print the numbber of elements
printf "%s\n" "${all_variables_single_string}"


### String Operators ###
printf "%s\n" "${extracted_ar[*]:-ERROR}"

printf "%s\n" "${count:-0}"
IFS=${oldIFS}