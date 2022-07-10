#!/usr/bin/bash

declare summing=0

while read -r line; do
    summing=$((summing+line))
done <<< "$(ls -latrR | awk '{print $5}')"

echo -e "${summing}" | bc