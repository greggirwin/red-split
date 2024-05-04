Red []

do %split.red

;trace?: on
;dbg: :print
;show-all?: yes

comment {
	split "abc^M^Jde^Mfghi^Jjk" [crlf | #"^M" | newline]]     ["abc" "de" "fghi" "jk"]
	
	split "abc     de fghi  jk" [some #" "]]                  ["abc" "de" "fghi" "jk"]
	
	split "a,b,c^/d,e^/f,g,h,i^/j,k" [by newline then comma (to word!)]  
		[
			[a b c]
			[d e]
			[f g h i]
			[j k]
		]

		
}

	test: func [block expected-result /local res err] [
		if error? set/any 'err try [
			res: do block
			if any [trace show-all?] [print [mold/only :block newline tab mold res]]
			if res <> expected-result [
				if all [not trace not show-all?] [print [mold/only :block newline tab mold res]]
				print [tab 'FAILED! tab 'expected mold expected-result]
			]
		][
			print [mold/only :block newline tab "ERROR!" mold err]
		]
		if any [trace show-all?] [print ""]
	]

do [ ; comment
;	test: func [block expected-result /local res err] [
;		if error? set/any 'err try [
;			print [mold/only :block newline tab mold res: do block]
;			if res <> expected-result [print [tab 'FAILED! tab 'expected mold expected-result]]
;		][
;			print [mold/only :block newline tab "ERROR!" mold err]
;		]
;	]
	split-once-tests: [
		[split-once [1 2 3 4 5 6 3 7 8] 3]				[ [1 2 3] [4 5 6 3 7 8] ]
		[split-once/after [1 2 3 4 5 6 3 7 8] 3]		[ [1 2 3] [4 5 6 3 7 8] ]
		[split-once/value [1 2 3 4 5 6 3 7 8] 3]		[ [1 2  ] [4 5 6 3 7 8] ]
		[split-once/value/after [1 2 3 4 5 6 3 7 8] 3]	[ [1 2 3] [4 5 6 3 7 8] ]
		[split-once/last [1 2 3 4 5 6 3 7 8] 3]			[ [1 2 3 4 5 6] [3 7 8] ]
		[split-once/last/after [1 2 3 4 5 6 3 7 8] 3]	[ [1 2 3 4 5 6 3] [7 8] ]

		[split-once [1 2 3 4 5 6 3 7 8] -1]				[ [] [1 2 3 4 5 6 3 7 8] ]
		[split-once [1 2 3 4 5 6 3 7 8] 0]				[ [] [1 2 3 4 5 6 3 7 8] ]
		[split-once [1 2 3 4 5 6 3 7 8] 10]				[ [1 2 3 4 5 6 3 7 8] [] ]

		[split-once/last [1 2 3 4 5 6 3 7 8] -1]		[ [1 2 3 4 5 6 3 7 8] [] ]
		[split-once/last [1 2 3 4 5 6 3 7 8] 0]			[ [1 2 3 4 5 6 3 7 8] [] ]
		[split-once/last [1 2 3 4 5 6 3 7 8] 10]		[ [] [1 2 3 4 5 6 3 7 8] ]

		[split-once "123456378" 3]						["123" "456378"]
		[split-once/after "123456378" 3]				["123" "456378"]
		[split-once/last "123456378" 3]					["123456" "378"]
		[split-once/last/after "123456378" 3]			["1234563" "78"]

		[split-once "123456378" #"3"]					["12" "456378"]
		[split-once/after "123456378" #"3"]				["123" "456378"]
		[split-once/last "123456378" #"3"]				["123456" "78"]
		[split-once/last/after "123456378" #"3"]		["1234563" "78"]

		[split-once "123456378" #"/"]					["123456378"]
		[split-once/after "123456378" #"/"]				["123456378"]
		[split-once/last "123456378" #"/"]				["123456378"]
		[split-once/last/after "123456378" #"/"]		["123456378"]
	]
	
	foreach [blk res] split-once-tests [test blk res]
	;halt
]

;e.g. [
;	blk: [a b c d e f g h i j k]
;	split-var-parts blk [1 2 3]
;	split-var-parts blk [1 -2 3]
;	split-var-parts blk [1 -2 3 10]
;]

;-------------------------------------------------------------------------------

do [
;	test: func [block expected-result /local res err] [
;		if error? set/any 'err try [
;			res: do block
;			if any [trace show-all?] [print [mold/only :block newline tab mold res]]
;			if res <> expected-result [
;				if all [not trace not show-all?] [print [mold/only :block newline tab mold res]]
;				print [tab 'FAILED! tab 'expected mold expected-result]
;			]
;		][
;			print [mold/only :block newline tab "ERROR!" mold err]
;		]
;		if any [trace show-all?] [print ""]
;	]

	test [split "" 4]  []
	;test [split "" 0]  [""]			; invalid call
	test [split "" comma]  [""]
	test [split " " comma]  [" "]
	test [split "," comma]  ["" ""]
	test [split "a," comma]  ["a" ""]
	test [split ",a" comma]  ["" "a"]
	test [split ",,," comma]  ["" "" "" ""]
	test [split "aaa" #"a"]  ["" "" "" ""]


	test [split "1234567812345678" 4]  ["1234" "5678" "1234" "5678"]

	test [split "1234567812345678" 3]  ["123" "456" "781" "234" "567" "8"]
	test [split "1234567812345678" 5]  ["12345" "67812" "34567" "8"]

	test [split "abc,de,fghi,jk" #","]              ["abc" "de" "fghi" "jk"]
	test [split "abc<br>de<br>fghi<br>jk" <br>]     ["abc" "de" "fghi" "jk"]

	test [split "line 1;^/line 2;^/line 3;^/" ";^/"]  ["line 1" "line 2" "line 3" ""]
	test [split "line_1:^/line_2:^/line_3:^/" #"^/"]  ["line_1:" "line_2:" "line_3:" ""]

	test [split "a.b.c" "."]     ["a" "b" "c"]
	test [split "c c" " "]       ["c" "c"]
	test [split "1,2,3" " "]     ["1,2,3"]
	test [split "1,2,3" ","]     ["1" "2" "3"]
	test [split "1,2,3," ","]    ["1" "2" "3" ""]
	test [split "1,2,3," charset ",."]    ["1" "2" "3" ""]
	test [split "1.2,3." charset ",."]    ["1" "2" "3" ""]

	;!! Seen as dialected delimiter in block if we don't require `once|every`
	test [split "-a-a" ["a"]]    ["-" "-" ""]
	test [split "-aa-aa'a" ["aa"]]    ["-" "-" "'a"]

	;-------------------------------------------------------------------------------
	test [split "abc|de/fghi:jk" charset "|/:"]                     ["abc" "de" "fghi" "jk"]

	;!! If there are non-literal values, you have to double-block
	;   parse rules. This isn't great.
	test [split "abc^M^Jde^Mfghi^Jjk" ["^M^/" | #"^M" | "^/"]]     ["abc" "de" "fghi" "jk"]
;	test [split "abc^M^Jde^Mfghi^Jjk" [crlf | #"^M" | newline]]     ["abc" "de" "fghi" "jk"]
;	test [split "abc     de fghi  jk" [some #" "]]                  ["abc" "de" "fghi" "jk"]
	test [split "abc^M^Jde^Mfghi^Jjk" [[crlf | #"^M" | newline]]]     ["abc" "de" "fghi" "jk"]
	test [split "abc     de fghi  jk" [[some #" "]]]                  ["abc" "de" "fghi" "jk"]

	;-------------------------------------------------------------------------------

	test [split [1 2 3 4 5 6] :even?]	[[2 4 6] [1 3 5]]
	test [split [1 2 3 4 5 6] :odd?]	[[1 3 5] [2 4 6]]
	test [split [1 2.3 /a word "str" #iss x: :y] :refinement?]	[[/a] [1 2.3 word "str" #iss x: :y]]
	test [split [1 2.3 /a word "str" #iss x: :y] :number?]		[[1 2.3] [/a word "str" #iss x: :y]]
	test [split [1 2.3 /a word "str" #iss x: :y] :any-word?]	[[word x: :y] [1 2.3 /a "str" #iss]]
	test [split [1 2.3 /a word "str" #iss x: :y] :all-word?]	[[/a word #iss x: :y] [1 2.3 "str"]]

	test [split [1 2 3 4 5 6] [:even?]]	[[2 4 6] [1 3 5]]
	test [split [1 2 3 4 5 6] [:odd?]]	[[1 3 5] [2 4 6]]

	;-------------------------------------------------------------------------------

	test [split [1 2.3 /a word "str" #iss x: :y <T>] [:number? :any-string?]]	[[1 2.3] ["str" <T>] [/a word #iss x: :y]]
	
	;-------------------------------------------------------------------------------

	; datatypes and typesets split at every delimiter, because you can achieve
	; the filter/partition behavior with funcs. But is this behavior useful?
	; Not as much because it throws away the delimiting value. In order to be
	; more useful, you need to use before/after.
	test [split [1 2.3 /a word "str" #iss x: :y] refinement!]	[[1 2.3] [word "str" #iss x: :y]]
	test [split [1 2.3 /a word "str" #iss x: :y] number!]		[[] [] [/a word "str" #iss x: :y]]
	test [split [1 2.3 /a word "str" #iss x: :y] any-word!]	[[1 2.3 /a] ["str" #iss] [] []]

	; get-word/set-word delims
	test [split [1 2.3 /a x: :y word "str" #iss] to set-word! 'x]	[[1 2.3 /a] [:y word "str" #iss]]
	test [split [1 2.3 /a x: :y word "str" #iss] to get-word! 'y]	[[1 2.3 /a x:] [word "str" #iss]]
	test [split [1 2.3 /a x: :y word "str" #iss] first [x:]]		[[1 2.3 /a] [:y word "str" #iss]]
	test [split [1 2.3 /a x: :y word "str" #iss] first [:y]]		[[1 2.3 /a x:] [word "str" #iss]]
	test [split [1 2.3 /a x: :y word "str" #iss] quote x:]			[[1 2.3 /a] [:y word "str" #iss]]
	test [split [1 2.3 /a x: :y word "str" #iss] quote :y]			[[1 2.3 /a x:] [word "str" #iss]]

	;-------------------------------------------------------------------------------
	test [split [1 2 3 4 5 6]      [into 2 parts]]    [[1 2 3] [4 5 6]]
	test [split "1234567812345678" [into 2 parts]]  ["12345678" "12345678"]
; Original tests, for unbalanced splitting
;	test [split "1234567812345678" [into 3 parts]]  ["12345" "67812" "345678"]
;	test [split "1234567812345678" [into 5 parts]]  ["123" "456" "781" "234" "5678"]
; New tests for balanced splitting
	test [split "1234567812345678" [into 3 parts]]  ["12345" "678123" "45678"]
	test [split "1234567812345678" [into 5 parts]]  ["123" "456" "7812" "345" "678"]
	
	; Dlm longer than series
; Original tests, for unbalanced splitting
;	test [split "123"   [into 6 parts]]			["1" "2" "3" "" "" ""] ;or ["1" "2" "3"]
;	test [split [1 2 3] [into 6 parts]]			[[1] [2] [3] [] [] []] ;or [[1] [2] [3]]
;	test [split quote (1 2 3) [into 6 parts]]	[(1) (2) (3) () () ()] ;or [(1) (2) (3)]
; New tests for balanced splitting
	test [split "123"   [into 6 parts]]			["1" "" "2" "" "3" ""]
	test [split [1 2 3] [into 6 parts]]			[[1] [] [2] [] [3] []]
	test [split quote (1 2 3) [into 6 parts]]	[(1) () (2) () (3) ()]
	;test [split [1 2 3] [into 6 parts]]     [[1] [2] [3] none none none] ;or [1 2 3]


	test [split [1 2 3 4 5 6] [2 1 3]]                  [[1 2] [3] [4 5 6]]
	test [split "1234567812345678" [4 4 2 2 1 1 1 1]]   ["1234" "5678" "12" "34" "5" "6" "7" "8"]
	test [split first [(1 2 3 4 5 6 7 8 9)] 3]          [(1 2 3) (4 5 6) (7 8 9)]
	;!! Red doesn't have binary! yet
	;test [split #{0102030405060708090A} [4 3 1 2]]      [#{01020304} #{050607} #{08} #{090A}]

; Original tests, for var splitting once
;	test [split [1 2 3 4 5 6] [2 1]]                [[1 2] [3]]
; New tests for var splitting running over entire series
	test [split [1 2 3 4 5 6] [2 1]]                [[1 2] [3] [4 5] [6]]
	test [split [1 2 3 4 5] [2 1]]                  [[1 2] [3] [4 5] []]
	

	test [split [1 2 3 4 5 6] [2 1 3 5]]            [[1 2] [3] [4 5 6] []]

	test [split [1 2 3 4 5 6] [2 1 6]]              [[1 2] [3] [4 5 6]]

	; Old design for negative skip vals
	;test [split [1 2 3 4 5 6] [3 2 2 -2 2 -4 3]]    [[1 2 3] [4 5] [6] [5 6] [3 4 5]]
	; New design for negative skip vals
	test [split [1 2 3 4 5 6] [2 -2 2]]             [[1 2] [5 6]]

	test [split "YYYYMMDD/HHMMSS"  [4 2 2 -1 2 2 2]]	["YYYY" "MM" "DD" "HH" "MM" "SS"]
	test [split "Mon, 24 Nov 1997" [3 -2 2 -1 3 -1 4]]	["Mon" "24" "Nov" "1997"]

	test [split "1,2,3" [at #","]]     	["1" "2" "3"]
	test [split "1,2,3" [before #","]]  ["1" ",2" ",3"]
	test [split "1,2,3" [after #","]]   ["1," "2," "3"]

	test [split ",1,2,3," [at #","]]      ["" "1" "2" "3" ""]
	;!! These are a bit tricky to reason about. The delimiter goes with
	;	the next or previous value, so what constitutes an empty field
	;	at the end, as with simple splitting? These results make the
	;	most sense to me, but I'm only 90% confident in that choice.
	;	The crux being that if a delimiter exists it needs to be in the
	;	result, attached to a part.
	test [split ",1,2,3," [before #","]]  [",1" ",2" ",3" ","]	; delim goes with next value
	test [split ",1,2,3," [after #","]]   ["," "1," "2," "3,"]  ; delim goes with prev value

	test [split "1 2 3" [at #","]]     	["1 2 3"]
	test [split "1 2 3" [before #","]]  ["1 2 3"]
	test [split "1 2 3" [after #","]]   ["1 2 3"]

	; Spec too many counts
	test [split "1,2,3"   [at #"," 5 times]]		["1" "2" "3"]
	test [split "1,2,3"   [before #"," 5 times]]	["1" ",2" ",3"]
	test [split "1,2,3"   [after #"," 5 times]] 	["1," "2," "3"]
	test [split ",1,2,3," [at #"," 5 times]]		["" "1" "2" "3" ""]
	test [split ",1,2,3," [before #"," 5 times]]	[",1" ",2" ",3" ","]
	test [split ",1,2,3," [after #"," 5 times]]		["," "1," "2," "3,"]
	test [split ",1,2,3," [at #"," 99 times]]		["" "1" "2" "3" ""]
	test [split ",1,2,3," [before #"," 99 times]]	[",1" ",2" ",3" ","]
	test [split ",1,2,3," [after #"," 99 times]]	["," "1," "2," "3,"]

	; TBD add error checks to tests
	; These SHOULD fail
	;test [split ",1,2,3," [#"," 0 times]]	["," "1," "2," "3,"]
	;test [split ",1,2,3," [#"," -1 times]]	["," "1," "2," "3,"]



	test [split "aaa" [before #"a"]]  ["a" "a" "a"]

	test [split "PascalCaseName" charset [#"A" - #"Z"]] ["" "ascal" "ase" "ame"]
	test [split "PascalCaseName" reduce ['before charset [#"A" - #"Z"]]] ["Pascal" "Case" "Name"]
	test [split "PascalCaseName" [before (charset [#"A" - #"Z"])]]  ["Pascal" "Case" "Name"]
	test [split "PascalCaseName" compose [before (charset [#"A" - #"Z"])]]  ["Pascal" "Case" "Name"]
	test [split "a,b,c" [before (charset [#"A" - #"Z"])]]  ["a,b,c"]

	test [split "PascalCaseNameAndMoreToo" reduce [charset [#"A" - #"Z"] 3 'times]] ["" "ascal" "ase" "ameAndMoreToo"]
	test [split "PascalCaseNameAndMoreToo" reduce ['before charset [#"A" - #"Z"] 3 'times]] ["Pascal" "Case" "Name" "AndMoreToo"]
	test [split "PascalCaseNameAndMoreToo" reduce ['after charset [#"A" - #"Z"] 3 'times]] ["P" "ascalC" "aseN" "ameAndMoreToo"]
	test [split "Pascal^/Case^/Name^/And^/More^/Too^/" reduce ['after newline 3 'times]] ["Pascal^/" "Case^/" "Name^/" {And^/More^/Too^/}]
	test [split "^/Pascal^/Case^/Name^/And^/More^/Too^/" reduce ['after newline 3 'times]] ["^/" "Pascal^/" "Case^/" {Name^/And^/More^/Too^/}]
	; Delim at end
	test [split "PascalCaseNameAndMoreTooZ" compose [(charset [#"A" - #"Z"]) up to 3 times]] ["" "ascal" "ase" "ameAndMoreTooZ"]

	test [split "camelCaseNameAndMoreToo" reduce ['once charset [#"A" - #"Z"]]] ["camel" "aseNameAndMoreToo"]
	test [split "camelCaseNameAndMoreToo" reduce ['once 'before charset [#"A" - #"Z"]]] ["camel" "CaseNameAndMoreToo"]
	test [split "camelCaseNameAndMoreToo" reduce ['once 'after charset [#"A" - #"Z"]]] ["camelC" "aseNameAndMoreToo"]

	test [split "Pascal^/Case^/Name^/And^/More^/Too^/" reduce ['first newline]] ["Pascal" {Case^/Name^/And^/More^/Too^/}]
	test [split "Pascal^/Case^/Name^/And^/More^/Too^/" reduce ['at 'first newline]] ["Pascal" {Case^/Name^/And^/More^/Too^/}]
	test [split "Pascal^/Case^/Name^/And^/More^/Too^/" reduce ['after 'first newline]] ["Pascal^/" {Case^/Name^/And^/More^/Too^/}]
	test [split "Pascal^/Case^/Name^/And^/More^/Too^/" reduce ['before 'first newline]] ["Pascal" {^/Case^/Name^/And^/More^/Too^/}]
	test [split "Pascal^/Case^/Name^/And^/More^/Too" reduce ['last newline]] [{Pascal^/Case^/Name^/And^/More} "Too"]
	test [split "Pascal^/Case^/Name^/And^/More^/Too" reduce ['at 'last newline]] [{Pascal^/Case^/Name^/And^/More} "Too"]
	test [split "Pascal^/Case^/Name^/And^/More^/Too" reduce ['after 'last newline]] [{Pascal^/Case^/Name^/And^/More^/} "Too"]
	test [split "Pascal^/Case^/Name^/And^/More^/Too" reduce ['before 'last newline]] [{Pascal^/Case^/Name^/And^/More} "^/Too"]

	test [split-at-index "abcdef" 0] 			["" "abcdef"]
	test [split-at-index/last "abcdef" 0] 		["abcdef" ""]
	test [split-at-index "abcdef" 1] 			["a" "bcdef"]
	test [split-at-index/last "abcdef" 1] 		["abcde" "f"]

	test [split-at-index at "abcdef" 3 -1]	["b" "cdef"]
	test [split-at-index at "abcdef" 3 0] 	["" "cdef"]
	test [split-at-index at "abcdef" 3 1]	["c" "def"]

	test [split [1 2 3 4 5 6 3 7 8 9]     [as-delim 3]]		[[1 2] [4 5 6] [7 8 9]]
	test [split [1 2 [3] 4 5 6 [3] 7 8 9] [as-delim [3]]]	[[1 2] [4 5 6] [7 8 9]]

	test [split [1 2 3 4 5 6 3 7 8 9]     [before as-delim 3]]		[[1 2] [3 4 5 6] [3 7 8 9]]
	test [split [1 2 3 4 5 6 3 7 8 9]     [after as-delim 3]]		[[1 2 3] [4 5 6 3] [7 8 9]]
	test [split [1 2 3 4 5 6 3 7 8 9]     [before last as-delim 3]]	[[1 2 3 4 5 6] [3 7 8 9]]
	test [split [1 2 3 4 5 6 3 7 8 9]     [after last as-delim 3]]	[[1 2 3 4 5 6 3] [7 8 9]]

	; Paren tests
	test [split [1 2 (3) 4 5 6 (3) 7 8 9] [as-delim (3)]]			[[1 2] [4 5 6] [7 8 9]]
	test [split [1 2 (a) 4 5 6 (a) 7 8 9] [before as-delim (a)]]	[[1 2] [(a) 4 5 6] [(a) 7 8 9]]
	test [split "aaabaaacaaabaaad" (charset "bcd")]		["aaa" "aaa" "aaa" "aaa" ""]
	test [split "aaabaaacaaabaaad" [(charset "bcd")]]	["aaa" "aaa" "aaa" "aaa" ""]

	; Multi-split tests
			
	test [split "abc<br>de<br><para>fghi<br>jk" [by <para> then <br>]]     [["abc" "de" ""] ["fghi" "jk"]]
	test [split "abc<br>de<br>FG<para>fghi<br>jk" [by <para> then <br>]]     [["abc" "de" "FG"] ["fghi" "jk"]]
	test [split "abc<br>de<para><br>fghi<br>jk" [by <para> then <br>]]     [["abc" "de"] ["" "fghi" "jk"]]
	test [split "<br>abc<br>de<br><para><br>fghi<br>jk<br>" [by <para> then <br>]]     [["" "abc" "de" ""] ["" "fghi" "jk" ""]]

	test [
		split "<br>abc<br>de<br><para><br>fghi<br>jk<br>"
		[by [before <para>] then [after <br>]]
	] [["<br>" "abc<br>" "de<br>"] ["<para><br>" "fghi<br>" "jk<br>"]]

	test [
		split "Pas_cal^/Ca_se^/Na_me^/XXX^/YY_YY^/ZZZ"
		compose/deep [
			by   [after (newline) 3 times]
			then #"_"
		]
	] [["Pas" "cal^/"] ["Ca" "se^/"] ["Na" "me^/"] ["XXX^/YY" "YY^/ZZZ"]]

	test [
		split "PascalCaseName camelCaseName dash-marked-name under_marked_name"
		compose/deep [
			by   (space)
			then (charset [#"A" - #"Z" "-_"])
		]
	] [["" "ascal" "ase" "ame"] ["camel" "ase" "ame"] ["dash" "marked" "name"] ["under" "marked" "name"]]

	test [
		split "PascalCaseName camelCaseName dash-marked-name under_marked_name"
		compose/deep [
			by   (space)
			then [before (charset [#"A" - #"Z" "-_"])]
		]
	] [["Pascal" "Case" "Name"] ["camel" "Case" "Name"] ["dash" "-marked" "-name"] ["under" "_marked" "_name"]]

	test [
		split [1 2 3 space 4 5 6 space 7 8 9]
		compose [
			by   [as-delim space]
			then (:even?)
		]
	] [ [[2] [1 3]]   [[4 6] [5]]   [[8] [7 9]] ]

	test [
		split [1 2 3 space 4 5 6 space 7 8 9]
		compose [
			by   [:space]
			then (:even?)
		]
	] [ [[2] [1 3]]   [[4 6] [5]]   [[8] [7 9]] ]

	test [
		split {{key-a=1^/key-b=2^/key-c=3}}
		[by newline then by #"="]
	] [["{key-a" "1"] ["key-b" "2"] ["key-c" "3}"]]
		
	test [
		split "A split sentence.And another."
		[by [dot up to 2 times] then by space]
	] [["A" "split" "sentence"] ["And" "another"]]


;	test [
;		split {{key-a=1^/key-b=2^/key-c=3}}
;		[by newline then by equal]
;	] [["{key-a" "1"] ["key-b" "2"] ["key-c" "3}"]]

	; Deeper nesting of multi-split rules
;	test [
;		split [1 x 2 x 3 space 4 y 5 y 6 space 7 z 8 z 9]
;		compose [
;			by   ['space]
;			then (word!)
;			then (:even?)
;		]
;	] [ [[2] [1 3]]   [[4 6] [5]]   [[8] [7 9]] ]
	

;"PascalCaseName"

;	test [split/at [1 2.3 /a word "str" #iss x: :y]  4    []]	[[1 2.3 /a word] ["str" #iss x: :y]]
;	;!! Splitting /at with a non-integer excludes the delimiter from the result
;	test [split/at [1 2.3 /a word "str" #iss x: :y] "str" []]	[[1 2.3 /a word] [#iss x: :y]]
;	test [split/at [1 2.3 /a word "str" #iss x: :y] 'word []]	[[1 2.3 /a] ["str" #iss x: :y]]

	;test [split "The sum is (a + b)." charset "()"] []
	;test [split "The sum is :(a + b):." [":(" | "):"]] []
]

;-------------------------------------------------------------------------------

print 'done
