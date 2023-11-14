#!/usr/bin/env bash
#
# workflowtests/documentation_tests.sh

# THE INTENT OF THIS FILE IS TO BE IMPORTED DIRECTLY BY THE 'WORKFLOWTESTS.SH'
# FILE. THIS SHOULD RAN DIRECTLY OR IMPORTED BY ANY OTHER BASH SCRIPT.

printstep "Testing 'documentation.yml' Workflow..."

ERROR_MESSAGE="'Build Documentation' step of 'documentation.yml' workflow failed."

if [ "$VERBOSE" == "1" ]; then
    xcodebuild docbuild "${XCODEBUILD_ARGS[@]}" -scheme "$PRODUCT_NAME" -destination "generic/platform=iOS" -derivedDataPath "$OUTPUT_DIR/.xcodebuild" SKIP_SWIFTLINT=YES
else
    LOG="$(createlogfile "build-documentation")"
    ERROR_MESSAGE="$(errormessage "$ERROR_MESSAGE" "$LOG")"

    #

    xcodebuild docbuild "${XCODEBUILD_ARGS[@]}" -scheme "$PRODUCT_NAME" -destination "generic/platform=iOS" -derivedDataPath "$OUTPUT_DIR/.xcodebuild" SKIP_SWIFTLINT=YES > "$LOG" 2>&1
fi

checkresult $? "$ERROR_MESSAGE"

printstep "'documentation.yml' Workflow Tests Passed\n"
