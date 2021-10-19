#!/usr/bin/env bash
#
# resolvepath.sh
# Usage example: ./resolvepath.sh "./some/random/path/../../"

cd "$(dirname "$1")" &>/dev/null && echo "$PWD/${1##*/}"
