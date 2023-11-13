#!/usr/bin/env bash -e -o pipefail
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

# Help

function printhelp() {
    local HELP="Run tests for the Github Action workflows.\n"
    HELP+="\n"
    HELP+="workflowtests.sh [--help | -h] [--verbose] [--project-name <project_name>]\n"
    HELP+="                 [--no-clean | --no-clean-on-fail] [--is-running-in-temp-env]\n"
    HELP+="\n"
    HELP+="--help, -h)               Print this help message and exit.\n"
    HELP+="\n"
    HELP+="--help, -h)               Enable verbose logging.\n"
    HELP+="\n"
    HELP+="--project-name)           The name of the project to run tests against. If not\n"
    HELP+="                          provided it will attempt to be resolved by searching\n"
    HELP+="                          the working directory for an Xcode project and using\n"
    HELP+="                          its name.\n"
    HELP+="\n"
    HELP+="--no-clean)               When not running in a temporary environment, do not\n"
    HELP+="                          clean up the temporary project created to run these\n"
    HELP+="                          tests upon completion.\n"
    HELP+="\n"
    HELP+="--no-clean-on-fail)       Same as --no-clean with the exception that if the\n"
    HELP+="                          succeed clean up will continue as normal. This is\n"
    HELP+="                          mutually exclusive with --no-clean with --no-clean\n"
    HELP+="                          taking precedence.\n"
    HELP+="\n"
    HELP+="--is-running-in-temp-env) Setting this flag tells this script that the\n"
    HELP+="                          environment (directory) in which it is running is a\n"
    HELP+="                          temporary environment and it need not worry about\n"
    HELP+="                          dirtying up the directory or creating/deleting files\n"
    HELP+="                          and folders. USE CAUTION WITH THIS OPTION.\n"
    HELP+="\n"
    HELP+="                          When this flag is NOT set, a copy of the containing\n"
    HELP+="                          working folder is created in a temporary location and\n"
    HELP+="                          removed (unless --no-clean is set) after the tests\n"
    HELP+="                          have finished running."

    IFS='%'
    echo -e "$HELP" 1>&2
    unset IFS

    exit $EXIT_CODE
}

# Parse Arguments

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project-name)
        PROJECT_NAME="$2"
        shift # --project-name
        shift # <project_name>
        ;;

        --is-running-in-temp-env)
        IS_RUNNING_IN_TEMP_ENV=1
        shift # --is-running-in-temp-env
        ;;

        --no-clean)
        NO_CLEAN=1
        shift # --no-clean
        ;;

        --no-clean-on-fail)
        NO_CLEAN_ON_FAIL=1
        shift # --no-clean-on-fail
        ;;

        --verbose)
        VERBOSE=1
        shift # --verbose
        ;;

        --help | -h)
        printhelp
        ;;

        *)
        "$SCRIPTS_DIR/printformat.sh" "foreground:red" "Unknown argument: $1\n" 1>&2
        EXIT_CODE=1
        printhelp
        ;;
    esac
done

if [ -z ${IS_RUNNING_IN_TEMP_ENV+x} ]; then
    IS_RUNNING_IN_TEMP_ENV=0
fi

if [ -z ${NO_CLEAN+x} ]; then
    NO_CLEAN=0
fi

if [ -z ${NO_CLEAN_ON_FAIL+x} ]; then
    NO_CLEAN_ON_FAIL=0
fi

# Function Definitions

