#!/usr/bin/env bash
#
# xcframework.sh
# Usage example: ./xcframework.sh --output <some_path>/<name>.xcframework

# Set Script Variables

SCRIPT="$("$(dirname "$0")/resolvepath.sh" "$0")"
SCRIPTS_DIR="$(dirname "$SCRIPT")"
ROOT_DIR="$(dirname "$SCRIPTS_DIR")"
CURRENT_DIR="$(pwd -P)"

IS_PARSING_BUILD_ARGS=0
BUILD_ARGS=()

EXIT_CODE=0

# Help

function printhelp() {
    local HELP="Builds an XCFramework for the given project.\n"
    HELP+="\n"
    HELP+="xcframework.sh [--help | -h] [--output (<output_framework> | <output_folder>)]\n"
    HELP+="               [--configuration <configuration>] [--project-name <project_name>]\n"
    HELP+="               [--exclude-dsyms] [--verbose] [--no-clean | --no-clean-on-fail]\n"
    HELP+="xcframework.sh [options] -- <build_flags> ...\n"
    HELP+="\n"
    HELP+="OPTIONS:\n"
    HELP+="\n"
    HELP+="--help, -h)         Print this help message and exit.\n"
    HELP+="\n"
    HELP+="--verbose)          Enable verbose logging. If enabled, no logs are created and\n"
    HELP+="                    hence the '--no-clean' and '--no-clean-on-fail' flags are\n"
    HELP+="                    moot.\n"
    HELP+="\n"
    HELP+="--output)           The directory or fully qualified path to export the\n"
    HELP+="                    generated XCFramework to. If not specified, this defaults to\n"
    HELP+="                    \"<scripts_dir>/build/<project_name>.xcframework\"\n"
    HELP+="\n"
    HELP+="--configuration)    The configuration to use when building each scheme. This is\n"
    HELP+="                    passed directly to 'xcodebuild' without modification. If not\n"
    HELP+="                    specified, this defaults to \"Release\".\n"
    HELP+="\n"
    HELP+="--project-name)     The name of the project to run tests against. If not\n"
    HELP+="                    provided it will attempt to be resolved by searching the\n"
    HELP+="                    working directory for an Xcode project and using its name.\n"
    HELP+="\n"
    HELP+="--exclude-dsyms)    Do not include the generated dSYMs nor BCSymbolMaps in the\n"
    HELP+="                    final XCFramework.\n"
    HELP+="\n"
    HELP+="--no-clean)         Do not clean up the logs created to run these tests upon\n"
    HELP+="                    completion.\n"
    HELP+="\n"
    HELP+="--no-clean-on-fail) Same as --no-clean with the exception that if the succeed\n"
    HELP+="                    clean up will continue as normal. This is mutually exclusive\n"
    HELP+="                    with --no-clean, with --no-clean taking precedence.\n"
    HELP+="\n"
    HELP+="--build-dir)        The directory in which to store temporary build artifacts\n"
    HELP+="                    and logs. The directory will be created if needed. If\n"
    HELP+="                    specified this directory will not be deleted when the\n"
    HELP+="                    script finishes running.\n"
    HELP+="\n"
    HELP+="ARGUMENTS:\n"
    HELP+="\n"
    HELP+="<build_flags>       Any arguments that appear after a '--' argument are treated\n"
    HELP+="                    as Xcode build arguments and are passed as is to 'xcodebuild'\n"
    HELP+="                    when building the architectures for the XCFramework.\n"

    IFS='%'
    echo -e "$HELP" 1>&2
    unset IFS

    exit $EXIT_CODE
}

# Parse Arguments

while [[ $# -gt 0 ]]; do
    if [ "$IS_PARSING_BUILD_ARGS" == "1" ]; then
        BUILD_ARGS=("${BUILD_ARGS[@]}" "$1")
        shift
    else
        case "$1" in
            --output)
            OUTPUT="$2"
            shift # --output
            shift # <project_name>
            ;;

            --configuration)
            CONFIGURATION="$2"
            shift # --configuration
            shift # <configuration>
            ;;

            --project-name)
            PROJECT_NAME="$2"
            shift # --project-name
            shift # <project_name>
            ;;

            --exclude-dsyms)
            EXCLUDE_DSYMS=1
            shift # --exclude-dsyms
            ;;

            --no-clean)
            NO_CLEAN=1
            shift # --no-clean
            ;;

            --no-clean-on-fail)
            NO_CLEAN_ON_FAIL=1
            shift # --no-clean-on-fail
            ;;

            --build-dir)
            BUILD_DIR="$2"
            shift # --build-dir
            shift # <build_dir>
            ;;

            --verbose)
            VERBOSE=1
            shift # --verbose
            ;;

            --help | -h)
            printhelp
            ;;

            --)
            IS_PARSING_BUILD_ARGS=1
            shift # --
            ;;

            *)
            "$SCRIPTS_DIR/printformat.sh" "foreground:red" "Unknown argument: $1\n" 1>&2
            EXIT_CODE=1
            printhelp
            ;;
        esac
    fi
