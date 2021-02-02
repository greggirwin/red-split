Red [
	Title:   "Red SPLIT functions"
	Author:  "Gregg Irwin"
	File: 	 %split.red
	Tabs:	 4
	Rights:  "Copyright 2021 All Mankind. No rights reserved."
	License: 'MIT
	Notes:   {
		This work is based on the Rebol SPLIT function, which I designed
		along with Gabriele Santilli, if my memory serves me.
		
		The original goal was to have a single function, like ROUND, that
		covered many common cases. The benefit is that users have to learn
		only one function, and help is in one place for all of them. In
		ROUND's case, it subsumes [ceil floor trunc], half-rounding variants
		and rounding to a given scale, for many datatypes. For SPLIT, we
		also have a number of cases to cover. For example:
		
		- Split at a delimiter (into 2 parts)
		- Split into N parts at one or more delimiters
		- Split into N pieces
		- Splint into pieces of size N
		- Split into pieces of varying sizes
		
		For non-string values, like blocks, you can split into groups based
		on a custom function, this is sometimes called GROUP or PARTITION, 
		but also acts like FILTER if your predicate returns a logic result.
		Then you may want to keep one or both partitions.
		
		That's a lot of cases and a lot of flexibility. Even down to whether
		you want to keep the delimiter when splitting/breaking a series, and
		which side the delimiter falls to. 
		
		We can't cover every case while also keeping the code managable and
		the interface not overwhelming or ambiguous.
		
		Where Rebol's SPLIT was small enough to keep all in one func, we 
		have to decide if we want to stay within those feature limits, or
		if we want to grow the capabilities. Either way, dispatching to 
		sub-funcs, with SPLIT as the dialected interface to most or all of
		them makes sense. Each can have a clear name, be used directly if
		we decide to expose them in a named context, and make us thinks in
		terms of a consistent interface for splitting and its results. When
		people need to write new functions for their own needs, using the
		standard model will benefit users from a consistency standpoint,
		along with other funcs designed to consume split results.
		
		The Rebol version has an `/into` refinement, but that is now semi-
		standardized in Red to mean "specify an existing output buffer 
		rather than	returning a new one." That lets advanced users reduce
		memory and GC pressure but uses a nice word previously used to
		mean "into N pieces".
		
	}
]

comment {
	split break divide separate
	join delimit combine append union	; opposites of split
	piece part slice chunk item
	
	VBA:    Split(expression, [ delimiter, [ limit, [ compare ]]])  ; limit=max items returned
	Python: string.split(separator, maxsplit) ; maxsplit=limit
	Ruby:	split(pattern=nil, [limit])
	Java:   string.split(String regex, int limit)
	PHP:    str_split ( string $string , int $length = 1 ) ; into chunks of size $length
	JS:     string.split(separator, limit)
	Swift:  split(separator: Character, maxSplits: Int = Int.max, omittingEmptySubsequences: Bool = true) -> [Substring]
	Go:     strings.Split(str, sep_string)
	Rust:   https://doc.rust-lang.org/std/string/struct.String.html#method.split
			An iterator over substrings of this string slice, separated by characters 
			matched by a pattern.
			The pattern can be a &str, char, a slice of chars, or a function or closure 
			that determines if a character matches.
			split_inclusive keeps the delimiter as part of the preceding element.
			split_at    int break at index N
			split_once  ch  split at first dlm
			split_terminator Equivalent to split, except that the trailing substring is skipped if empty.
}