function cleanup() {
    if [ "$IS_RUNNING_IN_TEMP_ENV" == "0" ]; then
        if [[ "$NO_CLEAN" == "1" ]] || [[ "$NO_CLEAN_ON_FAIL" == "1" && "$EXIT_CODE" != "0" ]]; then
            echo "Test Project: $OUTPUT_DIR"
        else
            cd "$CURRENT_DIR"
            rm -rf "$TEMP_DIR"
        fi
    fi

    #

    local CARTHAGE_CACHE="$HOME/Library/Caches/org.carthage.CarthageKit"
    if [ -e "$CARTHAGE_CACHE" ]; then
        if [ -e "$CARTHAGE_CACHE/dependencies/$PROJECT_NAME" ]; then
            rm -rf "$CARTHAGE_CACHE/dependencies/$PROJECT_NAME"
        fi

        for DIR in $(find "$CARTHAGE_CACHE/DerivedData" -mindepth 1 -maxdepth 1 -type d); do
            if [ -e "$DIR/$PROJECT_NAME" ]; then
                rm -rf "$DIR/$PROJECT_NAME"
            fi
        done
    fi

    #

    if [ "${#EXIT_MESSAGE}" != 0 ]; then
        if [ "$EXIT_MESSAGE" == "**printhelp**" ]; then
            printhelp
        else
            echo -e "$EXIT_MESSAGE" 1>&2
        fi
    fi

    exit $EXIT_CODE
}

function checkresult() {
    if [ "$1" != "0" ]; then
        if [ "${#2}" != "0" ]; then
            EXIT_MESSAGE="$("$SCRIPTS_DIR/printformat.sh" "foreground:red" "$2")"
        else
            EXIT_MESSAGE="**printhelp**"
        fi

        EXIT_CODE=$1
        cleanup
    fi
}

function printstep() {
    "$SCRIPTS_DIR/printformat.sh" "foreground:green" "$1"
}

function setuptemp() {
    TEMP_DIR="$(mktemp -d)"

    local TEMP_NAME="$(basename "$(mktemp -u "$TEMP_DIR/${PROJECT_NAME}WorkflowTests_XXXXXXXX")")"
    local OUTPUT_DIR="$TEMP_DIR/$TEMP_NAME"

    cp -R "$ROOT_DIR" "$OUTPUT_DIR"
    if [ "$?" != "0" ]; then exit $?; fi

    if [ -e "$OUTPUT_DIR/.build" ]; then
        rm -rf "$OUTPUT_DIR/.build"
    fi
    if [ -e "$OUTPUT_DIR/.swiftpm" ]; then
        rm -rf "$OUTPUT_DIR/.swiftpm"
    fi
    if [ -e "$OUTPUT_DIR/.xcodebuild" ]; then
        rm -rf "$OUTPUT_DIR/.xcodebuild"
    fi

    echo "$OUTPUT_DIR"
}

function createlogfile() {
    if [ ! -d "$OUTPUT_DIR/Logs" ]; then
        mkdir -p "$OUTPUT_DIR/Logs"
    fi

    local LOG="$OUTPUT_DIR/Logs/$1.log"
    touch "$LOG"

    echo "$LOG"
}

function errormessage() {
    local ERROR_MESSAGE="$1"

    if [[ "$NO_CLEAN" == "1" ]] || [[ "$NO_CLEAN_ON_FAIL" == "1" ]]; then
        ERROR_MESSAGE="$("$SCRIPTS_DIR/printformat.sh" "foreground:default" "${1%.}. See log for more details: $("$SCRIPTS_DIR/printformat.sh" "foreground:yellow" "$2")")"
    elif [ "$VERBOSE" != "1" ]; then
        ERROR_MESSAGE="$("$SCRIPTS_DIR/printformat.sh" "foreground:default" "${1%.}. Use the '--no-clean' or '--no-clean-on-fail' flag to inspect the logs.")"
    fi

    echo "$ERROR_MESSAGE"
}

function interrupt() {
    EXIT_CODE=$SIGINT
    EXIT_MESSAGE="$("$SCRIPTS_DIR/printformat.sh" "foreground:yellow" "Tests run was interrupted..")"

    cleanup
}

# Setup

trap interrupt SIGINT # Cleanup if the user aborts (Ctrl + C)

#

ARGUMENTS=()
if [ "${#PROJECT_NAME}" != 0 ]; then
    ARGUMENTS=(--project-name "$PROJECT_NAME")
fi

