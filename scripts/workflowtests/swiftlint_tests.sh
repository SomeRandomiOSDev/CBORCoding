#!/usr/bin/env bash
#
# workflowtests/swiftlint_tests.sh

# THE INTENT OF THIS FILE IS TO BE IMPORTED DIRECTLY BY THE 'WORKFLOWTESTS.SH'
# FILE. THIS SHOULD RAN DIRECTLY OR IMPORTED BY ANY OTHER BASH SCRIPT.

printstep "Testing 'swiftlint.yml' Workflow..."

swiftlint
checkresult $? "'Run SwiftLint' step of 'swiftlint.yml' workflow failed."

printstep "'swiftlint.yml' Workflow Tests Passed\n"
