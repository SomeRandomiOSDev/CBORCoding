#!/usr/bin/env bash
#
# workflowtests/parse_arguments.sh

# THE INTENT OF THIS FILE IS TO BE IMPORTED DIRECTLY BY THE 'WORKFLOWTESTS.SH'
# FILE. THIS SHOULD RAN DIRECTLY OR IMPORTED BY ANY OTHER BASH SCRIPT.

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project-name)
        PROJECT_NAME="$2"
        shift # --project-name
        shift # <project_name>
        ;;

        --workspace-name)
        WORKSPACE_NAME="$2"
        shift # --workspace-name
        shift # <workspace_name>
        ;;

        --is-running-in-temp-env)
        IS_RUNNING_IN_TEMP_ENV=1
        shift # --is-running-in-temp-env
        ;;

        --no-clean)
        NO_CLEAN=1
        shift # --no-clean
        ;;

        --no-clean-on-fail)
        NO_CLEAN_ON_FAIL=1
        shift # --no-clean-on-fail
        ;;

        --verbose)
        VERBOSE=1
        shift # --verbose
        ;;

        --help | -h)
        printhelp
        ;;

        *)
        "$SCRIPTS_DIR/printformat.sh" "foreground:red" "Unknown argument: $1\n" 1>&2
        EXIT_CODE=1
        printhelp
        ;;
    esac
done

#

if [ -z ${IS_RUNNING_IN_TEMP_ENV+x} ]; then
    IS_RUNNING_IN_TEMP_ENV=0
fi

if [ -z ${NO_CLEAN+x} ]; then
    NO_CLEAN=0
fi

if [ -z ${NO_CLEAN_ON_FAIL+x} ]; then
    NO_CLEAN_ON_FAIL=0
fi

#

if [ "${#WORKSPACE_NAME}" != 0 ]; then
    USE_WORKSPACE=1
    WORKSPACE_NAME="$("$SCRIPTS_DIR/findworkspace.sh" --workspace-name "$WORKSPACE_NAME")"

    checkresult $?
elif [ "${#PROJECT_NAME}" != 0 ]; then
    USE_WORKSPACE=0
    PROJECT_NAME="$("$SCRIPTS_DIR/findproject.sh" --project-name "$PROJECT_NAME")"

    checkresult $?
else
    WORKSPACE_NAME="$("$SCRIPTS_DIR/findworkspace.sh")" 2> /dev/null
    RESULT=$?

    if [[ "$RESULT" == 0 ]] && [[ "${#WORKSPACE_NAME}" != 0 ]]; then
        USE_WORKSPACE=1
    else
        PROJECT_NAME="$("$SCRIPTS_DIR/findproject.sh")" 2> /dev/null
        RESULT=$?

        if [[ "$RESULT" == 0 ]] && [[ "${#PROJECT_NAME}" != 0 ]]; then
            USE_WORKSPACE=0
        else
            checkresult 1 "Unable to find specific Xcode project or workspace in the root directory. Try specifying a project or workspace name:\n"
        fi
    fi
fi

if [ "$USE_WORKSPACE" == "1" ]; then
    PRODUCT_NAME="$WORKSPACE_NAME"
    FULL_PRODUCT_NAME="$WORKSPACE_NAME.xcworkspace"
    XCODEBUILD_ARGS=(-workspace "$FULL_PRODUCT_NAME")
    FORWARDING_ARGS=(--workspace-name "$WORKSPACE_NAME")
else
    PRODUCT_NAME="$PROJECT_NAME"
    FULL_PRODUCT_NAME="$PROJECT_NAME.xcodeproj"
    XCODEBUILD_ARGS=(-project "$FULL_PRODUCT_NAME")
    FORWARDING_ARGS=(--project-name "$PRODUCT_NAME")
fi

#

VERBOSE_FLAGS=()
if [ "$VERBOSE" == "1" ]; then
    VERBOSE_FLAGS=(--verbose)
fi

#

if [ "$IS_RUNNING_IN_TEMP_ENV" == "1" ]; then
    OUTPUT_DIR="$ROOT_DIR"
else
    OUTPUT_DIR="$(setuptemp)"
    echo -e "Testing from Temporary Directory: $("$SCRIPTS_DIR/printformat.sh" "foreground:yellow" "$OUTPUT_DIR")"
fi
