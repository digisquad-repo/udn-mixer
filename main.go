package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"strings"
)

type S_rule struct {
	ActualChar  string `json:"actual_char"`
	Unicode     string `json:"unicode"`
	LatinChar   string `json:"latin_char"`
	Description string `json:"description"`
}

// load rules from json
//

func loadRules(tRulesFilePath string) (map[string][]string, error) {

	homoglyphMap := make(map[string][]string)

	file, err := os.Open(tRulesFilePath)

	if err != nil {
		return nil, err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)

	for scanner.Scan() {

		var rule S_rule
		line := scanner.Text()

		if err := json.Unmarshal([]byte(line), &rule); err != nil {
			return nil, err
		}

		homoglyphMap[rule.LatinChar] = append(homoglyphMap[rule.LatinChar], rule.ActualChar)
	}

	return homoglyphMap, nil
}

// output domain variants after apply json rules
//

func generateNewDomains(tDomain string, tRules map[string][]string) []string {

	var variants []string

	for i, char := range tDomain {

		if replacements, ok := tRules[string(char)]; ok {
			for _, replacement := range replacements {
				variants = append(variants, tDomain[:i]+replacement+tDomain[i+1:])
			}
		}
	}

	return variants
}

func main() {

	// check args and STDIN if required/
	//

	warmupChecks()

	// load rules from json file.
	//

	homoglyphMap, err := loadRules(os.Args[2])

	if err != nil {
		panic(err)
	}

	scanner := bufio.NewScanner(os.Stdin)

	// generate variants for .com TLD
	//

	for scanner.Scan() {
		var domain, TLD string

		// parsing inputs
		//
		inputStream := scanner.Text()
		inputStreamToParse := strings.SplitN(inputStream, ".", 2)

		if len(inputStreamToParse) < 2 {

			domain = inputStream
			TLD = ""
		} else {

			domain = inputStreamToParse[0]
			TLD = inputStreamToParse[1]
		}

		variants := generateNewDomains(domain, homoglyphMap)

		if TLD != "" {
			for _, variant := range variants {
				fmt.Println(variant + "." + TLD)
			}
		} else {
			for _, variant := range variants {
				fmt.Println(variant)
			}
		}
	}
}

//// //// //// //// //// //// //// //// //// //// //// //// //// ////

func showHelp() {
	fmt.Println(" Usage:")
	fmt.Println("")
	fmt.Println("   Generate payload from STDIN that can be a domain or a sequence of characters:")
	fmt.Println("    echo \"google.com\"  | ./udnmixer -r ./rules.json")
	fmt.Println("    echo \"abcdefgh\"    | ./udnmixer -r ./rules.json")
	fmt.Println("    cat /tmp/domains.txt | ./udnmixer -r ./rules.json")
	fmt.Println("")
	fmt.Println("\n Note :")
	fmt.Println("")
	fmt.Println("   If you need to break payload generation, add a dot to your input.")
	fmt.Println("     echo \"aaaaa.bbbbb\"  | ./udnmixer -r ./rules.json")
	fmt.Println("   or : ")
	fmt.Println("     (echo \"aaaaa.stop\"; echo \"aaaa.bbbb.stop\") | ./udnmixer -r ./rules.json | sed 's/\\.stop//'")
	fmt.Println("")
	fmt.Println("")

	return
}

func warmupChecks() {

	// arg checks

	if len(os.Args) != 3 || os.Args[1] != "-r" {

		showHelp()
		os.Exit(1)
	}

	// STDIN checks

	fi, err := os.Stdin.Stat()
	if err != nil {
		panic(err)

	}

	if (fi.Mode() & os.ModeCharDevice) != 0 {
		fmt.Println("no stdin data.")
		os.Exit(1)
	}

}
