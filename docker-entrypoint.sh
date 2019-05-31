#!/usr/bin/env bash

set -e

chown -R keepassxc /keepassxc

if [ "$1" = "bash" ]; then
    # exec gosu keepassxc "$@"
    exec su-exec keepassxc "$@"
fi

exec "$@"
