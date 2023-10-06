# udn-mixer

UDN Mixer is a simple tool that generates .com UDN (Universal Domain Name) compatible payloads from input patterns provided through STDIN.
Note if you're goal is to check homoglyph phishing, you should consider the rules define by the owner of the TLD that can be read in the IANA tables or ./code.generator/data.sources/

## DATA SOURCES 

The tool sources its data directly from the IANA tables. (https://www.iana.org/domains/idn-tables/tables/) 

## USAGE EXAMPLES 

Generate payloads from a given domain pattern:

```
echo "test.com"  | ./udnmixer -r ./rules.json | head -n 10

``` 

Output : 

``` 
 test.com
 test.com
 ţest.com
 ťest.com
 țest.com
 ṫest.com
 ṭest.com
 ṯest.com
 ṱest.com
 ẗest.com
```

Generate a specific type of payload:

```
(echo "aaaaa.stop"; echo "aaaa.bbbb.stop") | ./udnmixer -r ./rules.json | sed 's/\.stop//'| head -n 5

```

Output : 

```
 aaaaa
 aaaaa
 àaaaa
 áaaaa
 âaaaa

```

# RULES FILE 

The rules.json file was generated using the tools found in the code.generator directory.

For example, if you want to identify Unicode characters that visually resemble the letter "a", use the following command:

```
cat rules.json | jq '. | select(.latin_char == "a")' -c
```

Output : 

```
... stripped 
{"actual_char":"а","unicode":"U+0430","latin_char":"a","description":"CYRILLIC SMALL LETTER A"}
{"actual_char":"ӑ","unicode":"U+04D1","latin_char":"a","description":"CYRILLIC SMALL LETTER A WITH BREVE"}
{"actual_char":"ӓ","unicode":"U+04D3","latin_char":"a","description":"CYRILLIC SMALL LETTER A WITH DIAERESIS"}
{"actual_char":"д","unicode":"U+0434","latin_char":"a","description":"CYRILLIC SMALL LETTER DE"}
{"actual_char":"ꙣ","unicode":"U+A663","latin_char":"a","description":"CYRILLIC SMALL LETTER SOFT DE"}
{"actual_char":"ᥑ","unicode":"U+1951","latin_char":"a","description":"TAI LE LETTER XA"}
{"actual_char":"Ꭺ","unicode":"U+13AA","latin_char":"a","description":"CHEROKEE LETTER GO"}
{"actual_char":"ᗅ","unicode":"U+15C5","latin_char":"a","description":"CANADIAN SYLLABICS CARRIER GHO"}
{"actual_char":"ᗋ","unicode":"U+15CB","latin_char":"a","description":"CANADIAN SYLLABICS CARRIER RO"}
{"actual_char":"ᗩ","unicode":"U+15E9","latin_char":"a","description":"CANADIAN SYLLABICS CARRIER PO"}
{"actual_char":"ꓮ","unicode":"U+A4EE","latin_char":"a","description":"LISU LETTER A"}
... stripped 
```

Note: If your intent is to investigate homoglyph phishing, it's essential to refer to the rules set by the TLD's owner. These rules can be found in the IANA tables or within the ./code.generator/data.sources/ directory.



