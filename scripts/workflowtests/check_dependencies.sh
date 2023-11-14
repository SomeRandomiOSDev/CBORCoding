#!/usr/bin/env bash
#
# workflowtests/check_dependencies.sh

# THE INTENT OF THIS FILE IS TO BE IMPORTED DIRECTLY BY THE 'WORKFLOWTESTS.SH'
# FILE. THIS SHOULD RAN DIRECTLY OR IMPORTED BY ANY OTHER BASH SCRIPT.

cd "$OUTPUT_DIR"
printstep "Checking for Test Dependencies..."

### Carthage

if which carthage >/dev/null; then
    CARTHAGE_VERSION="$(carthage version)"
    echo "Carthage: $CARTHAGE_VERSION"

    "$SCRIPTS_DIR/versions.sh" "$CARTHAGE_VERSION" "0.37.0"

    if [ $? -lt 0 ]; then
        "$SCRIPTS_DIR/printformat.sh" "foreground:yellow" "Carthage version of at least 0.37.0 is recommended for running these unit tests"
    fi
else
    checkresult -1 "Carthage is not installed and is required for running unit tests: $("$SCRIPTS_DIR/printformat.sh" "foreground:blue;underline" "https://github.com/Carthage/Carthage#installing-carthage")"
fi

### CocoaPods

if which pod >/dev/null; then
    PODS_VERSION="$(pod --version)"
    "$SCRIPTS_DIR/versions.sh" "$PODS_VERSION" "1.7.3"

    if [ $? -ge 0 ]; then
        echo "CocoaPods: $PODS_VERSION"
    else
        checkresult -1 "These unit tests require version 1.7.3 or later of CocoaPods: $("$SCRIPTS_DIR/printformat.sh" "foreground:blue;underline" "https://guides.cocoapods.org/using/getting-started.html#updating-cocoapods")"
    fi
else
    checkresult -1 "CocoaPods is not installed and is required for running unit tests: $("$SCRIPTS_DIR/printformat.sh" "foreground:blue;underline" "https://guides.cocoapods.org/using/getting-started.html#installation")"
fi

### SwiftLint

if which swiftlint >/dev/null; then
    echo "SwiftLint: $(swiftlint --version)"
else
    checkresult -1 "SwiftLint is not installed and is required for running unit tests: $("$SCRIPTS_DIR/printformat.sh" "foreground:blue;underline" "https://github.com/realm/SwiftLint#installation")"
fi
