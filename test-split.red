Red []

do %split.red

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

do [ ; comment
	test: func [block expected-result /local res err] [
		if error? set/any 'err try [
			print [mold/only :block newline tab mold res: do block]
			if res <> expected-result [print [tab 'FAILED! tab 'expected mold expected-result]]
		][
			print [mold/only :block newline tab "ERROR!" mold err]
		]
	]
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

