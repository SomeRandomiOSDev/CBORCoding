#!/usr/bin/env bash
#
# versions.sh
# Usage example: ./versions.sh "1.4.15" "1.7.0"

# Copied & adapted from: https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash#answer-4025065
function compare_versions() {
    if [ $1 = $2 ]; then
        return 0
    fi

    local IFS=.
    local i LHS=($1) RHS=($2)

    for ((i=${#LHS[@]}; i<${#RHS[@]}; i++)); do
        LHS[i]=0
    done

    for ((i=0; i<${#LHS[@]}; i++)); do
        if [ -z ${RHS[i]} ]; then
            RHS[i]=0
        fi

        if ((10#${LHS[i]} > 10#${RHS[i]})); then
            return 1
        elif ((10#${LHS[i]} < 10#${RHS[i]})); then
            return -1
        fi
    done

    return 0
}

exit $(compare_versions $1 $2)
