#!/usr/bin/env bash -e -o pipefail
#
# resolvepath.sh
# Usage example: ./resolvepath.sh "./some/random/path/../../"

cd "$(dirname "$1")" &>/dev/null && echo "$PWD/${1##*/}"