PROJECT_NAME="$("$SCRIPTS_DIR/findproject.sh" "${ARGUMENTS[@]}")"
checkresult $?

#

VERBOSE_FLAGS=()
if [ "$VERBOSE" == "1" ]; then
    VERBOSE_FLAGS=(--verbose)
fi

#

if [ "$IS_RUNNING_IN_TEMP_ENV" == "1" ]; then
    OUTPUT_DIR="$ROOT_DIR"
else
    OUTPUT_DIR="$(setuptemp)"
    echo -e "Testing from Temporary Directory: $("$SCRIPTS_DIR/printformat.sh" "foreground:yellow" "$OUTPUT_DIR")"
fi

# Check For Dependencies

cd "$OUTPUT_DIR"
printstep "Checking for Test Dependencies..."

### Carthage

if which carthage >/dev/null; then
    CARTHAGE_VERSION="$(carthage version)"
    echo "Carthage: $CARTHAGE_VERSION"

    comparison=$("$SCRIPTS_DIR/versions.sh" "$CARTHAGE_VERSION" "0.37.0"; echo $?)

    if [ "$comparison" -lt 0 ]; then
        "$SCRIPTS_DIR/printformat.sh" "foreground:yellow" "Carthage version of at least 0.37.0 is recommended for running these unit tests"
    fi
else
    checkresult -1 "Carthage is not installed and is required for running unit tests: $("$SCRIPTS_DIR/printformat.sh" "foreground:blue;underline" "https://github.com/Carthage/Carthage#installing-carthage")"
fi

### CocoaPods

if which pod >/dev/null; then
    PODS_VERSION="$(pod --version)"
    comparison=$("$SCRIPTS_DIR/versions.sh" "$PODS_VERSION" "1.7.3"; echo $?)

    if [ "$comparison" -ge 0 ]; then
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

# Run Tests

printstep "Running Tests...\n"

### Carthage Workflow

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

### CocoaPods Workflow

printstep "Testing 'cocoapods.yml' Workflow..."

pod lib lint "${VERBOSE_FLAGS[@]}"
checkresult $? "'Lint (Dynamic)' step of 'cocoapods.yml' workflow failed."

pod lib lint --use-libraries "${VERBOSE_FLAGS[@]}"
checkresult $? "'Lint (Static)' step of 'cocoapods.yml' workflow failed."

printstep "'cocoapods.yml' Workflow Tests Passed\n"

### Documentation Workflow

printstep "Testing 'documentation.yml' Workflow..."

ERROR_MESSAGE="'Build Documentation' step of 'documentation.yml' workflow failed."

if [ "$VERBOSE" == "1" ]; then
    xcodebuild docbuild -project "$PROJECT_NAME.xcodeproj" -scheme "$PROJECT_NAME" -destination "generic/platform=iOS" -derivedDataPath "$OUTPUT_DIR/.xcodebuild" SKIP_SWIFTLINT=YES
else
    LOG="$(createlogfile "build-documentation")"
    ERROR_MESSAGE="$(errormessage "$ERROR_MESSAGE" "$LOG")"

    #

    xcodebuild docbuild -project "$PROJECT_NAME.xcodeproj" -scheme "$PROJECT_NAME" -destination "generic/platform=iOS" -derivedDataPath "$OUTPUT_DIR/.xcodebuild" SKIP_SWIFTLINT=YES > "$LOG" 2>&1
fi

checkresult $? "$ERROR_MESSAGE"

printstep "'documentation.yml' Workflow Tests Passed\n"

### Swift Package Workflow

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

xcrun llvm-cov export --format=lcov --instr-profile=".build/debug/codecov/default.profdata" ".build/debug/${PROJECT_NAME}PackageTests.xctest/Contents/MacOS/${PROJECT_NAME}PackageTests" > "./codecov.lcov"
checkresult $? "'Generate Code Coverage File' step of 'swift-package.yml' workflow failed."

printstep "'swift-package.yml' Workflow Tests Passed\n"

