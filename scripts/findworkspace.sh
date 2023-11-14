#!/usr/bin/env bash
#
# xcframework.sh
# Usage example: ./findworkspace.sh --workspace-name <workspace_name>

# Set Script Variables

SCRIPT="$("$(dirname "$0")/resolvepath.sh" "$0")"
SCRIPTS_DIR="$(dirname "$SCRIPT")"
ROOT_DIR="$(dirname "$SCRIPTS_DIR")"

EXIT_CODE=0

# Help

function printhelp() {
    local HELP="Locates the Xcode workspace for the current working directory.\n\n"
    HELP+="findworkspace.sh [--help | -h] [--workspace-name <workspace_name>]\n"
    HELP+="\n"
    HELP+="--help, -h)       Print this help message and exit.\n"
    HELP+="\n"
    HELP+="--workspace-name) The name of the workspace to locate. If not provided,\n"
    HELP+="                  the working directory is searched for a Xcode workspace.\n"

    IFS='%'
    echo -e "$HELP" 1>&2
    unset IFS

    exit $EXIT_CODE
}

# Parse Arguments

while [[ $# -gt 0 ]]; do
    case "$1" in
        --workspace-name)
        WORKSPACE_NAME="$2"
        shift # --workspace-name
        shift # <workspace_name>
        ;;

        --help | -h)
        printhelp
        ;;

        *)
        echo -e "Unknown argument: $1\n" 1>&2
        EXIT_CODE=1
        printhelp
        ;;
    esac
done

#

if [ -z ${WORKSPACE_NAME+x} ]; then
    WORKSPACES=($(ls "$ROOT_DIR" | grep \.xcworkspace$))

    if [ "${#WORKSPACES[@]}" == "0" ]; then
        echo -e "No Xcode workspaces found in root directory. Try specifying a workspace name:\n" 1>&2
        exit 1
    elif [ "${#WORKSPACES[@]}" == "1" ]; then
        WORKSPACE_NAME="${WORKSPACES[0]}"
        WORKSPACE_NAME="${WORKSPACE_NAME%.*}"
    else
        echo -e "More than 1 Xcode workspaces found in root directory. Specify which workspace to use:\n" 1>&2
        exit 1
    fi
else
    if [ "${WORKSPACE_NAME##*.}" == "xcworkspace" ]; then
        if [ -e "$ROOT_DIR/$WORKSPACE_NAME" ]; then
            WORKSPACE_NAME="${WORKSPACE_NAME%.*}"
        else
            ERROR_MESSAGE="Unable to locate specified Xcode workspace: $ROOT_DIR/$WORKSPACE_NAME\n"
        fi
    elif [ ! -e "$ROOT_DIR/$WORKSPACE_NAME.xcworkspace" ]; then
        ERROR_MESSAGE="Unable to locate specified Xcode workspace: $ROOT_DIR/$WORKSPACE_NAME.xcworkspace\n"
    fi

    if [ "${#ERROR_MESSAGE[@]}" != "0" ]; then
        echo -e "$ERROR_MESSAGE" 1>&2
        exit 1
    fi
fi

#

echo "$WORKSPACE_NAME"
exit 0
