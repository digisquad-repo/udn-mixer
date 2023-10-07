#!/bin/bash

showExample() {
    echo "$(basename "$0")"
    echo "$(basename "$0") -h "
    echo "$(basename "$0") --help "
    echo "cat extract.output.filtered.manual| $(basename "$0")"
    echo "cat extract.output.filtered.manual.toEdit | $(basename "$0")"
    echo "cat stuff | $(basename "$0")"
    echo " "
}

if [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
    echo "NAME"
    echo "  $(basename "$0") - Convert extract.output.filtered or extract.output.filtered.toEdit to json rules "
    echo
    echo "SYNOPSIS"
    echo "  $(basename "$0") [-h|--help] [--update|-u]"
    echo
    echo "OPTIONS"
    echo "  -h, --help     Show this help message."
    echo
    echo "EXAMPLE"
    echo "  $(showExample)"
    echo
    exit 1
fi

###############################################################################

if [ -p /dev/stdin ]; then
    echo "" 1>&2
    echo " :: I love stream too. :) " 1>&2
    echo "" 1>&2

    INPUT="-"

else
    INPUT="extract.output.filtered.manual"
fi

(
    cat $INPUT | cut -d ";" -f1,2,4 | huniq |
        jq -R -s -c '  split("\n") | map(
                select(length > 0)
                | split(";")
                | {
                    "actual_char": (.[0] | split("/") | .[0] | ltrimstr(" ") | rtrimstr(" ")),
                    "unicode": (.[0] | split("/") | .[1] | ltrimstr(" ") | rtrimstr(" ")),
                    "latin_char": (.[1] | ltrimstr(" ") | rtrimstr(" ")),
                    "description": (.[2] | ltrimstr(" ") | rtrimstr(" "))
                }
            )' |
        jq -c ".[]" |
		jq -c '. |  select(.actual_char != .latin_char and .actual_char != "" and .latin_char != "" and .actual_char != null and .latin_char != null)' |
        sed 's/Latin\\tLATIN/LATIN/g'
)

echo "" 1>&2
echo " :: data ok ? then redirect stdout to ../rules.json" 1>&2
echo "" 1>&2
