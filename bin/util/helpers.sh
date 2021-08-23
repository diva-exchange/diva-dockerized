#!/usr/bin/env bash

function command_exists () {
  type hash "$1" 2>/dev/null 1>&2;
}

function confirm() {
    echo -e "\x1b[31;01m"
    # call with a prompt string or use a default
    read -r -p "${1:-Continue? [y/N]} " response
    echo -e "\x1b[39;49;00m"
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}
