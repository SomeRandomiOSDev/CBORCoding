#!/usr/bin/env bash
#
# workflowtests/xcodebuild_build_tests.sh

# THE INTENT OF THIS FILE IS TO BE IMPORTED DIRECTLY BY THE 'WORKFLOWTESTS.SH'
# FILE. THIS SHOULD RAN DIRECTLY OR IMPORTED BY ANY OTHER BASH SCRIPT.

for PLATFORM in "iOS" "iOS Simulator" "Mac Catalyst" "macOS" "tvOS" "tvOS Simulator" "watchOS" "watchOS Simulator"; do
    echo -e "$("$SCRIPTS_DIR/printformat.sh" "foreground:blue" "***") Building $("$SCRIPTS_DIR/printformat.sh" "foreground:green" "$PLATFORM") in $("$SCRIPTS_DIR/printformat.sh" "bold" "$FULL_PRODUCT_NAME")"

    SCHEME="$PRODUCT_NAME"
    DESTINATION="$PLATFORM"

    case "$PLATFORM" in
        "Mac Catalyst") DESTINATION="macOS,variant=Mac Catalyst" ;;
        "macOS") SCHEME="${SCHEME} macOS" ;;

        "tvOS") SCHEME="${SCHEME} tvOS" ;;
        "tvOS Simulator") SCHEME="${SCHEME} tvOS" ;;

        "watchOS") SCHEME="${SCHEME} watchOS" ;;
        "watchOS Simulator") SCHEME="${SCHEME} watchOS" ;;
    esac

    #

    ERROR_MESSAGE="'Build $PLATFORM' step of 'xcodebuild.yml' workflow failed."

    if [ "$VERBOSE" == "1" ]; then
        xcodebuild "${XCODEBUILD_ARGS[@]}" -scheme "$SCHEME" -destination "generic/platform=$DESTINATION" -configuration Debug RUN_DOCUMENTATION_COMPILER=NO SKIP_SWIFTLINT=YES
    else
        LOG="$(createlogfile "$(echo "$PLATFORM" | tr -d ' ' | tr '[:upper:]' '[:lower:]')-build")"
        ERROR_MESSAGE="$(errormessage "$ERROR_MESSAGE" "$LOG")"

        #

        xcodebuild "${XCODEBUILD_ARGS[@]}" -scheme "$SCHEME" -destination "generic/platform=$DESTINATION" -configuration Debug RUN_DOCUMENTATION_COMPILER=NO SKIP_SWIFTLINT=YES > "$LOG" 2>&1
    fi

    checkresult $? "$ERROR_MESSAGE"
done

echo ""
