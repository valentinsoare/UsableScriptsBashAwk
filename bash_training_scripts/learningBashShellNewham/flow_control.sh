#!/usr/bin/bash

IFS=":"

for i in ${PATH}; do
    printf "%s\n" "${i}"
    ls -ld "${i}" 2> /dev/null
done