comment {
	What if SPLIT was fully dialected? That is, 'dlm becomes 'rules and supports
	extra words to clarify intent.
	
	split series [into 5 parts/pieces]
	split series [into parts of size 5]
	split series [piece 5]
	split series [sizes [1 2 3]]
	
	split [at 5]
	split [at last]
	split [at /last]
	split [every 5]
	split [into 5]
	split [at [5 4 2]]	; relative offsets from previous number
	
	; Standard arg	
	split <integer!>			; into N parts, last may be longer (partition)
	split <char! string! bitset!>	; into N parts, at each dlm (int can also be a non-index dlm)
	split <block of integer!>	; into parts at relative offsets
	split <function!>			; into 2 groups, partition by func
	split <block of function!>	; into N+1 groups, partition by func; last group = default
	split <block of char!|str!>	; Split by each dlm successively. 
	; Dialected arg
	split [at <n>]				; into 2 parts, at absolute position
	split [at <dlm>]			; into 2 parts, at first dlm
	split [at last <dlm>]		; into 2 parts, at last dlm
	split [after <n>]			; into 2 parts, after absolute position
	split [after <dlm>]			; into 2 parts, after first dlm
	split [after last <dlm>]	; into 2 parts, after last dlm
	; Use `each` to indicate full splitting? e.g.
	split [at each <dlm>]		; into N parts, at each dlm
	split [after each <dlm>]	; into N parts, after each dlm

	split [at lit <dlm>]		; quote int and paren values to use as non-computed delims?
	
	; EACH or EVERY?
	split [each <n>]			; into ? parts, all of size N, last may be shorter
	; Is INTO ambgiuous, with series funcs that support `/into`?
	split [into <n>]			; into N parts, last may be longer
	; Is SKIP better than AT, to match standard func's behavior?
	split [skip [<i> <j> <k>]]	; relative offsets from previous number
	; Wordy but clear
	split [first by <char!|str!> then by <char!|str!>]	; Split by each dlm successively. 

	split comma
	split [comma]
	split [at comma]
	split [after comma]
	split [once at comma]
	split [twice at comma]
	split [3 times at comma]
	split [integer! times at comma] ; int > 0
	
	split [before every comma]		; keep delim with next value
	split [at every comma]			; don't keep delim
	split [after every comma]		; keep delim with prior value
	split [after each comma]		; each = every
	
	split [
		opt [
			'once					; n: 1
			| 'twice				; n: 2
			| integer! 'times		; n: int > 0
		]
		opt ['at | 'after]			; keep delim with next or previous part
		opt 'each		
		<dlm>
	] 
	
	'before = 'at
	
	BREAK as name for func that eats delims versus keeping them?

	Can `at|after` mean "keep the delim" on one side or the other? Then how do you
	say "don't keep the delim"?
	
	More advanced than I want to think about this late evening, but what about
	a lazy approach? In thinking about SPLIT, you have to allocate all those 
	new pieces maybe just to operate on them. But in an HOF/callback model,
	you could stream them out for aggregation or other processing, just accessing
	them where they lie in the original series. Without copying, or Boris' PART
	func and true slices, there's no protection of the original, which is dangerous
	of course. But it's a declarative, or functional if you prefer, approach, where
	you pass in the splitting criteria and an action to apply to each result. We
	may be able to reserve parens for that, making it consistent with PARSE.
	
}

