Red [
	title:  "Practice-Split"
	author: "Gregg Irwin"
	file:   %practice-split.red
	icon:   %split-lab.ico
	needs:  view
]

comment {
	session		; a pass on a suite. A suite is a test; a session is taking the test.
		When you start a session, a suite is loaded.
		When all tasks are done (goal met), the session is complete.
		You can stop before completing a session; but can't continue where you left off. ???
	suite		; a set of tasks
		When you load a suite, full tasks are made from template skeletons.
	task		; a split input, goal, user notes, and telemetry
		While you're on a task, its timer is running.
}

#include %split.red
#include %help.red
;#include %practice-split-suite-1.red
#include %../red-formatting/format-date-time.red
        
comment {
	Have a set of tests, try to solve each one in as short a time or fewest attempts.
	Preset test suites can let people challenge for high score.
	
	learn study practice rehearse train exercise drill (study is also a good noun)
	work-out gym studio kata dojo muscle-memory 
	
	praxis https://www.wordnik.com/words/praxis maybe 'practice then?
	[Medieval Latin prāxis, from Greek, from prāssein, prāg-, to do.]
	From Ancient Greek πρᾶξις (praksis, "action, activity, practice")
	
	- load suite
	- if a session for the suite is in progress, use that
	- session data is updated, suites are not; they are templates for sessions
	
		
	- split cheat sheet
	- Be able to save split rules that apply to known data formats?
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


;-------------------------------------------------------------------------------

; Maps and objects behave differently with respect to copying.
; Open question for Nenad, 
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
	input: "" 		; string or block
	goal:  []  		; expected output, always a block
	hint:  ""		; clues to keyword use, etc., that may apply
	time:  #[none]	; log start/end times for each "visit" to a task?
	ticks: 0		; 1 tick = 1 second; how long has this task taken so far?
	unticks: 0		; ticks while paused ???
	done?: no		; set to yes when result = goal
	tries: []		; be able to see what they actually tried
					; sub-blocks of [time rule]
	notes: ""		; [input goal rule note]
	rating: #[none] ; easy to hard
	vote:   #[none]	; like/dislike
]
;extend task <suite-task>

cur-task: none
set-cur-task: does [
	;cur-task: extend copy task-proto first suite
	cur-task: first cur-session	; session cycles
]

suite: #include %practice-split-suite-1.red

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
		; Toomas suggested the new approach, to represent/reproduce the text
		; exactly as it was entered, not as loaded into data.
		;append cur-task/tries [reduce now/precise form fld-rule/data]
		repend cur-task/tries [now/precise copy fld-rule/text]
		
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
		cur-task/done?: yes
		success-marker/text: "✔"
		success-marker/font/color: true-color
	][
		cur-task/done?: no
		success-marker/text: "✘"
		success-marker/font/color: false-color
	]
	show-task-stats
	res					; return result of split test
]
gather-UI-data: does [
	; Splitting action collects much of the data.
	cur-task/notes: copy fld-notes/text
	; Votes, rating, and ticks trigger updates directly, no need to gather
]
show-cur-task: does [		; scatter UI data
	fld-rule/enabled?: yes
	
	txt-ID/text: mold cur-task/id
	task-time/text: form to time! cur-task/ticks
	txt-input/data: mold cur-task/input
	txt-goal/data: mold cur-task/goal
	fld-notes/text: cur-task/notes
	clear fld-rule/text
	;TBD If the task is done, and we've kept the matching rule (last tries),
	; show that and disable fld-rule so they know they're done with this one.
	; Tricky bit. If we disable the field, it won't see F6/F8 to nav tasks.
	; And if it has focus, it eats those keys so nobody else sees them either.
	either cur-task/done? [
		fld-rule/text: form last cur-task/tries
		fld-rule/enabled?: no
		success-marker/text: "✔"
	][
		success-marker/text: ""
	]
	fld-rule/options/hint: any [cur-task/hint ""]

	lbl-rule-err/visible?: no
	clear txt-result/text
	;clear fld-notes/text
	;success-marker/text: "" ;success-marker/visible?: no
]
next-task: does [
	save-results
	cycle cur-session ;suite
	set-cur-task
	;probe cur-task: extend task-proto first suite
	;txt-input/data: random/only inputs
	;txt-input/text: mold random/only inputs
	show-cur-task
	start-task-timer
	set-focus fld-rule
	;TBD ? skip over complete tasks so user can move on if they're stuck?
	;print mold cur-task
]
prev-task: does [
	save-results
	cycle/prev cur-session ;suite
	set-cur-task
	;txt-input/data: random/only inputs
	show-cur-task
	set-focus fld-rule
	start-task-timer
]

;-------------------------------------------------------------------------------

