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
    HELP+="--workspace-name)   The name of the workspace to run tests against. If not\n"
    HELP+="                    provided it will attempt to be resolved by searching the\n"
    HELP+="                    working directory for an Xcode workspace and using its name.\n"
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

            --workspace-name)
            WORKSPACE_NAME="$2"
            shift # --workspace-name
            shift # <workspace_name>
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

if [ "${#WORKSPACE_NAME}" != 0 ]; then
    USE_WORKSPACE=1
    WORKSPACE_NAME="$("$SCRIPTS_DIR/findworkspace.sh" --workspace-name "$WORKSPACE_NAME")"

    checkresult $?
elif [ "${#PROJECT_NAME}" != 0 ]; then
    USE_WORKSPACE=0
    PROJECT_NAME="$("$SCRIPTS_DIR/findproject.sh" --project-name "$PROJECT_NAME")"

    checkresult $?
else
    WORKSPACE_NAME="$("$SCRIPTS_DIR/findworkspace.sh")" 2> /dev/null
    RESULT=$?

    if [[ "$RESULT" == 0 ]] && [[ "${#WORKSPACE_NAME}" != 0 ]]; then
        USE_WORKSPACE=1
    else
        PROJECT_NAME="$("$SCRIPTS_DIR/findproject.sh")" 2> /dev/null
        RESULT=$?

        if [[ "$RESULT" == 0 ]] && [[ "${#PROJECT_NAME}" != 0 ]]; then
            USE_WORKSPACE=0
        else
            checkresult 1 "Unable to find specific Xcode project or workspace in the root directory. Try specifying a project or workspace name:\n"
        fi
    fi
fi

if [ "$USE_WORKSPACE" == "1" ]; then
    PRODUCT_NAME="$WORKSPACE_NAME"
    FULL_PRODUCT_NAME="$WORKSPACE_NAME.xcworkspace"
    XCODEBUILD_ARGS=(-workspace "$FULL_PRODUCT_NAME")
else
    PRODUCT_NAME="$PROJECT_NAME"
    FULL_PRODUCT_NAME="$PROJECT_NAME.xcodeproj"
    XCODEBUILD_ARGS=(-project "$FULL_PRODUCT_NAME")
fi

EXIT_CODE=$?

if [ "$EXIT_CODE" != "0" ]; then
    printhelp
fi

#

if [ -z ${OUTPUT+x} ]; then
    OUTPUT="$SCRIPTS_DIR/build/$PRODUCT_NAME.xcframework"
elif [ "${OUTPUT##*.}" != "xcframework" ]; then
    if [ "${OUTPUT: -1}" == "/" ]; then
        OUTPUT="${OUTPUT}${PRODUCT_NAME}.xcframework"
    else
        OUTPUT="${OUTPUT}/${PRODUCT_NAME}.xcframework"
    fi
fi

mkdir -p "$(dirname "${OUTPUT}")"

if [ -z ${CONFIGURATION+x} ]; then
    CONFIGURATION="Release"
fi

if [ -z ${BUILD_DIR+x} ]; then
    BUILD_DIR="$(mktemp -d -t ".$(echo "$PRODUCT_NAME" | tr '[:upper:]' '[:lower:]').xcframework.build")"
    BUILD_DIR_IS_TEMP=1
else
    mkdir -p "$BUILD_DIR"
    EXIT_CODE=$?

    if [ "$EXIT_CODE" != "0" ]; then
        "$SCRIPTS_DIR/printformat.sh" "foreground:red" "Unable to create build directory: $BUILD_DIR"
        exit $EXIT_CODE
    fi
fi

# Build Platforms

cd "$ROOT_DIR"

#

