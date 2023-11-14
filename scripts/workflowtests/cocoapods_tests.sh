#!/usr/bin/env bash
#
# workflowtests/cocoapods_tests.sh

# THE INTENT OF THIS FILE IS TO BE IMPORTED DIRECTLY BY THE 'WORKFLOWTESTS.SH'
# FILE. THIS SHOULD RAN DIRECTLY OR IMPORTED BY ANY OTHER BASH SCRIPT.

printstep "Testing 'cocoapods.yml' Workflow..."

pod lib lint "${VERBOSE_FLAGS[@]}"
checkresult $? "'Lint (Dynamic)' step of 'cocoapods.yml' workflow failed."

pod lib lint --use-libraries "${VERBOSE_FLAGS[@]}"
checkresult $? "'Lint (Static)' step of 'cocoapods.yml' workflow failed."

printstep "'cocoapods.yml' Workflow Tests Passed\n"
