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

if [ -z "$EXTRA_GROUP_IDS" ]; then
    echo "No additional groups"
else
    for i in ${EXTRA_GROUP_IDS//,/ }; do
        if [ ! $(getent group "g$i") ]; then
            groupadd -g "$i" "g$i"
        fi
    done
    echo "Additional groups $EXTRA_GROUP_IDS"
    usermod -G "$EXTRA_GROUP_IDS" "$USERNAME"
fi

exec gosu emonhub "$@"

