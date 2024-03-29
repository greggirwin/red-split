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
	    id: #01
		category: "Simple split"
		input: "a,b,c"
		goal:  ["a" "b" "c"]
	]
	[
	    id: #02
	    category: "Simple split"
		input: "abc,de,fghi,jk"
	    goal: ["abc" "de" "fghi" "jk"]
	]
	[
	    id: #03
	    input: "abc<br>de<br>fghi<br>jk"
	    goal: ["abc" "de" "fghi" "jk"]
	]
	[
	    id: #04
	    input: "1.2,3."
	    goal: ["1" "2" "3" ""]
	]
	[
	    id: #05
	    input: "-aa-aa'a"
	    goal: ["-" "-" "'a"]
	]
	[
	    id: #06
	    input: "abc|de/fghi:jk"
	    goal: ["abc" "de" "fghi" "jk"]
	]
	[
		id: #07
		input: "aabbbccccddd"
		goal: ["aa" "bbb" "cccc" "ddd"]
	]
	[
	    id: #08
	    input: "PascalCaseName"
	    goal: ["Pascal" "Case" "Name"]
	]
	[
	    id: #09
	    input: "camelCaseName"
	    goal: ["camel" "Case" "Name"]
	]
	[
		id: #10
		input: [0 1 1 3 2 5 4 2 1 6 9]
		goal: [[0 1] [1 3] [2 5] [4] [2] [1 6 9]]
	]
	[
		id: #11
		input: [0 1 1 3 2 5 4 2 1 6 9]
		goal: [[0] [1 1] [3 2] [5 4 2 1] [6] [9]]
	]
	[
	    id: #12
	    input: "A split sentence.And another."
		goal:  [["A" "split" "sentence"] ["And" "another"]]
	]
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
	    input: "a,b,c,d,e,f,g"
	    goal: ["a" "b" "c" "d,e,f,g"]
	]
	[
	    id: #16
	    input: "a,b,c,d,e,f,g"
	    goal: ["a,b,c,d,e,f" "g"]
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
	    ;hint: "as-delim"
	]
	[
		id: #20
		input: [a 1 2 b 4 c 3 6 1]
		goal: [[a 1 2] [b 4] [c 3 6 1]]
	]
	[
		id: #21
		input: [a b 1 c 2 d e f 3]
		goal: [[a b 1] [c 2] [d e f 3]]
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
