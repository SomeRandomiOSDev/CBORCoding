#!/usr/bin/env bash
#
# workflowtests/xcframework_tests.sh

# THE INTENT OF THIS FILE IS TO BE IMPORTED DIRECTLY BY THE 'WORKFLOWTESTS.SH'
# FILE. THIS SHOULD RAN DIRECTLY OR IMPORTED BY ANY OTHER BASH SCRIPT.

printstep "Testing 'xcframework.yml' Workflow..."

./scripts/xcframework.sh "${FORWARDING_ARGS[@]}" --output "$OUTPUT_DIR" "${VERBOSE_FLAGS[@]}" -- RUN_DOCUMENTATION_COMPILER=NO SKIP_SWIFTLINT=YES
checkresult $? "'Build' step of 'xcframework.yml' workflow failed."

printstep "'xcframework.yml' Workflow Tests Passed\n"
