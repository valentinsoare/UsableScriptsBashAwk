#!/usr/bin/bash

#to_execute() {
#    sshpass -p "bobita_1871119520010+" ssh -o ConnectTimeout=1 -o StrictHostKeyChecking=no -q "vsoare@moviesondemand.io" << EOF
#        variabila="\$(ip a | grep eno1 | grep -E -o "(([0-9]{1,3})\.){1,3}[0-9]{1,3}" | head -1)"
#        ping "\${variabila}" -c 5    
#EOF
#}

for_services() {
    if systemctl status sshd.service; then
        printf "%s\n" "All Good"
    else
        printf "%s\n" "Not all good"
    fi

}


main() {
    for_services
    #to_execute
}
         
main
