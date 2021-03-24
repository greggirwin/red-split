Red [
	title:  "Whet-Split"
	author: "Gregg Irwin"
	file:   %whet-split.red
	icon:   %split-lab.ico
	needs:  view
]

#include %split.red
#include %help.red
;#include %whet-split-suite-1.red
        
comment {
	What about The Hatchet Challenge? How fast can you pass the split tests?
	Have a set of tests, try to solve each one in as short a time or fewest attempts.
	Preset test suites can let people challenge for high score.
	
	learn study practice rehearse train exercise drill (study is also a good noun)
	work-out gym studio kata dojo muscle-memory 
	praxis https://www.wordnik.com/words/praxis maybe 'practice then?
	
	- load suite
	- if a session for the suite is in progress, use that
	- session data is updated, suites are not; they are templates for sessions
	
}

cycle: function ['series [word!] /prev][
	ser: get series
	ser: either prev [
		either head? ser [back tail ser][skip ser -1]
	][
		either tail? next ser [head ser][skip ser 1]
	]
	set series ser
]
;closure: func [
;    vars [block!] "Values to close over, in spec block format"
;    spec [block!] "Function spec for closure func"
;    body [block!] "Body of closure func; vars will be available"
;][
;    func spec bind body context vars
;]
;cycler: func [block [block!]][
;	closure compose/only [block: (block)] [/reset] [
;		if any [reset  tail? block] [block: head block]
;		also  first block  block: next block
;	]
;]


;task-proto: #(
;	id:    none
;	desc:  ""
;	input: "" 	; string or block
;	goal:  []  	; expected output, always a block
;	time:  none
;	tries: []	; be able to see what they actually tried
;	notes: ""	; [input goal rule note]
;	rating: none
;	vote:  none
;)
task-proto: object [
	id:    #[none]
	desc:  ""
	input: "" 	; string or block
	goal:  []  	; expected output, always a block
	time:  #[none]
	tries: []	; be able to see what they actually tried
	notes: ""	; [input goal rule note]
	rating: #[none]
	vote:   #[none]
]
;extend task <suite-task>

cur-task: none
set-cur-task: does [
	;cur-task: extend copy task-proto first suite
	cur-task: first cur-session	; session cycles
]

suite: #include %whet-split-suite-1.red

make-session: func [data [block!]][
	collect [
		foreach item data [
			;keep make copy/deep/types item string! copy/deep/types task-proto string!
			keep/only make copy/deep task-proto item
		]
	]
]
save-session: func [dest data][
	save dest data
]
;help-text: {
;	Sharpen your skills.
;	Hone that code to a fine edge. 
;	Hone your splitting skills.
;}

; compose [after every (string!)]"
; compose [after every (all-word!)]

cur-session: either exists? %_session.red [
	reduce load %_session.red
][
	make-session suite
]
set-cur-task

