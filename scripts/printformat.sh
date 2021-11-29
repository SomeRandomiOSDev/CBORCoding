#!/usr/bin/env bash
#
# https://gist.github.com/SomeRandomiOSDev/798406a4a15f6b5d78b010599865c04f
#
# printformat.sh
# Usage example: ./formatstring.sh "forground:red;bold" "Hello, World"

# Help

function printhelp() {
    IFS='%'
    echo -e "printformat.sh [--help | -h] <format_string> <string_to_format>" 1>&2
    unset IFS

    exit 1
}

function printadvancedhelp() {
    local HELP="Updates a string with a specified format and returns it.\n\n"
    HELP+="printformat.sh [--help | -h] <format_string> <string_to_format>\n"
    HELP+="\n"
    HELP+="FLAGS:\n"
    HELP+="\n"
    HELP+="--help, -h)      Print this help message and exit.\n"
    HELP+="\n"
    HELP+="ARGUMENTS:\n"
    HELP+="\n"
    HELP+="format_string:   The format string with which to configure the input string. See\n"
    HELP+="                 \"FORMAT STRING\" section below for how to structure the format\n"
    HELP+="                 string.\n"
    HELP+="\n"
    HELP+="string_to_print: The string to be formatted\n"
    HELP+="\n"
    HELP+="FORMAT STRING:\n"
    HELP+="\n"
    HELP+="The format string is composed of a list of modifiers separated by semicolons.\n"
    HELP+="Valid modifiers are:\n"
    HELP+="\n"
    HELP+="- \"bold\": Bolds the text (\x1B[1mBold\x1B[0m)\n"
    HELP+="- \"dim\": Dims the text (\x1B[2mDim\x1B[0m)\n"
    HELP+="- \"underline\": Underlines the text (\x1B[4mUnderline\x1B[0m)\n"
    HELP+="- \"blink\": Blinks the text (\x1B[5mBlink\x1B[0m)\n"
    HELP+="- \"invert\": Inverts the foreground and background colors of the text\n"
    HELP+="            (\x1B[7mInvert\x1B[0m)\n"
    HELP+="- \"hidden\": Hides the text (\x1B[8mHidden\x1B[0m)\n"
    HELP+="\n"
    HELP+="- \"foreground:<color>\": Sets the text color for the text. See COLORS for a\n"
    HELP+="                        list of valid colors. (\x1B[32mGreen Text\x1B[0m)\n"
    HELP+="- \"background:<color>\": Sets the text color for the text. See COLORS for a\n"
    HELP+="                        list of valid colors. (\x1B[41mRed Background\x1B[0m)\n"
    HELP+="\n"
    HELP+="COLORS:\n"
    HELP+="\n"
    HELP+="Valid color names for the \"Foreground\" and \"Background\" are:\n"
    HELP+="\n"
    HELP+="- \"default\": Default color (\x1B[39mText\x1B[0m)\n"
    HELP+="- \"black\": Black color (\x1B[30mText\x1B[0m)\n"
    HELP+="- \"red\": Red color (\x1B[31mText\x1B[0m)\n"
    HELP+="- \"green\": Green color (\x1B[32mText\x1B[0m)\n"
    HELP+="- \"yellow\": Yellow color (\x1B[33mText\x1B[0m)\n"
    HELP+="- \"blue\": Blue color (\x1B[34mText\x1B[0m)\n"
    HELP+="- \"magenta\": Magenta color (\x1B[35mText\x1B[0m)\n"
    HELP+="- \"cyan\": Cyan color (\x1B[36mText\x1B[0m)\n"
    HELP+="- \"light-gray\": Light gray color (\x1B[37mText\x1B[0m)\n"
    HELP+="- \"dark-gray\": Dark gray color (\x1B[90mText\x1B[0m)\n"
    HELP+="- \"light-red\": Light red color (\x1B[91mText\x1B[0m)\n"
    HELP+="- \"light-green\": Light green color (\x1B[92mText\x1B[0m)\n"
    HELP+="- \"light-yellow\": Light yellow color (\x1B[93mText\x1B[0m)\n"
    HELP+="- \"light-blue\": Light blue color (\x1B[94mText\x1B[0m)\n"
    HELP+="- \"light-magenta\": Light magenta color (\x1B[95mText\x1B[0m)\n"
    HELP+="- \"light-cyan\": Light cyan color (\x1B[96mText\x1B[0m)\n"
    HELP+="- \"white\": White color (\x1B[97mText\x1B[0m)\n"
    HELP+="\n"
    HELP+="Additionally in lieu of a named color on terminals that support all 256 colors\n"
    HELP+="any number between 0 and 256 can be used (e.g. \"foreground:98\").\n"

    IFS='%'
    echo -e "$HELP" 1>&2
    unset IFS

    exit 0
}