for PLATFORM in "iOS" "iOS Simulator" "Mac Catalyst" "macOS" "tvOS" "tvOS Simulator" "watchOS" "watchOS Simulator"; do
    echo -e "$("$SCRIPTS_DIR/printformat.sh" "foreground:blue" "***") Building $("$SCRIPTS_DIR/printformat.sh" "foreground:green" "$PLATFORM") architecture(s) of $("$SCRIPTS_DIR/printformat.sh" "bold" "$FULL_PRODUCT_NAME")"

    SCHEME="${PRODUCT_NAME}"
    ARCHIVE=""
    ARCHS=""

    case "$PLATFORM" in
        "iOS")
        ARCHS="arm64 arm64e"
        ARCHIVE="iphoneos"
        ;;

        "iOS Simulator")
        ARCHS="x86_64 arm64"
        ARCHIVE="iphonesimulator"
        ;;

        "Mac Catalyst")
        PLATFORM="macOS,variant=Mac Catalyst"
        ARCHS="x86_64 arm64 arm64e"
        ARCHIVE="maccatalyst"
        ;;

        "macOS")
        SCHEME="${SCHEME} macOS"
        ARCHS="x86_64 arm64 arm64e"
        ARCHIVE="macos"
        ;;

        "tvOS")
        SCHEME="${SCHEME} tvOS"
        ARCHS="arm64 arm64e"
        ARCHIVE="appletvos"
        ;;

        "tvOS Simulator")
        SCHEME="${SCHEME} tvOS"
        ARCHS="x86_64 arm64"
        ARCHIVE="appletvsimulator"
        ;;

        "watchOS")
        SCHEME="${SCHEME} watchOS"
        ARCHS="arm64 arm64e arm64_32 armv7k"
        ARCHIVE="watchos"
        ;;

        "watchOS Simulator")
        SCHEME="${SCHEME} watchOS"
        ARCHS="x86_64 arm64"
        ARCHIVE="watchsimulator"
        ;;
    esac

    ERROR_MESSAGE=""

    #

    if [ "$VERBOSE" == "1" ]; then
        xcodebuild "${XCODEBUILD_ARGS[@]}" -scheme "$SCHEME" -destination "generic/platform=$PLATFORM" -archivePath "${BUILD_DIR}/$ARCHIVE.xcarchive" -configuration ${CONFIGURATION} SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES ONLY_ACTIVE_ARCH=NO ARCHS="$ARCHS" "${BUILD_ARGS[@]}" archive
    else
        LOG="$(createlogfile "$ARCHIVE-build")"
        ERROR_MESSAGE="$(errormessage "$LOG")"

        #

        xcodebuild "${XCODEBUILD_ARGS[@]}" -scheme "$SCHEME" -destination "generic/platform=$PLATFORM" -archivePath "${BUILD_DIR}/$ARCHIVE.xcarchive" -configuration ${CONFIGURATION} SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES ONLY_ACTIVE_ARCH=NO ARCHS="$ARCHS" "${BUILD_ARGS[@]}" archive > "$LOG" 2>&1
    fi

    checkresult $? "$ERROR_MESSAGE"
done

# Make XCFramework

if [[ -d "${OUTPUT}" ]]; then
    rm -rf "${OUTPUT}"
fi

ARGUMENTS=(-create-xcframework -output "$(readlink -f "$(dirname "${OUTPUT}")")/$(basename "${OUTPUT}")")

for ARCHIVE in ${BUILD_DIR}/*.xcarchive; do
    ARGUMENTS=(${ARGUMENTS[@]} -framework "$(readlink -f "${ARCHIVE}/Products/Library/Frameworks/${PRODUCT_NAME}.framework")")

    if [ "$EXCLUDE_DSYMS" != "1" ]; then
        if [[ -d "${ARCHIVE}/dSYMs/${PRODUCT_NAME}.framework.dSYM" ]]; then
            ARGUMENTS=(${ARGUMENTS[@]} -debug-symbols "$(readlink -f "${ARCHIVE}/dSYMs/${PRODUCT_NAME}.framework.dSYM")")
        fi

        if [[ -d "${ARCHIVE}/BCSymbolMaps" ]]; then
            for SYMBOLMAP in ${ARCHIVE}/BCSymbolMaps/*.bcsymbolmap; do
                ARGUMENTS=(${ARGUMENTS[@]} -debug-symbols "$(readlink -f "${SYMBOLMAP}")")
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
