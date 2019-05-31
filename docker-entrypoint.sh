#!/usr/bin/env bash

set -e

if [ "$1" = "bashx" ]; then
    chown -R keepassxc /keepassxc
    shift
    exec su-exec keepassxc bash "$@"
fi

exec "$@"
