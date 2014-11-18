#!/bin/bash

#Wait until Transmission opens, then close it immidiately and finish script execution
while true;
do
is_running=$(ps aux | grep -i [T]ransmission.app | wc -l)
if [ $is_running -eq 1 ]; then
        sleep 0.25
        killall Transmission
        break
fi
done