# Parse Arguments

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help | -h)
        printadvancedhelp
        ;;

        *)
        if [ -z ${FORMAT_STRING+x} ]; then
            FORMAT_STRING="$1"
            shift # <format_string>
        elif [ -z ${INPUT_STRING+x} ]; then
            INPUT_STRING="$1"
            shift # <string_to_format>
        else
            echo -e "\x1B[31mExpected exactly two positional arguments\x1B[0m\n" 1>&2
            printhelp
        fi
        ;;
    esac
done

if [[ -z ${FORMAT_STRING+x} ]] || [[ -z ${INPUT_STRING+x} ]]; then
    echo -e "\x1B[31mExpected exactly two positional arguments\x1B[0m\n" 1>&2
    printhelp
fi

# Functions

function invalid_format_string() {
    echo -e "\x1B[31mInvalid format string: \"$1\"\x1B[0m\n" 1>&2
    printhelp
}

# Parse Format Sring

FORMAT_COMPONENTS=()
INPUT_COMPONENTS=()

IFS=';' read -ra INPUT_COMPONENTS <<< "$FORMAT_STRING"

#



if [[ ${#INPUT_COMPONENTS[@]} -ge 1 ]]; then
    for COMPONENT in "${INPUT_COMPONENTS[@]}"; do
        case "$COMPONENT" in
            "bold") FORMAT_COMPONENTS=(${FORMAT_COMPONENTS[@]} "1") ;;
            "dim") FORMAT_COMPONENTS=(${FORMAT_COMPONENTS[@]} "2") ;;
            "underline") FORMAT_COMPONENTS=(${FORMAT_COMPONENTS[@]} "4") ;;
            "blink") FORMAT_COMPONENTS=(${FORMAT_COMPONENTS[@]} "5") ;;
            "invert") FORMAT_COMPONENTS=(${FORMAT_COMPONENTS[@]} "7") ;;
            "hidden") FORMAT_COMPONENTS=(${FORMAT_COMPONENTS[@]} "8") ;;

            *)
            IFS=':' read -ra COLOR_COMPONENTS <<< "$COMPONENT"

            if [ "${#COLOR_COMPONENTS[@]}"  == "2" ]; then
                COLOR_COMPONENT="${COLOR_COMPONENTS[0]}"
                COLOR_NAME="${COLOR_COMPONENTS[1]}"

                case "$COLOR_COMPONENT" in
                    "foreground" | "background")
                    COLOR=0

                    if [ "$COLOR_COMPONENT" == "background" ]; then
                        COLOR=10
                    fi

                    #

                    case "$COLOR_NAME" in
                        "default") COLOR=$((COLOR+39)) ;;
                        "black") COLOR=$((COLOR+30)) ;;
                        "red") COLOR=$((COLOR+31)) ;;
                        "green") COLOR=$((COLOR+32)) ;;
                        "yellow") COLOR=$((COLOR+33)) ;;
                        "blue") COLOR=$((COLOR+34)) ;;
                        "magenta") COLOR=$((COLOR+35)) ;;
                        "cyan") COLOR=$((COLOR+36)) ;;
                        "light-gray") COLOR=$((COLOR+37)) ;;
                        "dark-gray") COLOR=$((COLOR+90)) ;;
                        "light-red") COLOR=$((COLOR+91)) ;;
                        "light-green") COLOR=$((COLOR+92)) ;;
                        "light-yellow") COLOR=$((COLOR+93)) ;;
                        "light-blue") COLOR=$((COLOR+94)) ;;
                        "light-magenta") COLOR=$((COLOR+95)) ;;
                        "light-cyan") COLOR=$((COLOR+96)) ;;
                        "white") COLOR=$((COLOR+97)) ;;

                        *)
                        if [[ $(echo "$COLOR_NAME" | grep -E "^(1?[0-9]{1,2}|2[0-4][0-9]|25[0-6])$") ]]; then # is it a number from 0-256
                            COLOR=$((COLOR+38))
                            COLOR="$COLOR;5;$COLOR_NAME"
                        else
                            invalid_format_string "$COLOR_COMPONENT:$COLOR_NAME"
                        fi
                        ;;
                    esac

                    #

                    FORMAT_COMPONENTS=(${FORMAT_COMPONENTS[@]} "$COLOR")
                    ;;

                    *)
                    invalid_format_string "$FORMAT_STRING"
                    ;;
                esac
            else
                invalid_format_string "$FORMAT_STRING"
            fi
            ;;
        esac
    done

    #

    if [[ ${#FORMAT_COMPONENTS[@]} -gt 0 ]]; then
        echo -e "\x1B[$(echo "${FORMAT_COMPONENTS[@]}" | tr ' ' ';')m${INPUT_STRING}\x1B[0m"
    fi
else
    invalid_format_string "$FORMAT_STRING"
fi
