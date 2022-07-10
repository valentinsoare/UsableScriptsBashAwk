#!/usr/bin/bash

settrap() {
    trap 'printf "%s\n" "You Hit Ctrl + Z/C"' INT TERM
    eval "${@}"
}

while true; do
    settrap "ping google.ro -c 100"
done