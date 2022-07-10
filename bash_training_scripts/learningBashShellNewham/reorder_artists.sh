#!/usr/bin/bash

given_file="${1}"
given_file="${given_file:?"**ERROR* - not input argument was given, no file to sort."}"
#how_many_lines="${2:-2}" or
how_many_lines="${2}"
third_option="${3}"

printf "%s\n" "${third_option:+"ALBUMS   ARTISTS"}" | grep -v -E "^$"
sort -k1 -n -r "${given_file}" | head -"${how_many_lines:=2}"CV