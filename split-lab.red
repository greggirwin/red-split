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
	
;	text "Rule is a" pad 0x-5
;		radio "String" on [rule-type: string!]
;		radio "Block"     [rule-type: block!] return
	; hint {char!  OR  string!  OR  charset ",:"  OR  integer!  OR  block!}
	;pad 90x0 text snow navy "If String is checked, rule used as-is; otherwise loaded and used as a Red value." return
	pad 90x0 text snow navy "Rule is evaluated (reduced) and used as a Red value; format accordingly." return
	pad 0x-10
	text "Rule:"   fld-rule:   field 400 hint {charset ",:"}
	;chk-str-rule?: check "String" off return
	return
;	text "Rule is a" pad 0x-5
;		radio "String" [rule-type: string!]
;		radio "Value" on [rule-type: default!] return
	pad 0x10

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

view [
	space 4x2
	tab-panel 800x500 [
		"Split by size or postion" [
			space 4x2
			check "Split by ..." return
			pad 20x0 text font-color navy "example..." return
			pad 20x0 text "How often?" text "Rarely" sld-x: slider text "A lot" return
			pad 20x0 check "This is worth supporting"
		]
		"Split by delimiter" []
		"Split by predicate" []
		"Split at 2 levels" []
	] return
	check "Split by ..." return
	text font-color navy "example..." return
	text "How often?" text "Rarely" sld-x: slider text "A lot" return
	check "This is worth supporting"
]


;-------------------------------------------------------------------------------

comment {
	What about The Hatchet Challenge. How fast can you pass the split tests?
	Have a set of tests, try to solve each one in as short a time or fewest attempts.
	Preset test suites can let people challenge for high score.
}

task: #(
	desc: ""
	input: "" ; string or block
	goal: []  ; expected output
	time: none
	tries: 0
)

help-text: {
}

inputs: [
	{"a,b,c"}
	{"1234567812345678"}
	{"PascalCaseNameAndMoreToo"}
	{"abc<br>de<br>fghi<br>jk"}
	"[1 2 3 4 5 6]"
]
split-it: does [
	; Need to figure out how best to handle the rule, because it could be
	; comma
	; charset ""
	; before x    which has to be [[before x]] if we DO it.
	; etc.
	txt-result/data: mold split load txt-input/text do fld-rule/data
]
next-task: does [
	
]
view [
	style lbl: text 150
	text 600x30 font-size 14 "In this task your goal is to get this result:" return
	txt-goal: text 400x100 bold font-color navy "[ ... ^/^/^/^/^ ... ]" return
	
	lbl "Here is your input:" txt-input: text bold font-color navy 400 {"a,b,c"} return
	lbl "Put your rule here:" fld-rule: field 400 on-enter [split-it]
	button "Split!" [split-it] return
	lbl "Here's the result you got:" return
	pad 20x0
	txt-result: text 400x175 bold font-color navy "[ ... ^/^/^/^/^/^/^/^/^/^/ ... ]" return
	lbl "I think I found a bug" fld-bug-note: field 400
	button "Report" [] return
	pad 450x20
	button "Instructions" [] 
	button "Next Task >>" [txt-input/data: random/only inputs]
]