done

#

ARGUMENTS=()
if [ "${#PROJECT_NAME}" != 0 ]; then
    ARGUMENTS=(--project-name "$PROJECT_NAME")
fi

PROJECT_NAME="$("$SCRIPTS_DIR/findproject.sh" "${ARGUMENTS[@]}")"
EXIT_CODE=$?

if [ "$EXIT_CODE" != "0" ]; then
    printhelp
fi

#

if [ -z ${OUTPUT+x} ]; then
    OUTPUT="$SCRIPTS_DIR/build/$PROJECT_NAME.xcframework"
elif [ "${OUTPUT##*.}" != "xcframework" ]; then
    if [ "${OUTPUT: -1}" == "/" ]; then
        OUTPUT="${OUTPUT}${PROJECT_NAME}.xcframework"
    else
        OUTPUT="${OUTPUT}/${PROJECT_NAME}.xcframework"
    fi
fi

if [ -z ${CONFIGURATION+x} ]; then
    CONFIGURATION="Release"
fi

if [ -z ${BUILD_DIR+x} ]; then
    BUILD_DIR="$(mktemp -d -t ".$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]').xcframework.build")"
    BUILD_DIR_IS_TEMP=1
else
    mkdir -p "$BUILD_DIR"
    EXIT_CODE=$?

    if [ "$EXIT_CODE" != "0" ]; then
        "$SCRIPTS_DIR/printformat.sh" "foreground:red" "Unable to create build directory: $BUILD_DIR"
        exit $EXIT_CODE
    fi
fi

# Function Declarations

function cleanup() {
    cd "$CURRENT_DIR"
    if [[ "$VERBOSE" != "1" && "$BUILD_DIR_IS_TEMP" == "1" && ("$NO_CLEAN" == "1" || ("$NO_CLEAN_ON_FAIL" == "1" && "$EXIT_CODE" != "0")) ]]; then
        if [ "$EXIT_CODE" == "0" ]; then
            "$SCRIPTS_DIR/printformat.sh" "foreground:yellow" "Build Directory: $BUILD_DIR"
        fi
    elif [ "$BUILD_DIR_IS_TEMP" == "1" ]; then
        rm -rf "$BUILD_DIR"
    fi

    #

    if [ "${#EXIT_MESSAGE}" != 0 ]; then
        echo -e "$EXIT_MESSAGE" 1>&2
    fi

    exit $EXIT_CODE
}

function checkresult() {
    if [ "$1" != "0" ]; then
        if [ "${#2}" != "0" ]; then
            EXIT_MESSAGE="$("$SCRIPTS_DIR/printformat.sh" "foreground:red" "$2")"
        fi

        EXIT_CODE=$1
        cleanup
    fi
}

function createlogfile() {
    if [ ! -d "$BUILD_DIR/Logs" ]; then
        mkdir -p "$BUILD_DIR/Logs"
    fi

    local LOG="$BUILD_DIR/Logs/$1.log"
    touch "$LOG"

    echo "$LOG"
}

function errormessage() {
    local ERROR_MESSAGE=""

    if [[ "$NO_CLEAN" == "1" ]] || [[ "$NO_CLEAN_ON_FAIL" == "1" ]]; then
        ERROR_MESSAGE="$("$SCRIPTS_DIR/printformat.sh" "foreground:default" "Build Failed. See xcodebuild log for more details: $("$SCRIPTS_DIR/printformat.sh" "foreground:yellow" "$1")")"
    elif [ "$VERBOSE" != "1" ]; then
        ERROR_MESSAGE="$("$SCRIPTS_DIR/printformat.sh" "foreground:default" "Build Failed. Use the '--no-clean' or '--no-clean-on-fail' flag to inspect the logs.")"
    fi

    echo "$ERROR_MESSAGE"
}

# Build Platforms

cd "$ROOT_DIR"

#