### SwiftLint Workflow

printstep "Testing 'swiftlint.yml' Workflow..."

swiftlint
checkresult $? "'Run SwiftLint' step of 'swiftlint.yml' workflow failed."

printstep "'swiftlint.yml' Workflow Tests Passed\n"

### XCFramework Workflow

printstep "Testing 'xcframework.yml' Workflow..."

./scripts/xcframework.sh --project-name "$PROJECT_NAME" --output "$OUTPUT_DIR" "${VERBOSE_FLAGS[@]}" -- RUN_DOCUMENTATION_COMPILER=NO SKIP_SWIFTLINT=YES
checkresult $? "'Build' step of 'xcframework.yml' workflow failed."

printstep "'xcframework.yml' Workflow Tests Passed\n"

### Upload Assets Workflow

printstep "Testing 'upload-assets.yml' Workflow..."

echo -e "$("$SCRIPTS_DIR/printformat.sh" "foreground:blue" "***") Creating zip archive for $("$SCRIPTS_DIR/printformat.sh" "bold" "$PROJECT_NAME.xcframework")"
zip -rX "$PROJECT_NAME.xcframework.zip" "$PROJECT_NAME.xcframework" >/dev/null 2>&1
checkresult $? "'Create XCFramework Zip' step of 'upload-assets.yml' workflow failed."

echo -e "$("$SCRIPTS_DIR/printformat.sh" "foreground:blue" "***") Creating tar archive for $("$SCRIPTS_DIR/printformat.sh" "bold" "$PROJECT_NAME.xcframework")"
tar -zcvf "$PROJECT_NAME.xcframework.tar.gz" "$PROJECT_NAME.xcframework" >/dev/null 2>&1
checkresult $? "'Create XCFramework Tar' step of 'upload-assets.yml' workflow failed."

#

DOCC_ARCHIVE="$(find "$OUTPUT_DIR/.xcodebuild" -type d -name "$PROJECT_NAME.doccarchive")"

if [ "${DOCC_ARCHIVE[@]]}" == "0" ]; then
    checkresult 1 "'Build Documentation' step of 'upload-assets.yml' workflow failed."
else
    mv "${DOCC_ARCHIVE%/}" "$OUTPUT_DIR/$PROJECT_NAME.doccarchive"
    checkresult $? "'Build Documentation' step of 'upload-assets.yml' workflow failed."
fi

#

echo -e "$("$SCRIPTS_DIR/printformat.sh" "foreground:blue" "***") Creating zip archive for $("$SCRIPTS_DIR/printformat.sh" "bold" "$PROJECT_NAME.doccarchive")"
zip -rX "$PROJECT_NAME.doccarchive.zip" "$PROJECT_NAME.doccarchive" >/dev/null 2>&1
checkresult $? "'Create Documentation Zip' step of 'upload-assets.yml' workflow failed."

echo -e "$("$SCRIPTS_DIR/printformat.sh" "foreground:blue" "***") Creating tar archive for $("$SCRIPTS_DIR/printformat.sh" "bold" "$PROJECT_NAME.doccarchive")"
tar -zcvf "$PROJECT_NAME.doccarchive.tar.gz" "$PROJECT_NAME.doccarchive" >/dev/null 2>&1
checkresult $? "'Create Documentation Tar' step of 'upload-assets.yml' workflow failed."

printstep "'upload-assets.yml' Workflow Tests Passed\n"

### Xcodebuild Workflow

printstep "Testing 'xcodebuild.yml' Workflow..."

#

