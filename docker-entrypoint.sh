#!/usr/bin/env bash

set -e

chown -R keepassxc /keepassxc

if [ "$1" = "bash" ]; then
    exec gosu keepassxc "$@"
fi

exec "$@"