for PLATFORM in "iOS" "iOS Simulator" "Mac Catalyst" "macOS" "tvOS" "tvOS Simulator" "watchOS" "watchOS Simulator"; do
    echo -e "$("$SCRIPTS_DIR/printformat.sh" "foreground:blue" "***") Building $("$SCRIPTS_DIR/printformat.sh" "foreground:green" "$PLATFORM") architecture(s) of $("$SCRIPTS_DIR/printformat.sh" "bold" "${PROJECT_NAME}.xcodeproj")"

    SCHEME="${PROJECT_NAME}"
    ARCHIVE=""
    ARCHS=""

    case "$PLATFORM" in
        "iOS")
        ARCHS="armv7 armv7s arm64 arm64e"
        ARCHIVE="iphoneos"
        ;;

        "iOS Simulator")
        ARCHS="i386 x86_64 arm64"
        ARCHIVE="iphonesimulator"
        ;;

        "Mac Catalyst")
        PLATFORM="macOS,variant=Mac Catalyst"
        ARCHS="x86_64 arm64 arm64e"
        ARCHIVE="maccatalyst"
        ;;

        "macOS")
        SCHEME="${PROJECT_NAME} macOS"
        ARCHS="x86_64 arm64 arm64e"
        ARCHIVE="macos"
        ;;

        "tvOS")
        SCHEME="${PROJECT_NAME} tvOS"
        ARCHS="arm64 arm64e"
        ARCHIVE="appletvos"
        ;;

        "tvOS Simulator")
        SCHEME="${PROJECT_NAME} tvOS"
        ARCHS="x86_64 arm64"
        ARCHIVE="appletvsimulator"
        ;;

        "watchOS")
        SCHEME="${PROJECT_NAME} watchOS"
        ARCHS="arm64_32 armv7k"
        ARCHIVE="watchos"
        ;;

        "watchOS Simulator")
        SCHEME="${PROJECT_NAME} watchOS"
        ARCHS="i386 x86_64 arm64"
        ARCHIVE="watchsimulator"
        ;;
    esac

    ERROR_MESSAGE=""

    #

    if [ "$VERBOSE" == "1" ]; then
        xcodebuild -project "${PROJECT_NAME}.xcodeproj" -scheme "$SCHEME" -destination "generic/platform=$PLATFORM" -archivePath "${BUILD_DIR}/$ARCHIVE.xcarchive" -configuration ${CONFIGURATION} SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES ONLY_ACTIVE_ARCH=NO ARCHS="$ARCHS" "${BUILD_ARGS[@]}" archive
    else
        LOG="$(createlogfile "$ARCHIVE-build")"
        ERROR_MESSAGE="$(errormessage "$LOG")"

        #

        xcodebuild -project "${PROJECT_NAME}.xcodeproj" -scheme "$SCHEME" -destination "generic/platform=$PLATFORM" -archivePath "${BUILD_DIR}/$ARCHIVE.xcarchive" -configuration ${CONFIGURATION} SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES ONLY_ACTIVE_ARCH=NO ARCHS="$ARCHS" "${BUILD_ARGS[@]}" archive > "$LOG" 2>&1
    fi

    checkresult $? "$ERROR_MESSAGE"
done

# Make XCFramework

if [[ -d "${OUTPUT}" ]]; then
    rm -rf "${OUTPUT}"
fi

ARGUMENTS=(-create-xcframework -output "${OUTPUT}")

for ARCHIVE in ${BUILD_DIR}/*.xcarchive; do
    ARGUMENTS=(${ARGUMENTS[@]} -framework "${ARCHIVE}/Products/Library/Frameworks/${PROJECT_NAME}.framework")

    if [ "$EXCLUDE_DSYMS" != "1" ]; then
        if [[ -d "${ARCHIVE}/dSYMs/${PROJECT_NAME}.framework.dSYM" ]]; then
            ARGUMENTS=(${ARGUMENTS[@]} -debug-symbols "${ARCHIVE}/dSYMs/${PROJECT_NAME}.framework.dSYM")
        fi

        if [[ -d "${ARCHIVE}/BCSymbolMaps" ]]; then
            for SYMBOLMAP in ${ARCHIVE}/BCSymbolMaps/*.bcsymbolmap; do
                ARGUMENTS=(${ARGUMENTS[@]} -debug-symbols "${SYMBOLMAP}")
            done
        fi
    fi
done

#

echo -e "$("$SCRIPTS_DIR/printformat.sh" "foreground:blue" "***") Generating final XCFramework"

LOG="$(createlogfile "create-xcframework")"
ERROR_MESSAGE="$(errormessage "$LOG")"

xcodebuild "${ARGUMENTS[@]}"
checkresult $? "$ERROR_MESSAGE"

# Cleanup

cleanup
