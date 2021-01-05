#!/bin/bash

# Add local user "emonhub"
# Either use the USER_ID if passed in at runtime or fallback to auto

if id emonhub > /dev/null; then

    EMON_ID="$(id -u emonhub)"
    echo "Existing $EMON_ID, new $USER_ID"

    if [ "$USER_ID" -ne "$EMON_ID" ]; then
        echo "Deleting existing user 'emonhub' ($EMON_ID)"
        userdel emonhub
        echo "Starting with UID : $USER_ID"
        useradd -u "$USER_ID" -M -r -G dialout,tty -c "emonHub user" emonhub
    fi

else

    if [ -z "$USER_ID" ]; then
        echo "Starting with auto UID"
        useradd -M -r -G dialout,tty -c "emonHub user" emonhub
    else
        echo "Starting with UID : $USER_ID"
        useradd -u "$USER_ID" -M -r -G dialout,tty -c "emonHub user" emonhub
    fi

fi

exec gosu emonhub "$@"

