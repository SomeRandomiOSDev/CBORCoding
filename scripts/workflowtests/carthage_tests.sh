#!/usr/bin/env bash
#
# workflowtests/carthage_tests.sh

# THE INTENT OF THIS FILE IS TO BE IMPORTED DIRECTLY BY THE 'WORKFLOWTESTS.SH'
# FILE. THIS SHOULD RAN DIRECTLY OR IMPORTED BY ANY OTHER BASH SCRIPT.

printstep "Testing 'carthage.yml' Workflow..."

git add . >/dev/null 2>&1
git commit -m "Commit" --no-gpg-sign >/dev/null 2>&1
git tag | xargs git tag -d >/dev/null 2>&1
git tag --no-sign 1.0 >/dev/null 2>&1
checkresult $? "'Create Cartfile' step of 'carthage.yml' workflow failed."

echo "git \"file://$OUTPUT_DIR\"" > ./Cartfile

./scripts/carthage.sh update "${VERBOSE_FLAGS[@]}"
checkresult $? "'Build' step of 'carthage.yml' workflow failed."

printstep "'carthage.yml' Workflow Tests Passed\n"
