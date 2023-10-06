#!/bin/bash

showExample() {
	echo "$(basename "$0")"
	echo "$(basename "$0") -h "
	echo "$(basename "$0") --help "
	echo "$(basename "$0") -u "
	echo "$(basename "$0") --update "
	echo " "
}

if [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
	echo "NAME"
	echo "  $(basename "$0") - Extract and filter the Internationalized Domain Names (IDN) tables from IANA."
	echo
	echo "SYNOPSIS"
	echo "  $(basename "$0") [-h|--help] [--update|-u]"
	echo
	echo "DESCRIPTION"
	echo "  Processes the IANA tables to extract Unicode characters and their descriptions."
	echo "  It filters out specific characters and descriptions"
	echo
	echo "OPTIONS"
	echo "  -h, --help     Show this help message."
	echo "  -u, --update   Update filename extract.output.full file with the latest data from IANA."
	echo
	echo "EXAMPLE"
	echo "  $(showExample)"
	echo
	exit 1
fi

IFS=$'\n'

INPUT="./data.sources/iana-tables.url"
TRANSFORM_01="./extract.output.full"
OUTPUT="./extract.output.filtered"

updateOutput() {

	echo " :: download / prepare files parsing"
	(
		cat "$INPUT" |
			./extract/prepare.table
	) >"$TRANSFORM_01"
}

filterOutput() {

	(
		cat "$TRANSFORM_01" |
			grep -v "ꠇ" |
			grep -v "CJK Ideograph" |
			grep -v "Hangul Syllable" |
			grep -v "SUNDANESE LETTER" |
			grep -v "EGYPTIAN HIEROGLYPH" |
			grep -v "DIGIT" |
			grep -v "AVESTAN LETTER" |
			grep -v "ALINESE LETTER OKARA TEDUNG" |
			grep -v "BAMUM LETTER KET" |
			grep -v "BUHID LETTER" |
			grep -v "CHAM LETTER" |
			grep -v "COMBINING CYRILLIC LETTER" |
			grep -v "IDEOGRAPH" |
			grep -v "TAI THAM LETTER" |
			grep -v "LIMBU LETTER" |
			grep -v "MANDAIC LETTER" |
			grep -v "MEETEI MAYEK DIGIT FIVE" |
			grep -v "MONGOLIAN LETTER " |
			grep -v "OL CHIKI LETTER" |
			grep -v "OLD TURKIC LETTER" |
			grep -v "PHAGS-PA LETTER" |
			grep -v "REJANG LETTER" |
			grep -v "REJANG VOWEL" |
			grep -v "REJANG CONSONANT" |
			grep -v "INSCRIPTIONAL PARTHIAN LETTER" |
			grep -v "INSCRIPTIONAL PAHLAVI LETTER" |
			grep -v "OLD SOUTH ARABIAN" |
			grep -v "SUNDANESE" |
			grep -v "SYLOTI" |
			grep -v "TAGBANWA" |
			grep -v "NEW TAI LUE" |
			grep -v "CUNEIFORM SIGN" |
			grep -v "TAI VIET" |
			grep -v "YI SYLLABLE" |
			grep -v "VAI SYLLABLE" |
			grep -v "JAVANESE VOWEL" |
			grep -v "KAYAH LI" |
			grep -v "KHAROSHTHI LETTER" |
			grep -v "KAITHI LETTER" |
			grep -v "BAMUM" |
			grep -v "THAI TON" |
			grep -v "MEETEI MAYEK" |
			grep -v "CARIAN LETTER" |
			grep -v "COPTIC SMALL LETTE" |
			grep -v "IMPERIAL ARAMAIC" |
			grep -v "TAI THAM" |
			grep -v "LEPCHA LETTER" |
			grep -v "LIMBU" |
			grep -v "LYDIAN" |
			grep -v "ORIYA" |
			grep -v "SAMARITAN" |
			grep -v "BALINESE" |
			grep -v "CARIAN" |
			grep -v "HYPHEN-MINUS"

	) | sort -u >"$OUTPUT"

	cp "$OUTPUT" "$OUTPUT.toEdit"

}

if [ $# -eq 1 ] && ([ "$1" = "--update" ] || [ "$1" = "-u" ]); then
	updateOutput
	filterOutput
else
	if [ ! -f ./extract.output.full ]; then

		updateOutput
	fi
	filterOutput
	echo " :: output => $OUTPUT.toEdit" 1>&2

	echo " rename $OUTPUT.toEdit to $OUTPUT.manual when ready to generate json rules " 1>&2
	echo " then : ./02.extract.output.filtered.manual.csv.convert.to.jsons.sh" 1>&2
	echo "" 1>&2
fi
