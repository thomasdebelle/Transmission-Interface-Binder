#!/bin/bash
interface=$1;

interfaceIP=""
#If the interface is not whitespace, then determine the IP
if [ -z "${interface// }" ]; then
    interfaceIP=""
else
    #Get the interface ip
    interfaceIP=$(ifconfig $interface | grep 'inet ' | cut -d ' ' -f 2)
fi

printf "%s" "$interfaceIP"