;inputs: [
;	{"a,b,c"}
;	{"1234567812345678"}
;	{"PascalCaseNameAndMoreToo"}
;	{"abc<br>de<br>fghi<br>jk"}
;	{{line 1;^/line 2;^/line 3;^/}}		; curly braces needed due to newlines
;	{{^/line_1:^/line_2:^/line_3:^/}}
;	{{key-a=1^/key-b=2:^/key-c=3}}
;	{"PascalCaseName"}
;	{"camelCaseName"}
;	{"<br>abc<br>de<br><para><br>fghi<br>jk<br>"}	; [by <para> then <br>]
;	{"1.2.3-alpha.b+2045.RC3"}		; semver
;	{"PascalCaseName camelCaseName dash-marked-name under_marked_name"} ;compose/deep [by (space) then (charset [#"A" - #"Z" "-_"])]
;	{"YYYYMMDD/HHMMSS"}
;	{"Mon, 24 Nov 1997"}
;;{}
;	{[1 2 3 4 5 6]}
;	{[1 2 3 4 5 6 3 7 8 9]}
;	{[1 2 [3] 4 5 6 [3] 7 8 9]}
;	{[1 2.3 /a word "str" #iss x: :y]}
;	{[1 2.3 /a word "str" #iss x: :y <T>]}
;	{[1 2 3 space 4 5 6 space 7 8 9]} ; compose [by ['space] then (:even?)]
;	{[1 2.3 /mark word "str" /mark #iss x: :y]}
;]
split-it: has [res] [
	; Need to figure out how best to handle the rule, because it could be
	; comma
	; charset ""
	; before x    which has to be [[before x]] if we DO it.
	; etc.
	if error? set/any 'err try [
		txt-result/data: mold split load txt-input/text make-rule fld-rule/data
		lbl-rule-err/visible?: no
		;print mold make-rule fld-rule/data
	][
		print mold err
		; TBD: format error for display
		;alert ["I don't know what to make of " mold fld-rule/text]
		;?? TBD Dynamic error message?
		lbl-rule-err/text: "I don't understand that. Maybe try reduce/compose."
		lbl-rule-err/visible?: yes
	]
	;txt-goal/text: {["a" "b" "c"]}
	res: equal? txt-result/data txt-goal/data
	;TBD Disallow moving to next task until current one is done?
	;TBD Show count of completed tasks?	
	;res: true
	either res [
		success-marker/text: "✔"
		success-marker/font/color: true-color
	][
		success-marker/text: "✘"
		success-marker/font/color: false-color
	]
	
]
gather-UI-data: does [
	;	if cur-task [
;		cur-task/notes: fld-notes/text
;	]
	cur-task/notes: copy fld-notes/text

]
show-cur-task: does [
	txt-ID/text: mold cur-task/id
	txt-input/data: mold cur-task/input
	txt-goal/data: mold cur-task/goal
	fld-notes/text: cur-task/notes
	clear fld-rule/text
	clear txt-result/text
	;clear fld-notes/text
	success-marker/text: "" ;success-marker/visible?: no
]
next-task: does [
	cycle cur-session ;suite
	set-cur-task
	;probe cur-task: extend task-proto first suite
	;txt-input/data: random/only inputs
	;txt-input/text: mold random/only inputs
	show-cur-task
	;TBD ? skip over complete tasks so user can move on if they're stuck?
]
prev-task: does [
	cycle/prev cur-session ;suite
	set-cur-task
	;txt-input/data: random/only inputs
	show-cur-task
	start-task-timer
]


start-task-timer: does []
pause-task-timer: does []
stop-task-timer:  does []
store-task-timer: does []


make-rule: function [
	data  "Content from user input field"
	/local fn arg
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
;make-note: does [
;	; TBD
;	
;]
save-results: does [
	; TBD submit results
	print 'saving	
	save-session %_session.red head cur-session	; TBD mark cur-task
]
rate-task: func [val][cur-task/rating: val]
vote: func [val][print ['vote val] cur-task/vote: val]

true-color:  (leaf  + 100) 
false-color: (brick + 100) 

view/options [
	space 4x4
	style lbl: text 200 font-size 12
	style txt: text font-size 12
	style field: field 400x30 font-size 12
	style content: text 400x160 font-color navy font-size 11
	style vote: button 40 top font-size 12
	lbl "Task ID:" txt-ID: txt "___" return
	lbl "Your goal is to get this result:" ;return
	;pad 210x0
	txt-goal: content "[ ... ^/^/^/^/^/^/^/ ... ]" return
	;txt-goal: content 400x175 {["a" "b" "c"]} return
	
	lbl "Here is your input:" txt-input: content 400x100 return
	;lbl "Here is your input:" txt-input: field 400x100 return
	lbl "How do you want to split? :" fld-rule: field on-enter [split-it] 
	button "Split (F5)" [split-it] return
	pad 210x0 lbl-rule-err: txt 400 font-color red return
	lbl "Here is your result:" ;return
	;pad 20x0
	txt-result: content "[ ... ^/^/^/^/^/^/^/ ... ]" 
	success-marker: text 30x30 "" bold font-size 18 ; with [font: make font! [size: 18 style: 'bold]]
	return
	lbl "Notes:" fld-notes: area font-size 12 400x75 ;on-change [cur-task/notes]
	return
	lbl "Rate this task:" txt 35 "Easy" slider 50% 200 [rate-task face/data] txt 35 "Hard" 
	pad 20x0 vote "👍" [vote 1] vote "👎" [vote -1] return
	pad 400x20
	button "Help (F1)" [show-help] 
	button "Prev Task (F6)" [prev-task]
	button "Next Task (F8)" [next-task]
	pad 35x0 
	button "Save" [save-results]
	;return button "Halt" [halt]
	do [show-cur-task]
][
	text: "Hone your splitting skills"
	selected: fld-rule
	actors: make object! [
        on-key: function [face event] [
			;print ['on-key event/key mold event/flags type? event/key mold event/key]
			case [
				event/ctrl? [
					switch event/key [
;						#"^I" [split-it]
;						#"^N" [make-note]
						#"^S" [save-results]
;						#"^T" [next-task]
;						left  [prev-task]
;						right [next-task]
						up    [vote +1]
						down  [vote -1]
					]
				]
;				find event/flags 'control [
;					print ['control-flag mold event/key]
;					switch event/key [
;						F1    [show-help]
;						F5    [split-it]
;						F6    [prev-task]
;						F8    [next-task]
;;						up    [vote +1]
;;						down  [vote -1]
;					]
;				]
				'else [
					;print mold event/key
					switch event/key [
						F1    [show-help]
						F5    [split-it]
						F6    [prev-task]
						F8    [next-task]
						#"+" [vote +1]
						#"-" [vote -1]
					]
				]
			]
		]
;        on-key-down: function [face event] [
;			;print ['on-key event/key event/flags type? event/key]
;			case [
;				event/ctrl? [
;					switch event/key [
;;						#"^I" [split-it]
;;						#"^N" [make-note]
;						#"^S" [save-results]
;;						#"^T" [next-task]
;					]
;				]
;				find event/flags 'aux-down [
;					switch event/key [
;						left  [prev-task]
;						right [next-task]
;					]
;				]
;				'else [
;					switch event/key [
;						F1    [show-help]
;						F5    [split-it]
;						F6    [next-task]
;					]
;				]
;			]
;		]
	]
]

;view/options [size 400x300][
;	actors: make object! [
;        on-key: function [face event] [
;			print ['on-key event/key mold event/flags type? event/key mold event/key]
;		]
;	]
;]
