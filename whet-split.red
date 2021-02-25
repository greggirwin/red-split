Red [
	title:  "Whet-Split"
	author: "Gregg Irwin"
	file:   %whet-split.red
	icon:   %split-lab.ico
	needs:  view
]

#include %split.red
#include %help.red
        
comment {
	What about The Hatchet Challenge? How fast can you pass the split tests?
	Have a set of tests, try to solve each one in as short a time or fewest attempts.
	Preset test suites can let people challenge for high score.
	
	practice rehearse train exercise drill work-out gym studio kata dojo
	muscle-memory 
}

task: #(
	desc: ""
	input: "" 	; string or block
	goal: []  	; expected output, always a block
	time: none
	tries: []	; be able to see what they actually tried
	report: none	; [input goal rule note]
)

help-text: {
"	Sharpen your skills.
	Hone that code to a fine edge. 
	Hone your splitting skills.
}

; compose [after every (string!)]"
; compose [after every (all-word!)]

inputs: [
	{"a,b,c"}
	{"1234567812345678"}
	{"PascalCaseNameAndMoreToo"}
	{"abc<br>de<br>fghi<br>jk"}
	{{line 1;^/line 2;^/line 3;^/}}		; curly braces needed due to newlines
	{{line_1:^/line_2:^/line_3:^/}}
	{{key-a=1^/key-b=2:^/key-c=3}}
	{"PascalCaseName"}
	{"camelCaseName"}
	{"<br>abc<br>de<br><para><br>fghi<br>jk<br>"}	; [by <para> then <br>]
	{"1.2.3-alpha.b+2045.RC3"}		; semver
	{"PascalCaseName camelCaseName dash-marked-name under_marked_name"} ;compose/deep [by (space) then (charset [#"A" - #"Z" "-_"])]
	{"YYYYMMDD/HHMMSS"}
	{"Mon, 24 Nov 1997"}
;{}
	{[1 2 3 4 5 6]}
	{[1 2 3 4 5 6 3 7 8 9]}
	{[1 2 [3] 4 5 6 [3] 7 8 9]}
	{[1 2.3 /a word "str" #iss x: :y]}
	{[1 2.3 /a word "str" #iss x: :y <T>]}
	{[1 2 3 space 4 5 6 space 7 8 9]} ; compose [by ['space] then (:even?)]
	{[1 2.3 /mark word "str" /mark #iss x: :y]}
]
split-it: has [res] [
	; Need to figure out how best to handle the rule, because it could be
	; comma
	; charset ""
	; before x    which has to be [[before x]] if we DO it.
	; etc.
	if error? set/any 'err try [
		txt-result/data: mold split load txt-input/text make-rule fld-rule/data
	][
		print mold err
		; TBD: format error for display
		alert mold err
	]
	;txt-goal/text: {["a" "b" "c"]}
	res: equal? txt-result/data txt-goal/data
	;res: true
	either res [
		success-marker/text: "✔"
		success-marker/font/color: true-color
	][
		success-marker/text: "✘"
		success-marker/font/color: false-color
	]
	
]
next-task: does [
	txt-input/data: random/only inputs
]
make-rule: function [
	data  "Content from user input field"
	/local fn
][
	compose=: [
		'compose/deep/only | 'compose/only/deep | 'compose/deep | 'compose/only | 'compose
		| 'reduce
	]
	
	;print [type? data mold data]
	val: data
	case [
		any [word? val get-word? val][get val]
		
		block? val [
			case [
				parse val [['charset | 'make 'bitset!] set arg [string! | block!]] [
					charset arg
				]
				; compose or reduce
				parse val [set fn compose= set arg [string! | block!]] [
					do compose [(fn) arg]
				]
;				parse val ['compose/deep set arg [string! | block!]] [
;					compose/deep arg
;				]
;				parse val ['compose set arg [string! | block!]] [
;					compose arg
;				]
;				parse val ['reduce set arg [string! | block!]] [
;					reduce arg
;				]
				'else [
					val
				]
			]
			
		]
		'else [		; char! integer! string!
			val
		]
	]
]
done: does [
	; TBD submit results
	
]

true-color:  (leaf  + 100) 
false-color: (brick + 100) 

view/options [
	style lbl: text 200 font-size 12
	style txt: text font-size 12
	style field: field 400x30 font-size 12
	style content: text 400x175 font-color navy font-size 11
	lbl "Your goal is to get this result:" ;return
	;pad 210x0
	txt-goal: content 400x175 "[ ... ^/^/^/^/^/^/^/^/ ... ]" return
	;txt-goal: content 400x175 {["a" "b" "c"]} return
	
	;lbl "Here is your input:" txt-input: content 400x50 {"a,b,c"} return
	lbl "Here is your input:" txt-input: field 400x50 {"a,b,c"} return
	lbl "How do you want to split? :" fld-rule: field on-enter [split-it] 
	button "&Split!" [split-it] return
	lbl "Here is your result:" ;return
	;pad 20x0
	txt-result: content "[ ... ^/^/^/^/^/^/^/^/ ... ]" 
	success-marker: text 30x30 "" bold font-size 18 ; with [font: make font! [size: 18 style: 'bold]]
	return
	lbl "I think I found a bug:" fld-bug-note: area font-size 12 400x75
	button "&Note" [note-bug] return
	pad 400x20
	button "Help" [show-help] 
	button "Next &Task >>" [next-task]
	pad 35x0 
	button "&Done" [done]
	
][
	text: "Hone your splitting skills"
	selected: fld-rule
	actors: make object! [
        on-key: function [face event] [
			;print ['on-key event/key event/flags type? event/key]
			case [
				event/ctrl? [
					switch event/key [
						#"^D" [done]
						#"^N" [note-bug]
						#"^S" [split-it]
						#"^T" [next-task]
					]
				]
				'else [
					switch event/key [
						F1    [show-help]
					]
				]
			]
		]
	]
]
