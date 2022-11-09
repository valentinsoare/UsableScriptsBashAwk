#!/usr/bin/bash

declare -a list_with_servers list_of_services

list_with_servers=('192.168.122.18' '192.168.122.144')
list_with_services=('sshd' 'NetworkManager' 'iscsi' 'cups')
type_of_run=0


execute_ssh() {
    for destination in "${list_with_servers[@]}"; do
            sshpass -p "valisoare_191987+" ssh -o ConnectTimeout=1 -o StrictHostKeyChecking=no -q "vsoare@${destination}" << EOF
            arp -a
EOF
    done
}

main() {
    execute_ssh
}

main
