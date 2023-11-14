#!/usr/bin/env bash
#
# workflowtests/xcodebuild_test_tests.sh

# THE INTENT OF THIS FILE IS TO BE IMPORTED DIRECTLY BY THE 'WORKFLOWTESTS.SH'
# FILE. THIS SHOULD RAN DIRECTLY OR IMPORTED BY ANY OTHER BASH SCRIPT.

IOS_SIM="$(xcrun simctl list devices available | grep "iPhone [0-9]" | sort -rV | head -n 1 | sed -E 's/(.+)[ ]*\([^)]*\)[ ]*\([^)]*\)/\1/' | awk '{$1=$1};1')"
TVOS_SIM="$(xcrun simctl list devices available | grep "Apple TV" | sort -V | head -n 1 | sed -E 's/(.+)[ ]*\([^)]*\)[ ]*\([^)]*\)/\1/' | awk '{$1=$1};1')"
WATCHOS_SIM="$(xcrun simctl list devices available | grep "Apple Watch" | sort -rV | head -n 1 | sed -E 's/(.+)[ ]*\([^)]*\)[ ]*\([^)]*\)/\1/' | awk '{$1=$1};1')"

#

for PLATFORM in "iOS" "Mac Catalyst" "macOS" "tvOS" "watchOS"; do
    echo -e "$("$SCRIPTS_DIR/printformat.sh" "foreground:blue" "***") Testing $("$SCRIPTS_DIR/printformat.sh" "foreground:green" "$PLATFORM") in $("$SCRIPTS_DIR/printformat.sh" "bold" "$FULL_PRODUCT_NAME")"

    SCHEME="${PRODUCT_NAME}"
    TESTPLAN="${SCHEME}Tests"
    DESTINATION="$PLATFORM"

    case "$PLATFORM" in
        "iOS") DESTINATION="iOS Simulator,name=$IOS_SIM" ;;
        "Mac Catalyst") DESTINATION="macOS,variant=Mac Catalyst" ;;

        "macOS")
        TESTPLAN="$SCHEME macOS Tests"
        SCHEME="$SCHEME macOS"
        ;;

        "tvOS")
        TESTPLAN="$SCHEME tvOS Tests"
        SCHEME="$SCHEME tvOS"
        DESTINATION="tvOS Simulator,name=$TVOS_SIM"
        ;;

        "watchOS")
        TESTPLAN="$SCHEME watchOS Tests"
        SCHEME="$SCHEME watchOS"
        DESTINATION="watchOS Simulator,name=$WATCHOS_SIM"
        ;;
    esac

    #

    ERROR_MESSAGE="'Test $PLATFORM' step of 'xcodebuild.yml' workflow failed."

    if [ "$VERBOSE" == "1" ]; then
        xcodebuild "${XCODEBUILD_ARGS[@]}" -scheme "$SCHEME" -testPlan "$TESTPLAN" -destination "platform=$DESTINATION" -configuration Debug RUN_DOCUMENTATION_COMPILER=NO SKIP_SWIFTLINT=YES ONLY_ACTIVE_ARCH=YES test
    else
        LOG="$(createlogfile "$(echo "$PLATFORM" | tr -d ' ' | tr '[:upper:]' '[:lower:]')-test")"
        ERROR_MESSAGE="$(errormessage "$ERROR_MESSAGE" "$LOG")"

        #

        xcodebuild "${XCODEBUILD_ARGS[@]}" -scheme "$SCHEME" -testPlan "$TESTPLAN" -destination "platform=$DESTINATION" -configuration Debug RUN_DOCUMENTATION_COMPILER=NO SKIP_SWIFTLINT=YES ONLY_ACTIVE_ARCH=YES test > "$LOG" 2>&1
    fi

    checkresult $? "$ERROR_MESSAGE"
done
