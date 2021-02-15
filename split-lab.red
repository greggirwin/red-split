Red [
	title:  "Split Lab"
	author: "Gregg Irwin"
	File:   %split-lab.red
	Icon:   %split-lab.ico
]

#include %split.red
        
input-type: string!
input: none
rule: none
output: none
saved: copy []
saved-file: %saved-tests.dat

if exists? saved-file [saved: load saved-file]

set-test-values: does [
	input: fld-input/text
	if input-type = block! [
		input: load input
	]
	rule: load fld-rule/text
	if 'charset = first rule [
		rule: do rule
	]
	output: none
]

run-test: does [
	set-test-values	
	;output: split input rule
	print [
		"Input:"  tab	mold input	newline
		"Rule:"   tab	mold rule	newline
		"Output:" tab	mold output	newline
	]
]

save-test: has [new-entry] [
	if none? output [
		alert "Please run the test before saving."
		exit
	]
	new-entry: #()
	new-entry/input: input
	new-entry/rule: rule
	new-entry/output: output
	append saved new-entry
	save saved-file saved
]

;-------------------------------------------------------------------------------

; split-type input rule output

;-------------------------------------------------------------------------------

samples: [
	[split "abcdefghi" 2]
	[split "abcdefghi" 3]
	[split "abcdefghi" 4]
	[split "abc,def,ghi" comma]
]

;-------------------------------------------------------------------------------

input-samples: [
	"a,b,c:d,e,f"
]
split-types: [
	"At every delimiter"	delim
	"Once at a delimiter"	[once at]

	"Before every delimiter"	[before delim]
	"Once before a delimiter"	[once before delim]

	"After every delimiter"		[after delim]
	"Once after a delimiter"	[once after delim]

	"Into 2 parts, at a position or delimiter"	[once at]
	"Into parts of size N"						parts-of-size-N
	"Into N parts"								into-N-parts ;[into delim parts]
	"Into uneven parts"							uneven

	"Using a pass/fail test function"			filter
	"Using multiple test functions"				partition

	"Using a simple parse rule"					delim

	"First using one rule, then another"		multi
]

string-rule-samples: [
	#","
	{charset ",:"}
]
block-rule-samples: [
	[]
	[]
	[]
]

;-------------------------------------------------------------------------------

set-split-type-info: has [face] [
	face: fld-split-type
	key: pick face/data 2 * face/selected - 1
	print [mold key tab mold split-types/:key]
]

view [
	across
	text "I want to split:" fld-split-type:  drop-list 400 data split-types on-change [
		set-split-type-info 
	] return
	
	pad 0x10
	pad 90x0 text snow navy "If String is checked, value used as-is; otherwise loaded and parsed as Red data." return
	pad 0x-10
	;text "Input:"  fld-input:  field 400 hint "a,b,c:d,e,f"
	text "Input:"  fld-input:  drop-down 400 data input-samples hint "a,b,c:d,e,f"
	chk-str-input?: check "String" on return
	text "Input is a" pad 0x-5
		radio "String" on [input-type: string!]
		radio "Block"     [input-type: block!] return
	pad 0x10

	text "Enter the delimiting rule as a Red value." return
	pad 0x-10
	
;	text "Rule is a" pad 0x-5
;		radio "String" on [rule-type: string!]
;		radio "Block"     [rule-type: block!] return
	; hint {char!  OR  string!  OR  charset ",:"  OR  integer!  OR  block!}
	;pad 90x0 text snow navy "If String is checked, rule used as-is; otherwise loaded and used as a Red value." return
	pad 90x0 text snow navy "Rule is evaluated (reduced) and used as a Red value; format accordingly." return
	text "Rule:"   fld-rule:   field 400 hint {charset ",:"}
	;chk-str-rule?: check "String" off return
	return
;	text "Rule is a" pad 0x-5
;		radio "String" [rule-type: string!]
;		radio "Value" on [rule-type: default!] return
	pad 0x10
	
	text "Output:" fld-output: area 400x250
	return
	pad 210x0
	button "Got what I wanted"
	button "NOT what I expected" [ask-for-expected-result]
	return
	pad 210x0
	button "Run"  [run-test]
	button "Save" [save-test]
	button "Help" [show-help]
	button "Quit" [quit]
	
]

