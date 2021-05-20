Red []

; b: list of inputs
; repeat i length? b [print mold make map! compose [id: (to issue! form i] input: (b/:i]]]

[
;	[
;		id:    #_	; #_ doesn't show in app. Use as a template
;		;desc:  ""
;		input: "" 	; string or block
;		goal:  []  	; expected output, always a block
;	;	time:  none
;	;	tries: []	; be able to see what they actually tried
;	;	notes: none	; [input goal rule note]
;	]
	[
	    id: #1
		input: "a,b,c"
		goal:  ["a" "b" "c"]
	]
;	[
;	    id: #1b
;	    input: "a b c"
;		goal:  ["a" "b" "c"]
;	]
	[
	    id: #2
	    input: "abc,de,fghi,jk"
	    goal: ["abc" "de" "fghi" "jk"]
	]
	[
	    id: #3
	    input: "abc<br>de<br>fghi<br>jk"
	    goal: ["abc" "de" "fghi" "jk"]
	]
	[
	    id: #4
	    input: "1.2,3."
	    goal: ["1" "2" "3" ""]
	]
	[
	    id: #5
	    input: "-aa-aa'a"
	    goal: ["-" "-" "'a"]
	]
	[
	    id: #6
	    input: "abc|de/fghi:jk"
	    goal: ["abc" "de" "fghi" "jk"]
	]
;	[
;	    id: #7
;	    input: "{key-a=1^/key-b=2:^/key-c=3}"
;	]
	[
	    id: #8
	    input: "PascalCaseName"
	    goal: ["Pascal" "Case" "Name"]
	]
	[
	    id: #9
	    input: "camelCaseName"
	    goal: ["camel" "Case" "Name"]
	]
;	[
;	    id: #10
;	    input: {"<br>abc<br>de<br><para><br>fghi<br>jk<br>"}
;	]
;	[
;	    id: #11
;	    input: {"1.2.3-alpha.b+2045.RC3"}
;	]
;	[
;	    id: #12
;	    input: {"PascalCaseName camelCaseName dash-marked-name under_marked_name"}
;	]
	[
	    id: #13
	    input: "YYYYMMDD/HHMMSS"
	    goal: ["YYYY" "MM" "DD" "HH" "MM" "SS"]
	]
	[
	    id: #14
	    input: "Mon, 24 Nov 1997"
	    goal: ["Mon" "24" "Nov" "1997"]
	]
	[
	    id: #15
	    input: [1 2 3 4 5 6]
	    goal: [[2 4 6] [1 3 5]]
	]
	[
	    id: #16
	    input: [1 2 3 4 5 6]
	    goal: [[1 3 5] [2 4 6]]
	]
	[
	    id: #17
	    input: [1 2 [3] 4 5 6 [3] 7 8 9]
	    goal: [[1 2] [4 5 6] [7 8 9]]
	]
	[
	    id: #18
	    input: [1 2 3 4 5 6]
	    goal: [[1 2 3] [4 5 6]]
	]
	[
	    id: #19
	    input: [1 2 3 4 5 6]
	    goal: [[1 2] [3] [4 5 6]]
	]
	
;	[
;	    id: #18
;	    input: {[1 2.3 /a word "str" #iss x: :y]}
;	]
;	[
;	    id: #19
;	    input: {[1 2.3 /a word "str" #iss x: :y <T>]}
;	]
;	[
;	    id: #20
;	    input: "[1 2 3 space 4 5 6 space 7 8 9]"
;	]
;	[
;	    id: #21
;	    input: {[1 2.3 /mark word "str" /mark #iss x: :y]}
;	]
]
