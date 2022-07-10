#!/usr/bin/bash

lsd() {
    local given_date="${1}"

    ls -l | grep -E -i "${given_date}" | awk '{print $9}'
}

lsd "Oct  8"