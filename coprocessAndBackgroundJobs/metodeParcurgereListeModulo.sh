#! /usr/bin/bash
ping localhost -c 50 2> /dev/null &
pid=$!

spin='-\|/'

    i=0
    j=0
    while true; do
        [[ ${j} -eq 20 ]] && { kill -s 9 ${pid} 2> /dev/null; wait "${pid}" 2> /dev/null; break; }
        i=$(( (i+1) %4 ))
        echo -en "\r${spin:$i:1}"
        sleep 0.1
        ((j++))
        ((i++))
    done