for PLATFORM in "iOS" "iOS Simulator" "Mac Catalyst" "macOS" "tvOS" "tvOS Simulator" "watchOS" "watchOS Simulator"; do
    echo -e "$("$SCRIPTS_DIR/printformat.sh" "foreground:blue" "***") Building $("$SCRIPTS_DIR/printformat.sh" "foreground:green" "$PLATFORM") in $("$SCRIPTS_DIR/printformat.sh" "bold" "$PROJECT_NAME.xcodeproj")"

    SCHEME="${PROJECT_NAME}"
    DESTINATION="$PLATFORM"

    case "$PLATFORM" in
        "Mac Catalyst") DESTINATION="macOS,variant=Mac Catalyst" ;;
        "macOS") SCHEME="${PROJECT_NAME} macOS" ;;

        "tvOS") SCHEME="${PROJECT_NAME} tvOS" ;;
        "tvOS Simulator") SCHEME="${PROJECT_NAME} tvOS" ;;

        "watchOS") SCHEME="${PROJECT_NAME} watchOS" ;;
        "watchOS Simulator") SCHEME="${PROJECT_NAME} watchOS" ;;
    esac

    #

    ERROR_MESSAGE="'Build $PLATFORM' step of 'xcodebuild.yml' workflow failed."

    if [ "$VERBOSE" == "1" ]; then
        xcodebuild -project "$PROJECT_NAME.xcodeproj" -scheme "$SCHEME" -destination "generic/platform=$DESTINATION" -configuration Debug RUN_DOCUMENTATION_COMPILER=NO SKIP_SWIFTLINT=YES
    else
        LOG="$(createlogfile "$(echo "$PLATFORM" | tr -d ' ' | tr '[:upper:]' '[:lower:]')-build")"
        ERROR_MESSAGE="$(errormessage "$ERROR_MESSAGE" "$LOG")"

        #

        xcodebuild -project "$PROJECT_NAME.xcodeproj" -scheme "$SCHEME" -destination "generic/platform=$DESTINATION" -configuration Debug RUN_DOCUMENTATION_COMPILER=NO SKIP_SWIFTLINT=YES > "$LOG" 2>&1
    fi

    checkresult $? "$ERROR_MESSAGE"
done

echo ""

#

IOS_SIM="$(xcrun simctl list devices available | grep "iPhone [0-9]" | sort -rV | head -n 1 | sed -E 's/(.+)[ ]*\([^)]*\)[ ]*\([^)]*\)/\1/' | awk '{$1=$1};1')"
TVOS_SIM="$(xcrun simctl list devices available | grep "Apple TV" | sort -V | head -n 1 | sed -E 's/(.+)[ ]*\([^)]*\)[ ]*\([^)]*\)/\1/' | awk '{$1=$1};1')"
WATCHOS_SIM="$(xcrun simctl list devices available | grep "Apple Watch" | sort -rV | head -n 1 | sed -E 's/(.+)[ ]*\([^)]*\)[ ]*\([^)]*\)/\1/' | awk '{$1=$1};1')"

#

