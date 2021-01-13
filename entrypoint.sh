#!/bin/bash

USERNAME=emonhub
DEFAULT_UID_GID=9000

userdel "$USERNAME" 2>/dev/null
groupdel "$USERNAME" 2>/dev/null

if [ -z "$USER_ID" ]; then USER_ID="$DEFAULT_UID_GID"; fi
if [ -z "$GROUP_ID" ]; then GROUP_ID="$DEFAULT_UID_GID"; fi

echo "Starting with UID:$USER_ID and GID:$GROUP_ID"

if [ ! $(getent group "$GROUP_ID") ]; then
    groupadd -g "$GROUP_ID" "$USERNAME";
fi

useradd -r -u "$USER_ID" -g "$GROUP_ID" "$USERNAME"

if [ -z "$EXTRA_GROUPS" ]; then
    echo "No additional groups"
else
    for g in ${EXTRA_GROUPS//,/ }; do
        if [ ! $(getent group "$g") ]; then
            groupadd -g "$g" "g$g" # assume group is numeric gid
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

