#!/bin/bash

# The name of polybar bar which houses the main spotify module and the control modules.
PARENT_BAR="example"
PARENT_BAR_PID=$(pgrep -a "polybar" | grep "$PARENT_BAR" | cut -d" " -f1)

# List of players to check
PLAYERS=("spotify" "brave")

# Format of the information displayed
# Eg. {{ artist }} - {{ album }} - {{ title }}
# See more attributes here: https://github.com/altdesktop/playerctl/#printing-properties-and-metadata
FORMAT="{{ title }} - {{ artist }}"

# Function to send $2 as a message to all polybar PIDs that are part of $1
update_hooks() {
    while IFS= read -r id
    do
        polybar-msg -p "$id" hook spotify-play-pause $2 1>/dev/null 2>&1
    done < <(echo "$1")
}

STATUS="No player is running"
METADATA=""

# Loop through players to find one that is playing or paused
for PLAYER in "${PLAYERS[@]}"; do
    PLAYERCTL_STATUS=$(playerctl --player=$PLAYER status 2>/dev/null)
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        if [ "$PLAYERCTL_STATUS" = "Playing" ]; then
            STATUS="Playing"
            METADATA=$(playerctl --player=$PLAYER metadata --format "$FORMAT")
            update_hooks "$PARENT_BAR_PID" 1
            break
        elif [ "$PLAYERCTL_STATUS" = "Paused" ]; then
            STATUS="Paused"
            METADATA=$(playerctl --player=$PLAYER metadata --format "$FORMAT")
            update_hooks "$PARENT_BAR_PID" 2
            break
        fi
    fi
done

# Display the status or metadata
if [ "$1" == "--status" ]; then
    echo "$STATUS"
else
    if [ "$STATUS" = "No player is running" ]; then
        echo "$STATUS"
    else
        echo "$METADATA"
    fi
fi

