#!/bin/bash

#If Transmission is not open, bail.
was_running=$(ps aux | grep -i [T]ransmission.app | wc -l)
if [ $was_running -eq 0 ]; then
    exit
fi

echo "Restarting Transmission...."

#Gracefully quit transmission
#The & sign at the end is critical as it allows this command to run in background.
#Without it, we cannot continue onto the other commands when the "Are you sure you want to quit" warning appears.
osascript -e 'quit app "Transmission"' &

#Hit return to satisfy "Are you sure you want to quit" warning, this was fun writing (sarcasm)
osascript <<EOF
tell application "System Events"
    if ((count (every process whose name is "Transmission")) > 0) then
        tell application "Transmission" to activate
        tell application "System Events"
            tell process "Transmission"
                keystroke return
            end tell
        end tell
    end if
end tell
EOF

#Wait until transimssion has fully closed to reopen it.
while true;
do
    is_running=$(ps aux | grep -i [T]ransmission.app | wc -l)
    if [ $is_running -eq 0 ]; then
            sleep 0.5
            #Open Transmission, independant of its location with -a. Application location will differ user to user.
            open -a Transmission
            break
    fi
done