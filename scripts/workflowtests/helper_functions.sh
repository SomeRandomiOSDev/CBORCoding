#!/usr/bin/env bash
#
# workflowtests/helper_functions.sh

# THE INTENT OF THIS FILE IS TO BE IMPORTED DIRECTLY BY THE 'WORKFLOWTESTS.SH'
# FILE. THIS SHOULD RAN DIRECTLY OR IMPORTED BY ANY OTHER BASH SCRIPT.

function printhelp() {
    local HELP="Run tests for the Github Action workflows.\n"
    HELP+="\n"
    HELP+="workflowtests.sh [--help | -h] [--verbose] [--project-name <project_name>]\n"
    HELP+="                 [--no-clean | --no-clean-on-fail] [--is-running-in-temp-env]\n"
    HELP+="\n"
    HELP+="--help, -h)               Print this help message and exit.\n"
    HELP+="\n"
    HELP+="--help, -h)               Enable verbose logging.\n"
    HELP+="\n"
    HELP+="--project-name)           The name of the project to run tests against. If not\n"
    HELP+="                          provided it will attempt to be resolved by searching\n"
    HELP+="                          the working directory for an Xcode project and using\n"
    HELP+="                          its name.\n"
    HELP+="\n"
    HELP+="--workspace-name)         The name of the workspace to run tests against. If not\n"
    HELP+="                          provided it will attempt to be resolved by searching\n"
    HELP+="                          the working directory for a Xcode workspace and using\n"
    HELP+="                          its name.\n"
    HELP+="\n"
    HELP+="--no-clean)               When not running in a temporary environment, do not\n"
    HELP+="                          clean up the temporary project created to run these\n"
    HELP+="                          tests upon completion.\n"
    HELP+="\n"
    HELP+="--no-clean-on-fail)       Same as --no-clean with the exception that if the\n"
    HELP+="                          succeed clean up will continue as normal. This is\n"
    HELP+="                          mutually exclusive with --no-clean with --no-clean\n"
    HELP+="                          taking precedence.\n"
    HELP+="\n"
    HELP+="--is-running-in-temp-env) Setting this flag tells this script that the\n"
    HELP+="                          environment (directory) in which it is running is a\n"
    HELP+="                          temporary environment and it need not worry about\n"
    HELP+="                          dirtying up the directory or creating/deleting files\n"
    HELP+="                          and folders. USE CAUTION WITH THIS OPTION.\n"
    HELP+="\n"
    HELP+="                          When this flag is NOT set, a copy of the containing\n"
    HELP+="                          working folder is created in a temporary location and\n"
    HELP+="                          removed (unless --no-clean is set) after the tests\n"
    HELP+="                          have finished running."

    IFS='%'
    echo -e "$HELP" 1>&2
    unset IFS

    exit $EXIT_CODE
}

function cleanup() {
    if [ "$IS_RUNNING_IN_TEMP_ENV" == "0" ]; then
        if [[ "$NO_CLEAN" == "1" ]] || [[ "$NO_CLEAN_ON_FAIL" == "1" && "$EXIT_CODE" != "0" ]]; then
            echo "Test Project: $OUTPUT_DIR"
        else
            cd "$CURRENT_DIR"
            rm -rf "$TEMP_DIR"
        fi
    fi

    #

    local CARTHAGE_CACHE="$HOME/Library/Caches/org.carthage.CarthageKit"
    if [ -e "$CARTHAGE_CACHE" ]; then
        if [ -e "$CARTHAGE_CACHE/dependencies/$PROJECT_NAME" ]; then
            rm -rf "$CARTHAGE_CACHE/dependencies/$PROJECT_NAME"
        fi

        for DIR in $(find "$CARTHAGE_CACHE/DerivedData" -mindepth 1 -maxdepth 1 -type d); do
            if [ -e "$DIR/$PROJECT_NAME" ]; then
                rm -rf "$DIR/$PROJECT_NAME"
            fi
        done
    fi

    #

    if [ "${#EXIT_MESSAGE}" != 0 ]; then
        if [ "$EXIT_MESSAGE" == "**printhelp**" ]; then
            printhelp
        else
            echo -e "$EXIT_MESSAGE" 1>&2
        fi
    fi

    exit $EXIT_CODE
}

function checkresult() {
    if [ "$1" != "0" ]; then
        if [ "${#2}" != "0" ]; then
            EXIT_MESSAGE="$("$SCRIPTS_DIR/printformat.sh" "foreground:red" "$2")"
        else
            EXIT_MESSAGE="**printhelp**"
        fi

        EXIT_CODE=$1
        cleanup
    fi
}

function printstep() {
    "$SCRIPTS_DIR/printformat.sh" "foreground:green" "$1"
}

function setuptemp() {
    TEMP_DIR="$(mktemp -d)"

    local TEMP_NAME="$(basename "$(mktemp -u "$TEMP_DIR/${PROJECT_NAME}WorkflowTests_XXXXXXXX")")"
    local OUTPUT_DIR="$TEMP_DIR/$TEMP_NAME"

    cp -R "$ROOT_DIR" "$OUTPUT_DIR"
    if [ "$?" != "0" ]; then exit $?; fi

    if [ -e "$OUTPUT_DIR/.build" ]; then
        rm -rf "$OUTPUT_DIR/.build"
    fi
    if [ -e "$OUTPUT_DIR/.swiftpm" ]; then
        rm -rf "$OUTPUT_DIR/.swiftpm"
    fi
    if [ -e "$OUTPUT_DIR/.xcodebuild" ]; then
        rm -rf "$OUTPUT_DIR/.xcodebuild"
    fi

    echo "$OUTPUT_DIR"
}

function createlogfile() {
    if [ ! -d "$OUTPUT_DIR/Logs" ]; then
        mkdir -p "$OUTPUT_DIR/Logs"
    fi

    local LOG="$OUTPUT_DIR/Logs/$1.log"
    touch "$LOG"

    echo "$LOG"
}

function errormessage() {
    local ERROR_MESSAGE="$1"

    if [[ "$NO_CLEAN" == "1" ]] || [[ "$NO_CLEAN_ON_FAIL" == "1" ]]; then
        ERROR_MESSAGE="$("$SCRIPTS_DIR/printformat.sh" "foreground:default" "${1%.}. See log for more details: $("$SCRIPTS_DIR/printformat.sh" "foreground:yellow" "$2")")"
    elif [ "$VERBOSE" != "1" ]; then
        ERROR_MESSAGE="$("$SCRIPTS_DIR/printformat.sh" "foreground:default" "${1%.}. Use the '--no-clean' or '--no-clean-on-fail' flag to inspect the logs.")"
    fi

    echo "$ERROR_MESSAGE"
}

function interrupt() {
    EXIT_CODE=$SIGINT
    EXIT_MESSAGE="$("$SCRIPTS_DIR/printformat.sh" "foreground:yellow" "Tests run was interrupted..")"

    cleanup
}