task-stats: func [session /local task-grps] [
	; Hmmm, cur-session moves its head pointer through the block
	; of tasks as it goes, so we need to use HEAD. Not great.
	task-grps: partition head session func [task][task/done?]
	object [
		tasks: length? session
		done:  length? task-grps/1
		not-done: length? task-grps/2
	]	
]
all-tasks-done?: func [session] [
	foreach task session [
		if not task/done? [return false]
	]
]
show-task-stats: has [stats] [
	stats: task-stats cur-session
	lbl-stats/text: rejoin [stats/done " down, " stats/not-done " to go"]
]

;-------------------------------------------------------------------------------

session-timer: object [
	start: end: none
	elapsed: does [difference end start]
]

;start-session: does [
;	start-session-timer
;]

; Do we need a session timer? It could tell us if people do better late
; at night, or if they run a session multiple times, breaking it up
; into chunks.
start-session-timer: does [session-timer/start: now]
pause-session-timer: does []
 stop-session-timer: does [session-timer/end: now]
store-session-timer: does []

; If we have a rate/timer ticking, we can just increment the task timer
; for the current task on every tick as long as the task isn't done.
start-task-timer: does []
pause-task-timer: does []
 stop-task-timer: does []
store-task-timer: does []

;-------------------------------------------------------------------------------


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


open-session-file: does [
	if session-file: request-file/file %sessions/ [
		;if session open [save-results]
		cur-session: either exists? session-file [
			reduce load session-file
		][
			make-session suite
		]
		set-cur-task
		show-task-stats
	]
]

make-dir %sessions/

session-file: none
start-session: does [
	session-file: rejoin [
		%sessions/practice-split-
		format-date-time now "yyyy-mm-dd-hhh-mm-ss-"
		%.red
	]
]

save-results: does [
	; TBD submit results
	;print 'saving	
	;save-session %sessions/_session.red head cur-session	; TBD mark cur-task
	save-session session-file head cur-session	; TBD mark cur-task
]

rate-task: func [val][cur-task/rating: val]

vote: func [val][
	;print ['vote val]
	cur-task/vote: val
	either val = 1 [
		if f-downvote/data [f-downvote/data: off]
	][
		if f-upvote/data [f-upvote/data: off]
	]
]

tick: does [
	;print ['tick now/precise]
	if not cur-task/done? [
		cur-task/ticks: cur-task/ticks + 1
	]
	task-time/text: form to time! cur-task/ticks
]

;-------------------------------------------------------------------------------

start-session

;-------------------------------------------------------------------------------

true-color:  (leaf  + 100) 
false-color: (brick + 100) 

view/options [
	space 4x4
	style lbl: text 200 font-size 12
	style txt: text font-size 12
	style field: field 400x30 font-size 12
	style content: text 400x160 font-color navy font-size 12
	;style vote: toggle 50 left top font-size 12
	style vote: toggle 50 top font-size 12
	style timer: base 0x0 rate 0:0:1 
	
	lbl "Task ID:" txt-ID: txt 350 "___"
	task-time: timer 50x20 glass navy on-time [tick]
	button "Start" [start-suite] return

	lbl "Here is your input:" txt-input: content 400x100 return
	;lbl "Here is your input:" txt-input: field 400x100 return

	lbl "Your goal is to get this result:" ;return
	;pad 210x0
	txt-goal: content "[ ... ^/^/^/^/^/^/^/ ... ]" return
	;txt-goal: content 400x175 {["a" "b" "c"]} return
	
	lbl "How do you want to split? :" fld-rule: field on-enter [split-it]  hint ""
	button "Split (Enter | F5)" [split-it] return
	pad 210x0 lbl-rule-err: txt 400 font-color red return
	lbl "Here is your result:" ;return
	;pad 20x0
	txt-result: content "[ ... ^/^/^/^/^/^/^/ ... ]" 
	success-marker: text 30x30 "" bold font-size 18 ; with [font: make font! [size: 18 style: 'bold]]
	return
	
	lbl "Notes:" fld-notes: area font-size 12 400x75 ;on-change [cur-task/notes]
	return
	lbl "Rate this task:" txt 35 "Easy" slider 50% 190 [rate-task face/data] txt 35 "Hard" 
	pad 20x0 f-upvote: vote "👍" [vote 1] f-downvote: vote "👎" [vote -1] return
	;pad 300x20
	lbl-stats: lbl 300 font-color gray "Ready? Steady. Go!"
	button "Help (F1)" [show-help] 
	button "Prev Task (F6)" [prev-task]
	button "Next Task (F8)" [next-task]
	pad 35x0 
	button "Save" [save-results]
	;return button "Halt" [halt]
	button "Open" [open-session-file]
	do [show-cur-task]
	button "Halt" [print "" halt]
][
	text: "Practice Split"
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
;						#"+" [vote +1]
;						#"-" [vote -1]
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
						page-up    [prev-task]
						page-down  [next-task]
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
