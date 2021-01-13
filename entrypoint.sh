#!/bin/bash

USERNAME=emonhub
DEFAULT_UID_GID=9000

userdel "$USERNAME" 2>/dev/null
groupdel "$USERNAME" 2>/dev/null

if [ -z "$USER" ]; then
    USER_ID="$DEFAULT_UID_GID";
else
    USER_ID=$(id -u "$USER")
    if [ -z "$USER_ID" ]; then
        USER_ID="$USER" # Assume USER is UID
    fi
fi

if [ -z "$GROUP" ]; then
    GROUP_ID="$DEFAULT_UID_GID";
else
    GROUP_ID=$(getent group "$GROUP" | cut -d: -f3)
    if [ -z "$GROUP_ID" ]; then
        GROUP_ID="$GROUP" # Assume GROUP is GID
    fi
fi

echo "Starting with UID:$USER_ID and GID:$GROUP_ID"

groupadd -o -g "$GROUP_ID" "$USERNAME";
useradd -o -r -u "$USER_ID" -g "$GROUP_ID" "$USERNAME"

if [ -z "$EXTRA_GROUPS" ]; then
    echo "No additional groups"
else
    for g in ${EXTRA_GROUPS//,/ }; do
        if [ ! $(getent group "$g") ]; then
            groupadd -g "$g" "g$g" # Assume g is GID
            EXTRA_GROUP_IDS="$EXTRA_GROUP_IDS,$g"
        else
            gid=$(getent group "$g" | cut -d: -f3)
            EXTRA_GROUP_IDS="$EXTRA_GROUP_IDS,$gid"
        fi
    done
    echo "Additional group IDs ${EXTRA_GROUP_IDS/,/}"
    usermod -G "${EXTRA_GROUP_IDS/,/}" "$USERNAME"
fi

exec gosu emonhub "$@"
