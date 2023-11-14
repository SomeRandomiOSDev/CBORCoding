#!/usr/bin/env bash
#
# workflowtests/swift_package_tests.sh

# THE INTENT OF THIS FILE IS TO BE IMPORTED DIRECTLY BY THE 'WORKFLOWTESTS.SH'
# FILE. THIS SHOULD RAN DIRECTLY OR IMPORTED BY ANY OTHER BASH SCRIPT.

printstep "Testing 'swift-package.yml' Workflow..."

if [ "$VERBOSE" == "1" ]; then
    echo -e "$("$SCRIPTS_DIR/printformat.sh" "foreground:blue" "***") Building Swift Package from $("$SCRIPTS_DIR/printformat.sh" "bold" "Package.swift")"
    swift build "${VERBOSE_FLAGS[@]}"
    checkresult $? "'Build' step of 'swift-package.yml' workflow failed."

    echo -e "$("$SCRIPTS_DIR/printformat.sh" "foreground:blue" "***") Testing Swift Package from $("$SCRIPTS_DIR/printformat.sh" "bold" "Package.swift")"
    swift test --enable-code-coverage "${VERBOSE_FLAGS[@]}"
    checkresult $? "'Test' step of 'swift-package.yml' workflow failed."
else
    LOG="$(createlogfile "build-swiftpackage")"

    echo -e "$("$SCRIPTS_DIR/printformat.sh" "foreground:blue" "***") Building Swift Package from $("$SCRIPTS_DIR/printformat.sh" "bold" "Package.swift")"
    swift build > "$LOG" 2>&1
    checkresult $? "$(errormessage "'Build' step of 'swift-package.yml' workflow failed." "$LOG")"

    #

    LOG="$(createlogfile "test-swiftpackage")"

    echo -e "$("$SCRIPTS_DIR/printformat.sh" "foreground:blue" "***") Testing Swift Package from $("$SCRIPTS_DIR/printformat.sh" "bold" "Package.swift")"
    swift test --enable-code-coverage > "$LOG" 2>&1
    checkresult $? "$(errormessage "'Test' step of 'swift-package.yml' workflow failed." "$LOG")"
fi

xcrun llvm-cov export --format=lcov --instr-profile=".build/debug/codecov/default.profdata" ".build/debug/${PRODUCT_NAME}PackageTests.xctest/Contents/MacOS/${PRODUCT_NAME}PackageTests" > "./codecov.lcov"
checkresult $? "'Generate Code Coverage File' step of 'swift-package.yml' workflow failed."

printstep "'swift-package.yml' Workflow Tests Passed\n"