;map-each: function [
;	"Evaluates body for each value(s) in a series, returning all results."
;	'word [word! block!] "Word, or words, to set on each iteration"
;	data [series! map!] 
;	body [block!]
;] [
;	collect [
;		foreach :word data [
;			if not unset? set/any 'tmp do body [keep/only :tmp]
;		]
;	]
;]
;
;collect: function [
;	"Collect in a new block all the values passed to KEEP function from the body block"
;	body [block!]	"Block to evaluate"
;	/into			"Insert into a buffer instead (returns position after insert)"
;		collected [series!] "The buffer series (modified)"
;][
;	keep: func [v /only][either only [append/only collected v][append collected v]]
;	
;	unless collected [collected: make block! 16]
;	parse body rule: [									;-- selective binding (needs BIND/ONLY support)
;		any [pos: ['keep | 'collected] (pos/1: bind pos/1 'keep) | any-string! | into rule | skip]
;	]
;	do body
;	either into [collected][head collected]
;]

;-------------------------------------------------------------------------------
; Old SPLIT ported to Red

old-split: function [
	"Split a series into pieces; fixed or variable size, fixed number, or at delimiters"
	series [series!] "The series to split"
	;!! If we support /at, dlm could be any-value.
	dlm    ;[block! integer! char! bitset! any-string! any-function!] "Split size, delimiter(s), predicate, or rule(s)." 
	/parts "If dlm is an integer, split into n pieces, rather than pieces of length n."
	/at "Split into 2, at the index position if an integer or the first occurrence of the dlm"
][
	if any-function? :dlm [
		res: reduce [ copy [] copy [] ]
		foreach value series [
			append/only pick res make logic! dlm :value :value
		]
		return res
	]
	if at [
		return reduce either integer? dlm [
			[
				copy/part series dlm
				copy system/words/at series dlm + 1
			]
		][
			;-- Without adding a /tail refinement, we don't know if they want
			;	to split at the head or tail of the delimiter, so we'll exclude
			;	the delimiter from the result entirely. They know what the dlm
			;	was that they passed in, so they can add it back to either side
			;	of the result if they want to.
			[
				copy/part series find series :dlm
				copy find/tail series :dlm
			]
		]
	]
	;print ['split 'parts? parts mold series mold dlm]
	either all [block? dlm  parse dlm [some integer!]][
		map-each len dlm [
			either positive? len [
				copy/part series series: skip series len
			][
				series: skip series negate len
				()										;-- return unset so that nothing is added to output
			]
		]
	][
		size: dlm										;-- alias for readability
		res: collect [
			;print ['split 'parts? parts mold series mold dlm newline]
			parse series case [
				all [integer? dlm  parts][
					if size < 1 [cause-error 'Script 'invalid-arg size]
					count: size - 1
					piece-size: to integer! round/down divide length? series size
					if zero? piece-size [piece-size: 1]
					[
						count [copy series piece-size skip (keep/only series)]
						copy series to end (keep/only series)
					]
				]
				integer? dlm [
					if size < 1 [cause-error 'Script 'invalid-arg size]
					[any [copy series 1 size skip (keep/only series)]]
				]
				'else [									;-- = any [bitset? dlm  any-string? dlm  char? dlm]
					[any [mk1: some [mk2: dlm break | skip] (keep/only copy/part mk1 mk2)]]
				]
			]
		]
		;-- Special processing, to handle cases where they spec'd more items in
		;   /parts than the series contains (so we want to append empty items),
		;   or where the dlm was a char/string/charset and it was the last char
		;   (so we want to append an empty field that the above rule misses).
		fill-val: does [copy either any-block? series [ [] ][ "" ]]
		add-fill-val: does [append/only res fill-val]
		case [
			all [integer? size  parts][
				;-- If the result is too short, i.e., less items than 'size, add
				;   empty items to fill it to 'size.
				;   We loop here, because insert/dup doesn't copy the value inserted.
				if size > length? res [
					loop (size - length? res) [add-fill-val]
				]
			]
			;-- integer? size
			;	If they spec'd an integer size, but did not use /parts, there is
			;	no special filing to be done. The final element may be less than
			;	size, which is intentional.
			;--
			'else [ 									;-- = any [bitset? dlm  any-string? dlm  char? dlm]
				;-- If the last thing in the series is a delimiter, there is an
				;   implied empty field after it, which we add here.
				case [
					bitset? dlm [
						;-- ATTEMPT is here because LAST will return NONE for an 
						;   empty series, and finding none in a bitest is not allowed.
						if attempt [find dlm last series][add-fill-val]
					]
					char? dlm [
						if dlm = last series [add-fill-val]
					]
					string? dlm [
						if all [
							find series dlm
							empty? find/last/tail series dlm
						][add-fill-val]
					]
				]
			]
		]

		res
	]
]
 
 
;-------------------------------------------------------------------------------
 
 
split: function [
	"Split a series into pieces; fixed or variable size, fixed number, or at delimiters"
	series [series!] "The series to split"
	;!! If we support /at, dlm could be any-value.
	dlm    ;[block! integer! char! bitset! any-string! any-function!] "Split size, delimiter(s), predicate, or rule(s)." 
	/parts "If dlm is an integer, split into n pieces, rather than pieces of length n."
	/at "Split into 2, at the index position if an integer or the first occurrence of the dlm"
		opts [block!]
][
	if any-function? :dlm [return filter series :dlm]
	if at [return split-at series :dlm opts]
	if all [block? dlm  parse dlm [some integer!]][return split-parts series :dlm]
	
	;print ['split 'parts? parts mold series mold dlm]
	either all [block? dlm  parse dlm [some integer!]][
		map-each len dlm [
			either positive? len [
				copy/part series series: skip series len
			][
				series: skip series negate len
				()										;-- return unset so that nothing is added to output
			]
		]
	][
		size: dlm										;-- alias for readability
		res: collect [
			;print ['split 'parts? parts mold series mold dlm newline]
			parse series case [
				all [integer? dlm  parts][
					if size < 1 [cause-error 'Script 'invalid-arg size]
					count: size - 1
					piece-size: to integer! round/down divide length? series size
					if zero? piece-size [piece-size: 1]
					[
						count [copy series piece-size skip (keep/only series)]
						copy series to end (keep/only series)
					]
				]
				integer? dlm [
					if size < 1 [cause-error 'Script 'invalid-arg size]
					[any [copy series 1 size skip (keep/only series)]]
				]
				'else [									;-- = any [bitset? dlm  any-string? dlm  char? dlm]
					[any [mk1: some [mk2: dlm break | skip] (keep/only copy/part mk1 mk2)]]
				]
			]
		]
		;-- Special processing, to handle cases where they spec'd more items in
		;   /parts than the series contains (so we want to append empty items),
		;   or where the dlm was a char/string/charset and it was the last char
		;   (so we want to append an empty field that the above rule misses).
		fill-val: does [copy either any-block? series [ [] ][ "" ]]
		add-fill-val: does [append/only res fill-val]
		case [
			all [integer? size  parts][
				;-- If the result is too short, i.e., less items than 'size, add
				;   empty items to fill it to 'size.
				;   We loop here, because insert/dup doesn't copy the value inserted.
				if size > length? res [
					loop (size - length? res) [add-fill-val]
				]
			]
			;-- integer? size
			;	If they spec'd an integer size, but did not use /parts, there is
			;	no special filing to be done. The final element may be less than
			;	size, which is intentional.
			;--
			'else [ 									;-- = any [bitset? dlm  any-string? dlm  char? dlm]
				;-- If the last thing in the series is a delimiter, there is an
				;   implied empty field after it, which we add here.
				case [
					bitset? dlm [
						;-- ATTEMPT is here because LAST will return NONE for an 
						;   empty series, and finding none in a bitest is not allowed.
						if attempt [find dlm last series][add-fill-val]
					]
					char? dlm [
						if dlm = last series [add-fill-val]
					]
					string? dlm [
						if all [
							find series dlm
							empty? find/last/tail series dlm
						][add-fill-val]
					]
				]
			]
		]

		res
	]
]

