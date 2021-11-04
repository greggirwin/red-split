Red []

do %split-r.red

trace?: on
dbg: :print
show-all?: yes

comment {
	split-r "abc^M^Jde^Mfghi^Jjk" [crlf | #"^M" | newline]]     ["abc" "de" "fghi" "jk"]
	
	split-r "abc     de fghi  jk" [some #" "]]                  ["abc" "de" "fghi" "jk"]
	
	split-r "a,b,c^/d,e^/f,g,h,i^/j,k" [by newline then comma (to word!)]  
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
			if any [trace? show-all?] [print [mold/only :block newline tab mold res]]
			if res <> expected-result [
				if all [not trace? not show-all?] [print [mold/only :block newline tab mold res]]
				print [tab 'FAILED! tab 'expected mold expected-result]
			]
		][
			print [mold/only :block newline tab "ERROR!" mold err]
		]
		if any [trace? show-all?] [print ""]
	]


;-------------------------------------------------------------------------------

tests: [
	[split-r/first [1 2 3 4 5 6 3 7 8] 3]				[ [1 2 3] [4 5 6 3 7 8] ]
	[split-r/first/after [1 2 3 4 5 6 3 7 8] 3]			[ [1 2 3] [4 5 6 3 7 8] ]
	[split-r/first/quoted [1 2 3 4 5 6 3 7 8] 3]		[ [1 2  ] [4 5 6 3 7 8] ]
	[split-r/first/quoted/after [1 2 3 4 5 6 3 7 8] 3]	[ [1 2 3] [4 5 6 3 7 8] ]
	;[split-r/last [1 2 3 4 5 6 3 7 8] 3]				[ [1 2 3 4 5 6] [3 7 8] ]
	;[split-r/last/after [1 2 3 4 5 6 3 7 8] 3]			[ [1 2 3 4 5 6 3] [7 8] ]

	[split-r/first [1 2 3 4 5 6 3 7 8] -1]				[ [] [1 2 3 4 5 6 3 7 8] ]
	[split-r/first [1 2 3 4 5 6 3 7 8] 0]				[ [] [1 2 3 4 5 6 3 7 8] ]
	[split-r/first [1 2 3 4 5 6 3 7 8] 10]				[ [1 2 3 4 5 6 3 7 8] [] ]

	;[split-r/last [1 2 3 4 5 6 3 7 8] -1]				[ [1 2 3 4 5 6 3 7 8] [] ]
	;[split-r/last [1 2 3 4 5 6 3 7 8] 0]				[ [1 2 3 4 5 6 3 7 8] [] ]
	;[split-r/last [1 2 3 4 5 6 3 7 8] 10]				[ [] [1 2 3 4 5 6 3 7 8] ]

	[split-r/first "123456378" 3]						["123" "456378"]
	[split-r/first/after "123456378" 3]					["123" "456378"]
	;[split-r/last "123456378" 3]						["123456" "378"]
	;[split-r/last/after "123456378" 3]					["1234563" "78"]

	[split-r/first "123456378" #"3"]					["12" "456378"]
	[split-r/first/after "123456378" #"3"]				["123" "456378"]
	;[split-r/last "123456378" #"3"]					["123456" "78"]
	;[split-r/last/after "123456378" #"3"]				["1234563" "78"]

	[split-r/first "123456378" #"/"]					["123456378"]
	[split-r/first/after "123456378" #"/"]				["123456378"]
	;[split-r/last "123456378" #"/"]					["123456378"]
	;[split-r/last/after "123456378" #"/"]				["123456378"]

	[split-r "" 4]  []
	;[split-r "" 0]  [""]			; invalid call
	[split-r "" comma]  [""]
	[split-r " " comma]  [" "]
	[split-r "," comma]  ["" ""]
	[split-r "a," comma]  ["a" ""]
	[split-r ",a" comma]  ["" "a"]
	[split-r ",,," comma]  ["" "" "" ""]
	[split-r "aaa" #"a"]  ["" "" "" ""]


	[split-r "1234567812345678" 4]  ["1234" "5678" "1234" "5678"]

	[split-r "1234567812345678" 3]  ["123" "456" "781" "234" "567" "8"]
	[split-r "1234567812345678" 5]  ["12345" "67812" "34567" "8"]

	[split-r "abc,de,fghi,jk" #","]              ["abc" "de" "fghi" "jk"]
	[split-r "abc<br>de<br>fghi<br>jk" <br>]     ["abc" "de" "fghi" "jk"]

	[split-r "line 1;^/line 2;^/line 3;^/" ";^/"]  ["line 1" "line 2" "line 3" ""]
	[split-r "line_1:^/line_2:^/line_3:^/" #"^/"]  ["line_1:" "line_2:" "line_3:" ""]

	[split-r "a.b.c" "."]     ["a" "b" "c"]
	[split-r "c c" " "]       ["c" "c"]
	[split-r "1,2,3" " "]     ["1,2,3"]
	[split-r "1,2,3" ","]     ["1" "2" "3"]
	[split-r "1,2,3," ","]    ["1" "2" "3" ""]
	[split-r "1,2,3," charset ",."]    ["1" "2" "3" ""]
	[split-r "1.2,3." charset ",."]    ["1" "2" "3" ""]

	;!! Seen as dialected delimiter in block if we don't require `once|every`
	[split-r "-a-a" ["a"]]    ["-" "-" ""]
	[split-r "-aa-aa'a" ["aa"]]    ["-" "-" "'a"]

	;-------------------------------------------------------------------------------
	[split-r "abc|de/fghi:jk" charset "|/:"]                     ["abc" "de" "fghi" "jk"]

	;!! If there are non-literal values, you have to double-block
	;   parse rules. This isn't great.
	[split-r "abc^M^Jde^Mfghi^Jjk" ["^M^/" | #"^M" | "^/"]]     ["abc" "de" "fghi" "jk"]
;	[split-r "abc^M^Jde^Mfghi^Jjk" [crlf | #"^M" | newline]]     ["abc" "de" "fghi" "jk"]
;	[split-r "abc     de fghi  jk" [some #" "]]                  ["abc" "de" "fghi" "jk"]
	[split-r "abc^M^Jde^Mfghi^Jjk" [[crlf | #"^M" | newline]]]     ["abc" "de" "fghi" "jk"]
	[split-r "abc     de fghi  jk" [[some #" "]]]                  ["abc" "de" "fghi" "jk"]

	;---- Functions ----------------------------------------------------------------

	[split-r [1 2 3 4 5 6] :even?]	[[1] [3] [5] []]
	[split-r [1 2 3 4 5 6] :odd?]	[[] [2] [4] [6]]
	[split-r [1 2.3 /a word "str" #iss x: :y] :refinement?]	[[1 2.3] [word "str" #iss x: :y]]
	[split-r [1 2.3 /a word "str" #iss x: :y] :number?]		[[] [] [/a word "str" #iss x: :y]]
	[split-r [1 2.3 /a word "str" #iss x: :y] :any-word?]	[[1 2.3 /a] ["str" #iss] [] []]
	[split-r [1 2.3 /a word "str" #iss x: :y] :all-word?]	[[1 2.3] [] ["str"] [] [] []]

	[split-r [1 2 3 4 5 6] [:even?]] [[1] [3] [5] []]
	[split-r [1 2 3 4 5 6] [:odd?]]	 [[] [2] [4] [6]]

	;-------------------------------------------------------------------------------

	[split-r [1 2.3 /a word "str" #iss x: :y <T>] [:word? :any-string?]]	[[1 2.3 /a] [#iss x: :y <T>]]
	;-------------------------------------------------------------------------------

	; datatypes and typesets split-r at every delimiter, because you can achieve
	; the filter/partition behavior with funcs. But is this behavior useful?
	; Not as much because it throws away the delimiting value. In order to be
	; more useful, you need to use before/after.
	[split-r [1 2.3 /a word "str" #iss x: :y] refinement!]	[[1 2.3] [word "str" #iss x: :y]]
	[split-r [1 2.3 /a word "str" #iss x: :y] number!]		[[] [] [/a word "str" #iss x: :y]]
	[split-r [1 2.3 /a word "str" #iss x: :y] any-word!]	[[1 2.3 /a] ["str" #iss] [] []]

	; get-word/set-word delims
	[split-r [1 2.3 /a x: :y word "str" #iss] to set-word! 'x]	[[1 2.3 /a] [:y word "str" #iss]]
	[split-r [1 2.3 /a x: :y word "str" #iss] to get-word! 'y]	[[1 2.3 /a x:] [word "str" #iss]]
	[split-r [1 2.3 /a x: :y word "str" #iss] first [x:]]		[[1 2.3 /a] [:y word "str" #iss]]
	[split-r [1 2.3 /a x: :y word "str" #iss] first [:y]]		[[1 2.3 /a x:] [word "str" #iss]]
	[split-r [1 2.3 /a x: :y word "str" #iss] quote x:]			[[1 2.3 /a] [:y word "str" #iss]]
	[split-r [1 2.3 /a x: :y word "str" #iss] quote :y]			[[1 2.3 /a x:] [word "str" #iss]]

	;-------------------------------------------------------------------------------
	;Currently without /only series is divided into n groups of exatly same length and rest is gatheres 
	;into additional group (even if empty). 
	;With /only exactly N groups are returned with redistributed elements so as to consume whole series, but groups' lengths can vary by 1
	[split-r [1 2 3 4 5 6]      [into 2 groups]]  [[1 2 3] [4 5 6] []]  
	[split-r "1234567812345678" [into 2 groups]]  ["12345678" "12345678" ""]
	[split-r "1234567812345678" [into 3 groups]]  ["12345" "67812" "34567" "8"]
	[split-r "1234567812345678" [into 5 groups]]  ["123" "456" "781" "234" "567" "8"]
	
	[split-r [1 2 3 4 5 6]      [into 2 groups only]]  [[1 2 3] [4 5 6]]  
	[split-r "1234567812345678" [into 2 groups only]]  ["12345678" "12345678"]
	[split-r "1234567812345678" [into 3 groups only]]  ["123456" "78123" "45678"]
	[split-r "1234567812345678" [into 5 groups only]]  ["1234" "567" "812" "345" "678"]

	; Dlm longer than series
	[split-r "123"   [into 6 groups]]		["" "" "" "" "" "" "123"];["1" "2" "3" "" "" ""] ;or ["1" "2" "3"]
	[split-r [1 2 3] [into 6 groups]]		[[] [] [] [] [] [] [1 2 3]]
	[split-r quote (1 2 3) [into 6 groups]]	[() () () () () () (1 2 3)]
	
	[split-r "123"   [into 6 groups only]]	["1" "2" "3" "" "" ""]
	[split-r [1 2 3] [into 6 groups only]]  [[1] [2] [3] [] [] []]


	[split-r [1 2 3 4 5 6] [2 1 3]]                  [[1 2] [3] [4 5 6]]
	[split-r "1234567812345678" [4 4 2 2 1 1 1 1]]   ["1234" "5678" "12" "34" "5" "6" "7" "8"]
	[split-r first [(1 2 3 4 5 6 7 8 9)] 3]          [(1 2 3) (4 5 6) (7 8 9)]
	[split-r #{0102030405060708090A} [4 3 1 2]]      [#{01020304} #{050607} #{08} #{090A}]

	[split-r [1 2 3 4 5 6] [2 1]]                [[1 2] [3] [4 5] [6]]
	[split-r [1 2 3 4 5 6] [2 1 3 5]]            [[1 2] [3] [4 5 6] []]
	[split-r [1 2 3 4 5 6] [2 1 6]]              [[1 2] [3] [4 5 6]]
	;Negative size skips N elements
	[split-r [1 2 3 4 5 6] [2 -2 2]]             [[1 2] [5 6]]

	[split-r "YYYYMMDD/HHMMSS"  [4 2 2 -1 2 2 2]]	["YYYY" "MM" "DD" "HH" "MM" "SS"]
	[split-r "Mon, 24 Nov 1997" [3 -2 2 -1 3 -1 4]]	["Mon" "24" "Nov" "1997"]

	[split-r "1,2,3" [by #","]]      ["1" "2" "3"]
	[split-r "1,2,3" [at #","]]      ["1" #"," "2" #"," "3"]
	[split-r "1,2,3" [before #","]]  ["1" ",2" ",3"]
	[split-r "1,2,3" [after #","]]   ["1," "2," "3"]

	[split-r ",1,2,3," [by #","]]      ["" "1" "2" "3" ""]
	[split-r ",1,2,3," [at #","]]      ["" #"," "1" #"," "2" #"," "3" #"," ""]
	[split-r ",1,2,3," [before #","]]  [",1" ",2" ",3" ","]	; delim goes with next value
	[split-r ",1,2,3," [after #","]]   ["," "1," "2," "3,"]  ; delim goes with prev value

	[split-r "1 2 3" [by #","]]      ["1 2 3"]
	[split-r "1 2 3" [at #","]]      ["1 2 3"]
	[split-r "1 2 3" [before #","]]  ["1 2 3"]
	[split-r "1 2 3" [after #","]]   ["1 2 3"]

	; Spec too many counts
	[split-r "1,2,3"   [by 5 #","]]		 ["1" "2" "3"]
	[split-r "1,2,3"   [at 5 #","]]		 ["1" #"," "2" #"," "3"]
	[split-r "1,2,3"   [before 5 #","]]	 ["1" ",2" ",3"]
	[split-r "1,2,3"   [after 5 #","]] 	 ["1," "2," "3"]
	[split-r ",1,2,3," [by 5 #","]]		 ["" "1" "2" "3" ""]
	[split-r ",1,2,3," [before 5 #","]]	 [",1" ",2" ",3" ","]
	[split-r ",1,2,3," [after 5 #","]]	 ["," "1," "2," "3,"]
	[split-r ",1,2,3," [by 99 #","]]	 ["" "1" "2" "3" ""]
	[split-r ",1,2,3," [before 99 #","]] [",1" ",2" ",3" ","]
	[split-r ",1,2,3," [after 99 #","]]	 ["," "1," "2," "3,"]

	; TBD add error checks to tests
	; These SHOULD fail
	;[split-r ",1,2,3," [#"," 0 times]]	["," "1," "2," "3,"]
	;[split-r ",1,2,3," [#"," -1 times]]	["," "1," "2," "3,"]



	[split-r "aaa" [before #"a"]]  ["a" "a" "a"]

	[split-r "PascalCaseName" charset [#"A" - #"Z"]] ["" "ascal" "ase" "ame"]
	[split-r "PascalCaseName" reduce ['before charset [#"A" - #"Z"]]] ["Pascal" "Case" "Name"]
	[split-r "PascalCaseName" [before (charset [#"A" - #"Z"])]]  ["Pascal" "Case" "Name"]
	[split-r "PascalCaseName" compose [before (charset [#"A" - #"Z"])]]  ["Pascal" "Case" "Name"]
	[split-r "a,b,c" [before (charset [#"A" - #"Z"])]]  ["a,b,c"]

	[split-r "PascalCaseNameAndMoreToo" reduce [charset [#"A" - #"Z"] 3 'times]] ["" "ascal" "ase" "ameAndMoreToo"]
	[split-r "PascalCaseNameAndMoreToo" reduce ['before charset [#"A" - #"Z"] 3 'times]] ["Pascal" "Case" "Name" "AndMoreToo"]
	[split-r "PascalCaseNameAndMoreToo" reduce ['after charset [#"A" - #"Z"] 3 'times]] ["P" "ascalC" "aseN" "ameAndMoreToo"]
	[split-r "Pascal^/Case^/Name^/And^/More^/Too^/" reduce ['after newline 3 'times]] ["Pascal^/" "Case^/" "Name^/" {And^/More^/Too^/}]
	[split-r "^/Pascal^/Case^/Name^/And^/More^/Too^/" reduce ['after newline 3 'times]] ["^/" "Pascal^/" "Case^/" {Name^/And^/More^/Too^/}]
	; Delim at end
	[split-r "PascalCaseNameAndMoreTooZ" compose [(charset [#"A" - #"Z"]) up to 3 times]] ["" "ascal" "ase" "ameAndMoreTooZ"]

	[split-r "camelCaseNameAndMoreToo" reduce ['once charset [#"A" - #"Z"]]] ["camel" "aseNameAndMoreToo"]
	[split-r "camelCaseNameAndMoreToo" reduce ['once 'before charset [#"A" - #"Z"]]] ["camel" "CaseNameAndMoreToo"]
	[split-r "camelCaseNameAndMoreToo" reduce ['once 'after charset [#"A" - #"Z"]]] ["camelC" "aseNameAndMoreToo"]

	[split-r "Pascal^/Case^/Name^/And^/More^/Too^/" reduce ['first newline]] ["Pascal" {Case^/Name^/And^/More^/Too^/}]
	[split-r "Pascal^/Case^/Name^/And^/More^/Too^/" reduce ['at 'first newline]] ["Pascal" {Case^/Name^/And^/More^/Too^/}]
	[split-r "Pascal^/Case^/Name^/And^/More^/Too^/" reduce ['after 'first newline]] ["Pascal^/" {Case^/Name^/And^/More^/Too^/}]
	[split-r "Pascal^/Case^/Name^/And^/More^/Too^/" reduce ['before 'first newline]] ["Pascal" {^/Case^/Name^/And^/More^/Too^/}]
	[split-r "Pascal^/Case^/Name^/And^/More^/Too" reduce ['last newline]] [{Pascal^/Case^/Name^/And^/More} "Too"]
	[split-r "Pascal^/Case^/Name^/And^/More^/Too" reduce ['at 'last newline]] [{Pascal^/Case^/Name^/And^/More} "Too"]
	[split-r "Pascal^/Case^/Name^/And^/More^/Too" reduce ['after 'last newline]] [{Pascal^/Case^/Name^/And^/More^/} "Too"]
	[split-r "Pascal^/Case^/Name^/And^/More^/Too" reduce ['before 'last newline]] [{Pascal^/Case^/Name^/And^/More} "^/Too"]

	[split-r-at-index "abcdef" 0] 			["" "abcdef"]
	[split-r-at-index/last "abcdef" 0] 		["abcdef" ""]
	[split-r-at-index "abcdef" 1] 			["a" "bcdef"]
	[split-r-at-index/last "abcdef" 1] 		["abcde" "f"]

	[split-r-at-index at "abcdef" 3 -1]	["b" "cdef"]
	[split-r-at-index at "abcdef" 3 0] 	["" "cdef"]
	[split-r-at-index at "abcdef" 3 1]	["c" "def"]

	[split-r [1 2 3 4 5 6 3 7 8 9]     [quoted 3]]		[[1 2] [4 5 6] [7 8 9]]
	[split-r [1 2 [3] 4 5 6 [3] 7 8 9] [quoted [3]]]	[[1 2] [4 5 6] [7 8 9]]

	[split-r [1 2 3 4 5 6 3 7 8 9]     [before quoted 3]]		[[1 2] [3 4 5 6] [3 7 8 9]]
	[split-r [1 2 3 4 5 6 3 7 8 9]     [after quoted 3]]		[[1 2 3] [4 5 6 3] [7 8 9]]
	[split-r [1 2 3 4 5 6 3 7 8 9]     [before last quoted 3]]	[[1 2 3 4 5 6] [3 7 8 9]]
	[split-r [1 2 3 4 5 6 3 7 8 9]     [after last quoted 3]]	[[1 2 3 4 5 6 3] [7 8 9]]

	; Paren tests
	[split-r [1 2 (3) 4 5 6 (3) 7 8 9] [quoted (3)]]			[[1 2] [4 5 6] [7 8 9]]
	[split-r [1 2 (a) 4 5 6 (a) 7 8 9] [before quoted (a)]]	[[1 2] [(a) 4 5 6] [(a) 7 8 9]]
	[split-r "aaabaaacaaabaaad" (charset "bcd")]		["aaa" "aaa" "aaa" "aaa" ""]
	[split-r "aaabaaacaaabaaad" [(charset "bcd")]]	["aaa" "aaa" "aaa" "aaa" ""]

	; Multi-split-r tests
			
	[split-r "abc<br>de<br><para>fghi<br>jk" [by <para> then <br>]]     [["abc" "de" ""] ["fghi" "jk"]]
	[split-r "abc<br>de<br>FG<para>fghi<br>jk" [by <para> then <br>]]     [["abc" "de" "FG"] ["fghi" "jk"]]
	[split-r "abc<br>de<para><br>fghi<br>jk" [by <para> then <br>]]     [["abc" "de"] ["" "fghi" "jk"]]
	[split-r "<br>abc<br>de<br><para><br>fghi<br>jk<br>" [by <para> then <br>]]     [["" "abc" "de" ""] ["" "fghi" "jk" ""]]

	[
		split-r "<br>abc<br>de<br><para><br>fghi<br>jk<br>"
		[by [before <para>] then [after <br>]]
	] [["<br>" "abc<br>" "de<br>"] ["<para><br>" "fghi<br>" "jk<br>"]]

	[
		split-r "Pas_cal^/Ca_se^/Na_me^/XXX^/YY_YY^/ZZZ"
		compose/deep [
			by   [after (newline) 3 times]
			then #"_"
		]
	] [["Pas" "cal^/"] ["Ca" "se^/"] ["Na" "me^/"] ["XXX^/YY" "YY^/ZZZ"]]

	[
		split-r "PascalCaseName camelCaseName dash-marked-name under_marked_name"
		compose/deep [
			by   (space)
			then (charset [#"A" - #"Z" "-_"])
		]
	] [["" "ascal" "ase" "ame"] ["camel" "ase" "ame"] ["dash" "marked" "name"] ["under" "marked" "name"]]

	[
		split-r "PascalCaseName camelCaseName dash-marked-name under_marked_name"
		compose/deep [
			by   (space)
			then [before (charset [#"A" - #"Z" "-_"])]
		]
	] [["Pascal" "Case" "Name"] ["camel" "Case" "Name"] ["dash" "-marked" "-name"] ["under" "_marked" "_name"]]

	[
		split-r [1 2 3 space 4 5 6 space 7 8 9]
		compose [
			by   [quoted space]
			then (:even?)
		]
	] [ [[2] [1 3]]   [[4 6] [5]]   [[8] [7 9]] ]

	[
		split-r [1 2 3 space 4 5 6 space 7 8 9]
		compose [
			by   [:space]
			then (:even?)
		]
	] [ [[2] [1 3]]   [[4 6] [5]]   [[8] [7 9]] ]

	[
		split-r {{key-a=1^/key-b=2^/key-c=3}}
		[by newline then by #"="]
	] [["{key-a" "1"] ["key-b" "2"] ["key-c" "3}"]]

;	[
;		split-r {{key-a=1^/key-b=2^/key-c=3}}
;		[by newline then by equal]
;	] [["{key-a" "1"] ["key-b" "2"] ["key-c" "3}"]]

	; Deeper nesting of multi-split-r rules
;	[
;		split-r [1 x 2 x 3 space 4 y 5 y 6 space 7 z 8 z 9]
;		compose [
;			by   ['space]
;			then (word!)
;			then (:even?)
;		]
;	] [ [[2] [1 3]]   [[4 6] [5]]   [[8] [7 9]] ]
	

;"PascalCaseName"

;	[split-r/at [1 2.3 /a word "str" #iss x: :y]  4    []]	[[1 2.3 /a word] ["str" #iss x: :y]]
;	;!! Splitting /at with a non-integer excludes the delimiter from the result
;	[split-r/at [1 2.3 /a word "str" #iss x: :y] "str" []]	[[1 2.3 /a word] [#iss x: :y]]
;	[split-r/at [1 2.3 /a word "str" #iss x: :y] 'word []]	[[1 2.3 /a] ["str" #iss x: :y]]

	;[split-r "The sum is (a + b)." charset "()"] []
	;[split-r "The sum is :(a + b):." [":(" | "):"]] []
]
foreach [pattern result] tests [test pattern result]
;-------------------------------------------------------------------------------

print 'done
