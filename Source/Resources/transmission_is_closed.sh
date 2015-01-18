#!/bin/bash

#Finish script execution only once transmission is closed.
while true;
do
is_running=$(ps aux | grep -i [T]ransmission.app | wc -l)
if [ $is_running -eq 0 ]; then
        break
fi
sleep 0.5
done
