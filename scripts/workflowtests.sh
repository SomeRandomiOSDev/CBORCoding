#!/usr/bin/env bash
#
# workflowtests.sh
# Usage example: ./workflowtests.sh --no-clean

# Set Script Variables

SCRIPT="$("$(dirname "$0")/resolvepath.sh" "$0")"
SCRIPTS_DIR="$(dirname "$SCRIPT")"
ROOT_DIR="$(dirname "$SCRIPTS_DIR")"
CURRENT_DIR="$(pwd -P)"

EXIT_CODE=0
EXIT_MESSAGE=""

# Import Helper Functions

source "$SCRIPTS_DIR/workflowtests/helper_functions.sh"

# Parse Arguments

source "$SCRIPTS_DIR/workflowtests/parse_arguments.sh"

# Setup

trap interrupt SIGINT # Cleanup if the user aborts (Ctrl + C)

# Check For Dependencies

source "$SCRIPTS_DIR/workflowtests/check_dependencies.sh"

# Run Tests

printstep "Running Tests...\n"

# Carthage
source "$SCRIPTS_DIR/workflowtests/carthage_tests.sh"

# Cocoapods
source "$SCRIPTS_DIR/workflowtests/cocoapods_tests.sh"

# Documentation
source "$SCRIPTS_DIR/workflowtests/documentation_tests.sh"

# Swift Package
source "$SCRIPTS_DIR/workflowtests/swift_package_tests.sh"

# SwiftLint
source "$SCRIPTS_DIR/workflowtests/swiftlint_tests.sh"

# XCFramework
source "$SCRIPTS_DIR/workflowtests/xcframework_tests.sh"

# Upload Assets
source "$SCRIPTS_DIR/workflowtests/upload_assets_tests.sh"

# Xcodebuild
printstep "Testing 'xcodebuild.yml' Workflow..."

#source "$SCRIPTS_DIR/workflowtests/xcodebuild_build_tests.sh"
source "$SCRIPTS_DIR/workflowtests/xcodebuild_test_tests.sh"

printstep "'xcodebuild.yml' Workflow Tests Passed\n"

# Test Schemes
source "$SCRIPTS_DIR/workflowtests/test_scheme_tests.sh"

### Success

cleanup