for PLATFORM in "iOS" "Mac Catalyst" "macOS" "tvOS" "watchOS"; do
    echo -e "$("$SCRIPTS_DIR/printformat.sh" "foreground:blue" "***") Testing $("$SCRIPTS_DIR/printformat.sh" "foreground:green" "$PLATFORM") in $("$SCRIPTS_DIR/printformat.sh" "bold" "$PROJECT_NAME.xcodeproj")"

    SCHEME="${PROJECT_NAME}"
    TESTPLAN="${PROJECT_NAME}Tests"
    DESTINATION="$PLATFORM"

    case "$PLATFORM" in
        "iOS") DESTINATION="iOS Simulator,name=$IOS_SIM" ;;
        "Mac Catalyst") DESTINATION="macOS,variant=Mac Catalyst" ;;

        "macOS")
        SCHEME="$PROJECT_NAME macOS"
        TESTPLAN="$PROJECT_NAME macOS Tests"
        ;;

        "tvOS")
        SCHEME="$PROJECT_NAME tvOS"
        TESTPLAN="$PROJECT_NAME tvOS Tests"
        DESTINATION="tvOS Simulator,name=$TVOS_SIM"
        ;;

        "watchOS")
        SCHEME="$PROJECT_NAME watchOS"
        TESTPLAN="$PROJECT_NAME watchOS Tests"
        DESTINATION="watchOS Simulator,name=$WATCHOS_SIM"
        ;;
    esac

    #

    ERROR_MESSAGE="'Test $PLATFORM' step of 'xcodebuild.yml' workflow failed."

    if [ "$VERBOSE" == "1" ]; then
        xcodebuild -project "$PROJECT_NAME.xcodeproj" -scheme "$SCHEME" -testPlan "$TESTPLAN" -destination "platform=$DESTINATION" -configuration Debug RUN_DOCUMENTATION_COMPILER=NO SKIP_SWIFTLINT=YES ONLY_ACTIVE_ARCH=YES test
    else
        LOG="$(createlogfile "$(echo "$PLATFORM" | tr -d ' ' | tr '[:upper:]' '[:lower:]')-test")"
        ERROR_MESSAGE="$(errormessage "$ERROR_MESSAGE" "$LOG")"

        xcodebuild -project "$PROJECT_NAME.xcodeproj" -scheme "$SCHEME" -testPlan "$TESTPLAN" -destination "platform=$DESTINATION" -configuration Debug RUN_DOCUMENTATION_COMPILER=NO SKIP_SWIFTLINT=YES ONLY_ACTIVE_ARCH=YES test > "$LOG" 2>&1
    fi

    checkresult $? "$ERROR_MESSAGE"
done

printstep "'xcodebuild.yml' Workflow Tests Passed\n"

### Test Schemes

printstep "Test running unit tests with test schemes..."

for PLATFORM in "iOS" "Mac Catalyst" "macOS" "tvOS" "watchOS"; do
    echo -e "$("$SCRIPTS_DIR/printformat.sh" "foreground:blue" "***") Testing $("$SCRIPTS_DIR/printformat.sh" "foreground:green" "$PLATFORM") in $("$SCRIPTS_DIR/printformat.sh" "bold" "$PROJECT_NAME.xcodeproj")"

    SCHEME="${PROJECT_NAME}Tests"
    DESTINATION="$PLATFORM"

    case "$PLATFORM" in
        "iOS") DESTINATION="iOS Simulator,name=$IOS_SIM" ;;
        "Mac Catalyst") DESTINATION="macOS,variant=Mac Catalyst" ;;
        "macOS") SCHEME="$PROJECT_NAME macOS Tests" ;;

        "tvOS")
        SCHEME="$PROJECT_NAME tvOS Tests"
        DESTINATION="tvOS Simulator,name=$TVOS_SIM"
        ;;

        "watchOS")
        SCHEME="$PROJECT_NAME watchOS Tests"
        DESTINATION="watchOS Simulator,name=$WATCHOS_SIM"
        ;;
    esac

    #

    ERROR_MESSAGE="Test $PLATFORM (Test Scheme) failed."

    if [ "$VERBOSE" == "1" ]; then
        xcodebuild -project "$PROJECT_NAME.xcodeproj" -scheme "$SCHEME" -testPlan "$SCHEME" -destination "platform=$DESTINATION" -configuration Debug RUN_DOCUMENTATION_COMPILER=NO SKIP_SWIFTLINT=YES ONLY_ACTIVE_ARCH=YES test
    else
        LOG="$(createlogfile "$(echo "$PLATFORM" | tr -d ' ' | tr '[:upper:]' '[:lower:]')-test")"
        ERROR_MESSAGE="$(errormessage "$ERROR_MESSAGE" "$LOG")"

        xcodebuild -project "$PROJECT_NAME.xcodeproj" -scheme "$SCHEME" -testPlan "$SCHEME" -destination "platform=$DESTINATION" -configuration Debug RUN_DOCUMENTATION_COMPILER=NO SKIP_SWIFTLINT=YES ONLY_ACTIVE_ARCH=YES test > "$LOG" 2>&1
    fi

    checkresult $? "$ERROR_MESSAGE"
done

printstep "Test Scheme Unit Tests Passed\n"

### Success

cleanup
