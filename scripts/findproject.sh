#!/usr/bin/env bash
#
# xcframework.sh
# Usage example: ./findproject.sh --project-name <project_name>

# Set Script Variables

SCRIPT="$("$(dirname "$0")/resolvepath.sh" "$0")"
SCRIPTS_DIR="$(dirname "$SCRIPT")"
ROOT_DIR="$(dirname "$SCRIPTS_DIR")"

EXIT_CODE=0

# Help

function printhelp() {
    local HELP="Locates the Xcode project for the current workspace.\n\n"
    HELP+="findproject.sh [--help | -h] [--project-name <project_name>]\n"
    HELP+="\n"
    HELP+="--help, -h)     Print this help message and exit.\n"
    HELP+="\n"
    HELP+="--project-name) The name of the project to locate. If not provided,\n"
    HELP+="                the working directory is searched for a Xcode project.\n"

    IFS='%'
    echo -e "$HELP" 1>&2
    unset IFS

    exit $EXIT_CODE
}

# Parse Arguments

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project-name)
        PROJECT_NAME="$2"
        shift # --project-name
        shift # <project_name>
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

if [ -z ${PROJECT_NAME+x} ]; then
    PROJECTS=($(ls "$ROOT_DIR" | grep \.xcodeproj$))

    if [ "${#PROJECTS[@]}" == "0" ]; then
        echo -e "No Xcode projects found in root directory. Try specifying a project name:\n" 1>&2
        exit 1
    elif [ "${#PROJECTS[@]}" == "1" ]; then
        PROJECT_NAME="${PROJECTS[0]}"
        PROJECT_NAME="${PROJECT_NAME%.*}"
    else
        echo -e "More than 1 Xcode projects found in root directory. Specify which project to use:\n" 1>&2
        exit 1
    fi
else
    if [ "${PROJECT_NAME##*.}" == "xcodeproj" ]; then
        if [ -e "$ROOT_DIR/$PROJECT_NAME" ]; then
            PROJECT_NAME="${PROJECT_NAME%.*}"
        else
            ERROR_MESSAGE="Unable to locate specified Xcode project: $ROOT_DIR/$PROJECT_NAME\n"
        fi
    elif [ ! -e "$ROOT_DIR/$PROJECT_NAME.xcodeproj" ]; then
        ERROR_MESSAGE="Unable to locate specified Xcode project: $ROOT_DIR/$PROJECT_NAME.xcodeproj\n"
    fi

    if [ "${#ERROR_MESSAGE[@]}" != "0" ]; then
        echo -e "$ERROR_MESSAGE" 1>&2
        exit 1
    fi
fi

#

echo "$PROJECT_NAME"
exit 0
