package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"regexp"
	"strconv"
)

func processURL(tUrl string) {

	resp, err := http.Get(tUrl)
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()

	contentBytes, err := ioutil.ReadAll(resp.Body)

	if err != nil {
		panic(err)
	}

	contentStr := string(contentBytes)

	r := regexp.MustCompile(`(U\+[0-9A-F]+)\s*#\s*(.*)`)

	matches := r.FindAllStringSubmatch(contentStr, -1)

	for _, match := range matches {

		unicodeValue := match[1]
		description := match[2]

		character := decodeUnicode(unicodeValue)

		line := fmt.Sprintf("%s / %s ; SPACE_FOR_MANUAL_ANNOTATION ; %s ; %s", character, unicodeValue, tUrl, description)

		fmt.Println(line)
	}
}

func decodeUnicode(tUnicodeValue string) string {

	decoded, err := strconv.ParseInt(tUnicodeValue[2:], 16, 32)

	if err != nil {
		return ""
	}

	return string(rune(decoded))
}

func main() {

	warmupChecks()

	scanner := bufio.NewScanner(os.Stdin)

	for scanner.Scan() {
		url := scanner.Text()
		processURL(url)
	}

	if scanner.Err() != nil {

		panic(scanner.Err())
	}
}

//// //// //// //// //// //// //// //// //// //// //// //// //// ////

func showHelp() {
	fmt.Println("")
	fmt.Println("")
	fmt.Println("  Usage: cat ../data.sources/iana-tables.url | ./prepare.table")
	fmt.Println("")
	fmt.Println("")
	return
}

func warmupChecks() {

	//// //// arg checks //// ////

	if len(os.Args) == 2 && (os.Args[1] == "--help" || os.Args[1] == "-h") {
		showHelp()
		os.Exit(1)
	}

	if len(os.Args) > 1 {
		showHelp()
		os.Exit(1)
	}

	//// //// STDIN ? //// ////

	fi, err := os.Stdin.Stat()
	if err != nil {
		panic(err)

	}

	if (fi.Mode() & os.ModeCharDevice) != 0 {
		fmt.Println("no stdin data.")

		os.Exit(1)
	}

}
