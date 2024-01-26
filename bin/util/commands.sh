#!/usr/bin/env bash
SUDO_CMD="${SUDO_CMD-sudo}"

function as_root() {
    echo "Running privileged command"
    echo " $SUDO_CMD " "$@"

    if [[ -n "$SUDO_CMD" ]]; then
        "$SUDO_CMD" "$@"
    else
        "$@"
    fi
}