test: func [block expected-result /local res err] [
	if error? set/any 'err try [
		print [mold/only :block newline tab mold res: do block]
		if res <> expected-result [print [tab 'FAILED! tab 'expected mold expected-result]]
	][
		print [mold/only :block newline tab "ERROR!" mold err]
	]
]

test [split "1234567812345678" 4]  ["1234" "5678" "1234" "5678"]

test [split "1234567812345678" 3]  ["123" "456" "781" "234" "567" "8"]
test [split "1234567812345678" 5]  ["12345" "67812" "34567" "8"]

test [split/parts [1 2 3 4 5 6] 2]       [[1 2 3] [4 5 6]]
test [split/parts "1234567812345678" 2]  ["12345678" "12345678"]
test [split/parts "1234567812345678" 3]  ["12345" "67812" "345678"]
test [split/parts "1234567812345678" 5]  ["123" "456" "781" "234" "5678"]

; Dlm longer than series
test [split/parts "123" 6]       ["1" "2" "3" "" "" ""] ;or ["1" "2" "3"]
test [split/parts [1 2 3] 6]     [[1] [2] [3] [] [] []] ;or [1 2 3]
;test [split/parts [1 2 3] 6]     [[1] [2] [3] none none none] ;or [1 2 3]


test [split [1 2 3 4 5 6] [2 1 3]]                  [[1 2] [3] [4 5 6]]
test [split "1234567812345678" [4 4 2 2 1 1 1 1]]   ["1234" "5678" "12" "34" "5" "6" "7" "8"]
test [split first [(1 2 3 4 5 6 7 8 9)] 3]          [(1 2 3) (4 5 6) (7 8 9)]
;!! Red doesn't have binary! yet
;test [split #{0102030405060708090A} [4 3 1 2]]      [#{01020304} #{050607} #{08} #{090A}]

test [split [1 2 3 4 5 6] [2 1]]                [[1 2] [3]]

test [split [1 2 3 4 5 6] [2 1 3 5]]            [[1 2] [3] [4 5 6] []]

test [split [1 2 3 4 5 6] [2 1 6]]              [[1 2] [3] [4 5 6]]

; Old design for negative skip vals
;test [split [1 2 3 4 5 6] [3 2 2 -2 2 -4 3]]    [[1 2 3] [4 5] [6] [5 6] [3 4 5]]
; New design for negative skip vals
test [split [1 2 3 4 5 6] [2 -2 2]]             [[1 2] [5 6]]

test [split "abc,de,fghi,jk" #","]              ["abc" "de" "fghi" "jk"]
;!! Red doesn't have tag! yet
;test [split "abc<br>de<br>fghi<br>jk" <br>]     ["abc" "de" "fghi" "jk"]

test [split "a.b.c" "."]     ["a" "b" "c"]
test [split "c c" " "]       ["c" "c"]
test [split "1,2,3" " "]     ["1,2,3"]
test [split "1,2,3" ","]     ["1" "2" "3"]
test [split "1,2,3," ","]    ["1" "2" "3" ""]
test [split "1,2,3," charset ",."]    ["1" "2" "3" ""]
test [split "1.2,3." charset ",."]    ["1" "2" "3" ""]

test [split "-a-a" ["a"]]    ["-" "-"]
test [split "-a-a'" ["a"]]    ["-" "-" "'"]

;-------------------------------------------------------------------------------
; to/thru bitset! is broken in R3 now.
test [split "abc|de/fghi:jk" charset "|/:"]                     ["abc" "de" "fghi" "jk"]

; to/thru block! is broken in R3 now.
test [split "abc^M^Jde^Mfghi^Jjk" [crlf | #"^M" | newline]]     ["abc" "de" "fghi" "jk"]
test [split "abc     de fghi  jk" [some #" "]]                  ["abc" "de" "fghi" "jk"]

;-------------------------------------------------------------------------------

test [split [1 2 3 4 5 6] :even?]	[[2 4 6] [1 3 5]]
test [split [1 2 3 4 5 6] :odd?]	[[1 3 5] [2 4 6]]
test [split [1 2.3 /a word "str" #iss x: :y] :refinement?]	[[/a] [1 2.3 word "str" #iss x: :y]]
test [split [1 2.3 /a word "str" #iss x: :y] :number?]		[[1 2.3] [/a word "str" #iss x: :y]]
test [split [1 2.3 /a word "str" #iss x: :y] :any-word?]	[[/a word #iss x: :y] [1 2.3 "str"]]

;-------------------------------------------------------------------------------

test [split/at [1 2.3 /a word "str" #iss x: :y] 4]	[[1 2.3 /a word] ["str" #iss x: :y]]
;!! Splitting /at with a non-integer excludes the delimiter from the result
test [split/at [1 2.3 /a word "str" #iss x: :y] "str"]	[[1 2.3 /a word] [#iss x: :y]]
test [split/at [1 2.3 /a word "str" #iss x: :y] 'word]	[[1 2.3 /a] ["str" #iss x: :y]]

;-------------------------------------------------------------------------------


sys-tail: :tail
split-at: function [
	"Split the series at a position or value, returning the two halves."
	series [series!]
	delim  "Delimiting value, or index if an integer"
	/value "Split at delim value, not index, if it's an integer"
	/tail  "Split at delim's tail; implies value"
	/last  "Split at the last occurrence of value, from the tail"
][
	copy-to: func [end] [copy/part series end]
	reduce either all [integer? delim  not any [value tail last]] [
		[copy-to delim  copy at series delim + 1]
	][
		if string? series [delim: form delim]
		; No way to apply or refine funcs in Red yet, so this is ugly.
		pos: either last [
			either tail [find/tail/last series delim] [find/last series delim]
		][
			either tail [find/tail series delim] [find series delim]
		]
		; Delimiter not found
		if none? pos [
			pos: either last [series] [sys-tail series]
		]
		[copy-to pos  copy pos]
	]
]


split-at-tests: [
	[split-at [1 2 3 4 5 6 3 7 8] 3]
	[split-at/tail [1 2 3 4 5 6 3 7 8] 3]
	[split-at/value [1 2 3 4 5 6 3 7 8] 3]
	[split-at/value/tail [1 2 3 4 5 6 3 7 8] 3]
	[split-at/last [1 2 3 4 5 6 3 7 8] 3]
	[split-at/last/tail [1 2 3 4 5 6 3 7 8] 3]

	[split-at [1 2 3 4 5 6 3 7 8] -1]
	[split-at [1 2 3 4 5 6 3 7 8] 0]
	[split-at [1 2 3 4 5 6 3 7 8] 10]

	[split-at/last [1 2 3 4 5 6 3 7 8] -1]
	[split-at/last [1 2 3 4 5 6 3 7 8] 0]
	[split-at/last [1 2 3 4 5 6 3 7 8] 10]

	[split-at "123456378" 3]
	[split-at/tail "123456378" 3]
	[split-at/last "123456378" 3]
	[split-at/last/tail "123456378" 3]

	[split-at "123456378" #"3"]
	[split-at/tail "123456378" #"3"]
	[split-at/last "123456378" #"3"]
	[split-at/last/tail "123456378" #"3"]

	[split-at "123456378" #"/"]
	[split-at/tail "123456378" #"/"]
	[split-at/last "123456378" #"/"]
	[split-at/last/tail "123456378" #"/"]
]

split-at: function [
	"Split the series at a position or value, returning the two halves."
	series [series!]
	value  "Delimiting value, or index if an integer"
	/only  "Treat value as single value if a series, and as a literal value, not index, if an integer"
	/tail  "Split at delim's tail, if splitting by value"
	/last  "Split at the last occurrence of value, from the tail"
][
	copy-to: func [end] [copy/part series end]
	reduce either all [integer? value  not any [only tail last]] [
		[copy-to value  copy at series value + 1]
	][
		pos: either tail [find/tail series value] [find series value]
		[copy-to pos  copy pos]
	]
]
;red>> split-at blk 4
;== [[1 2 3 4] [5 6]]
;red>> split-at/tail/value blk 4
;== [[1 2 3 4] [5 6]]
;red>> split-at/value blk 4
;== [[1 2 3] [4 5 6]]
; Just dump results for manual inspection right now.
split-at-tests: [
	[split-at [1 2 3 4 5 6 3 7 8] 3]
	[split-at/tail [1 2 3 4 5 6 3 7 8] 3]
	[split-at/only [1 2 3 4 5 6 3 7 8] 3]
	[split-at/only/tail [1 2 3 4 5 6 3 7 8] 3]
	[split-at/last [1 2 3 4 5 6 3 7 8] 3]
	[split-at/last/tail [1 2 3 4 5 6 3 7 8] 3]

	[split-at [1 2 3 4 5 6 3 7 8] -1]
	[split-at [1 2 3 4 5 6 3 7 8] 0]
	[split-at [1 2 3 4 5 6 3 7 8] 10]

	[split-at/last [1 2 3 4 5 6 3 7 8] -1]
	[split-at/last [1 2 3 4 5 6 3 7 8] 0]
	[split-at/last [1 2 3 4 5 6 3 7 8] 10]

	[split-at "123456378" 3]
	[split-at/tail "123456378" 3]
	[split-at/last "123456378" 3]
	[split-at/last/tail "123456378" 3]

	[split-at "123456378" #"3"]
	[split-at/tail "123456378" #"3"]
	[split-at/last "123456378" #"3"]
	[split-at/last/tail "123456378" #"3"]

	[split-at "123456378" #"/"]
	[split-at/tail "123456378" #"/"]
	[split-at/last "123456378" #"/"]
	[split-at/last/tail "123456378" #"/"]
]
print ""
foreach test split-at-tests [
	print [mold test "==" mold do test]
]

split-parts: function [
	"Split a series into variable size pieces"
	series [series!] "The series to split"
	sizes  [block!]  "Must contain only integers; negative values mean ignore that part"
][
	if not parse sizes [some integer!][ cause-error 'script 'invalid-arg [sizes] ]
	map-each len sizes [
		either positive? len [
			copy/part series series: skip series len
		][
			series: skip series negate len
			()										;-- return unset so that nothing is added to output
		]
	]
]
e.g. [
	blk: [a b c d e f g h i j k]
	split-parts blk [1 2 3]
	split-parts blk [1 -2 3]
	split-parts blk [1 -2 3 10]
]

filter: function [
	"Returns two blocks: items that pass the test, and those that don't"
	series [series!]
	test [any-function!] "Test (predicate) to perform on each value; must take one arg"
	/only "Return a single block of values that pass the test"
	; Getting only the things that don't pass a test means applying NOT
	; to the test and using /ONLY. Applying NOT means making a lambda.
	; Not hard, for people who understand anonymous funcs.
	;/pass "Return a single block of values that pass the test"
	;/fail "Return a single block of values that fail the test"
][
	;TBD: Is it worth optimizing to avoid collecting values we won't need to return?
	result: reduce [copy [] copy []]
	foreach value series [
		append/only pick result make logic! test :value :value
	]
	either only [result/1][result]
]

; break-at [first comma]
; break-at [last comma]
; break-at [comma 4]
; break-at [#5th comma]
; break-at [@2nd comma]

break-at: function [
	"Split the series at a position or value, returning the two halves, excludes delim."
	series [series!]
	delim  "Delimiting value, or index if an integer"
	;/value "Split at delim value, not index, if it's an integer"
	/last  "Split at the last occurrence of value, from the tail"
][
	;reduce either all [integer? delim  not any [value last]] [
	reduce either all [integer? delim  not last] [
		parse series [collect [keep delim skip  keep to end]]
	][
		if string? series [delim: form delim]
		either last [
			reduce [
				copy/part series find/only/last series :delim
				copy find/only/last/tail series :delim
			]
		][
;			either all [value  not any-string? series] [
;				parse series compose/deep [collect [keep to quote (delim)  quote (delim)  keep to end]]
;			][
				parse series [collect [keep to delim  delim  keep to end]]
;			]
		]
	]
]


break-at-tests: [
	[break-at [1 2 3 4 5 6 3 7 8] 3]
;	[break-at/value [1 2 3 4 5 6 3 7 8] 3]
;	[break-at/last [1 2 3 4 5 6 3 7 8] 3]

;	[break-at [1 2 3 4 5 6 3 7 8] -1]
;	[break-at [1 2 3 4 5 6 3 7 8] 0]
;	[break-at [1 2 3 4 5 6 3 7 8] 10]
;
;	[break-at/last [1 2 3 4 5 6 3 7 8] -1]
;	[break-at/last [1 2 3 4 5 6 3 7 8] 0]
;	[break-at/last [1 2 3 4 5 6 3 7 8] 10]
;
;	[break-at "123456378" 3]
;	[break-at/last "123456378" 3]
;
;	[break-at "123456378" #"3"]
;	[break-at/last "123456378" #"3"]
;
;	[break-at "123456378" #"/"]
;	[break-at/last "123456378" #"/"]
]
print ""
foreach test break-at-tests [
	print [mold test "==" mold do test]
]

;-------------------------------------------------------------------------------

; Red

split: func [
    {Break a string series into pieces using the provided delimiters} 
    series [any-string!]
    dlm [string! char! bitset!]
    /local s num
][
    num: either string? dlm [length? dlm] [1] 
    parse series [
    	collect any [
    		copy s [to [dlm | end]] keep (s)
    		num skip
    		[end keep (copy "") | none]
    	]
    ]
]

