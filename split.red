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

e.g.: :comment

comment {
	split break divide separate partition
	join delimit combine append union	; opposites of split
	segment section part piece portion slice chunk item
	
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
	split <integer!>			; into N parts, last may be longer
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

	split [
		at third dash		; break YYYY-MM-DD-HH-MM-SS into date and time
		then at every dash	; break date and time into fields
	]

	split comma
	split [comma]
	split [at comma]
	split [after comma]
	split [once at comma]
	split [twice at comma]
	split [3 times at comma]
	split [integer! times at comma] ; int > 0

	; Maybe EVERY is implied, and is overridden by ordinal specifiers.
	
	split [before last comma]	
	split [at last comma]	
	split [at third dash]			; break YYYY-MM-DD-HH-MM-SS into date and time
	split [after last comma]	
	
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
	
	'before = at+remove
	
	BREAK as name for func that eats delims versus keeping them?

	Can `before|after` mean "keep the delim" on one side or the other? Then "at"
	says "don't keep the delim"? How do you say keep the delim as a separate item,
	or is that such rare use case that it doesn't matter. For a single value,
	like a char or string, it is lossless to throw it away, but for a charset it's
	lossy. Before/After keep it as part of the value, but that requires another
	processing step for the user.
	
	Delims aren't keys, but grouping by key is another facet of splitting by
	function. It needs to keep the keys though, under which all matching items
	are grouped, making the resulting structure key-value based and a special
	case.
	
	More advanced than I want to think about this late evening, but what about
	a lazy approach? In thinking about SPLIT, you have to allocate all those 
	new pieces maybe just to operate on them. But in an HOF/callback model,
	you could stream them out for aggregation or other processing, just accessing
	them where they lie in the original series. Without copying, or Boris' PART
	func and true slices, there's no protection of the original, which is dangerous
	of course. But it's a declarative, or functional if you prefer, approach, where
	you pass in the splitting criteria and an action to apply to each result. We
	may be able to reserve parens for that, making it consistent with PARSE.
	
	Splitting at a datatype could be useful. e.g. log files where each starts with
	a date!, or config files where entries start with a set-word! (though *we*
	wouldn't do that ;^), using issue! as an ID for entries that may vary in length.
	But it raises a question, because you might want to get word values that
	refer to them, so you don't have to compose. But that conflicts with splitting
	at literal word values.

;-------------------------------------------------------------------------------

; "As verbs the difference between split and break is that split is (ergative) of
; something solid, to divide fully or partly along a more or less straight line
; while break is (intransitive) to separate into two or more pieces, to fracture
; or crack, by a process that cannot easily be reversed for reassembly." wikidiff


; 'at should implied, because it applies to both 'once and 'every.
;	- at every
;	- once at opt [first | last]
; In a dialected block, it may help readability to include it, but it's a noop.

; split-once-every-delimiter /before /after
; split-once-at-first-delimiter		delim
; split-once-at-last-delimiter		delim
; split-once-at-Nth-delimiter		delim

; split-every-N-items  			part-size	split-into-equal-parts-of-size-N
; split-into-N-parts			num-parts
; split-into-sized-parts		part-sizes

; split-once-at-index				index
; split-once-at-index-from-tail		index

; split-by-predicate				test		always every


; integer!:  [once | every | into | Nth]  [lit opt keep]
; function!: [every]
; string!:	 [once | every] [before | after | keep]  No INTO because that implies a known number
; char!:	 [once | every] [before | after | keep]
; bitset!:	 [once | every] [before | after | keep]
; block!: [
;	all ints  [into]
;	all funcs [every]		partition
;   delim     [every]
;
; no-fill ?

}

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
	;print 'XXXXX
	;TBD: Is it worth optimizing to avoid collecting values we won't need to return?
	result: reduce [copy [] copy []]
	foreach value series [
		;print [tab :value  test :value]
		append/only pick result make logic! test :value :value
	]
	either only [result/1][result]
]

map-each: function [
	"Evaluates body for each value(s) in a series, returning all results."
	'word [word! block!] "Word, or words, to set on each iteration"
	data [series! map!] 
	body [block!]
] [
	collect [
		foreach :word data [
			if not unset? set/any 'tmp do body [keep/only :tmp]
		]
	]
]

; Minimal map-ex: no /skip, always /only
map-ex: func [
	"Evaluates a function for all values in a series and returns the results."
	series [series!]
	fn [any-function!] "Function to perform on each value; called with value, index, series args"
][
	collect [
		repeat i length? series [
			keep/only fn series/:i :i :series
		]
	]
]
;res: map-ex [1 2 3 a b c #d #e #f] :form
;res: map-ex [1 2 3 a b c #d #e #f] func [v i] [reduce [i v]]
;res: map-ex [1 2 3 a b c #d #e #f] func [v i s] [reduce [i v s]]

partition: function [   ; GROUP ?
	"Group values by matching tests (predicates); last group didn't match any"
	series [series!] "Each value is passed to each test, in turn, until one matches"
	tests  [block!]  "Block of single-arity functions; unset results not supported"
][
	; So the caller can just use get-words in a block. Otherwise 99.9%
	; of callers will have to use `reduce` themselves.
	tests: attempt [reduce tests]
	; No arity or type checking for given predicate funcs.
	if not parse tests [some any-function!] [
		cause-error 'Script 'invalid-arg [tests]
	]
	; Result will be a block of blocks.
	result: copy []
	; Allocate space for each predicate in results. No ARRAY in Red (yet).
	loop add length? tests 1 [
		append/only result copy []
	]
	; Loop over the series, trying each value against each predicate.
	; As soon as a value matches one, move to the next value. That is
	; values can't appear in more than one predicate result. You get
	; each value back exactly once, just redistributed.
	foreach value series [
		match?: false
		; Repeat lets us easily access the associated result sub-block.
		repeat i length? tests [
			match?: attempt [tests/:i :value]
			; If we do this, unset results are considered a match
			;match?: to logic! attempt [tests/:i :value]
			; Add this element to the block for the current predicate
			; and break so it's not added to others.
			if match? [append/only result/:i :value  break]
		]
		; If none matched, put it in the default block where no predicate matched.
		if not match? [append/only last result :value]
	]
	result
]
;data: [0.5 1 2 3.4 5.6 7 8.9 0 100]
;partition data [:integer? :float?]
;partition/with data [:lesser? :greater?] [3 7]
;partition/with data [:lesser? :greater?] 3

;-------------------------------------------------------------------------------

split-into-N-parts: function [
	"If the series can't be evenly split, the last value will be longer"
	series [series!]
	parts [integer!]
	/local p
][
	if parts < 1 [cause-error 'Script 'invalid-arg parts]
	if parts = 1 [return series]
	count: parts - 1
	part-size: to integer! round/down divide length? series parts
	if zero? part-size [part-size: 1]
	res: collect [
		parse series [
			count [copy p part-size skip (keep/only p)]
			copy p to end (keep/only p)
		]
	]
	;-- If the result is too short, i.e., less items than 'size, add
	;   empty items to fill it to 'size.
	;   We loop here, because insert/dup doesn't copy the value inserted.
	if parts > length? res [
		;loop (parts - length? res) [append/only res fill-val series]
		loop (parts - length? res) [append/only res make series 0]
	]
	
	res
]

split-var-parts: function [
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


split-once: function [
	"Split the series at a position or value, returning the two halves."
	series [series!]
	delim  "Delimiting value, or index (think SKIP not AT) if an integer"
	/value "Split at delim value, not index, if it's an integer"
	/before "Include delimiter in the second half; implies /value"
	;/at     "(default) Do not include delimiter in results if /value"
	/after  "Include delimiter in the first half; implies /value"
	;/first "(default) Split at the first occurrence of value"
	/last  "Split at the last occurrence of value"
][
	reduce either all [integer? delim  not any [value before after]] [
		print 'A-POS
		pos: either last [
			skip tail series negate delim
		][
			delim
		]
		; Result to reduce
		print [tab pos mold series]
		[
			copy/part series pos
			copy at series pos + 1
		]
	][
		; A big question is whether to use find/only or make it a refinement. 
		print 'B-VAL
		if string? series [delim: form delim]
		drop-len either any [before after][length? delim][0]
		; No way to apply or refine funcs in Red yet, so this is a bit ugly/redundant.
		; Eventually we'll want to use a APPLY/REFINE applicator of some kind.
		pos: case [
			all [before last]	[find/last series delim]
			all [after  last]	[find/tail/last series delim]
			before 				[find series delim]
			after  				[find/tail series delim]
			last   				[find/last series delim]
			'else  				[find series delim]
		]
;		pos: either last [
;			either after [find/tail/last series delim] [find/last series delim]
;		][
;			either after [find/tail series delim] [find series delim]
;		]
		; Delimiter not found
		if none? pos [
			pos: either last [series] [tail series]
		]
		; Result to reduce
		[copy/part series pos  copy pos]
	]
]

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
		[split-once/last/after [1 2 3 4 5 6 3 7 8] 3]	[ [1 2 3 4 5 6 7 3] [7 8] ]

		[split-once [1 2 3 4 5 6 3 7 8] -1]				[ [] [1 2 3 4 5 6 3 7 8] ]
		[split-once [1 2 3 4 5 6 3 7 8] 0]				[ [] [1 2 3 4 5 6 3 7 8] ]
		[split-once [1 2 3 4 5 6 3 7 8] 10]				[ [1 2 3 4 5 6 3 7 8] [] ]

		[split-once/last [1 2 3 4 5 6 3 7 8] -1]		[ [1 2 3 4 5 6 3 7] [8] ]
		[split-once/last [1 2 3 4 5 6 3 7 8] 0]			[ [1 2 3 4 5 6 3 7 8] [] ]
		[split-once/last [1 2 3 4 5 6 3 7 8] 10]		[ [] [1 2 3 4 5 6 3 7 8] ]

		[split-once "123456378" 3]						[ [] [] ]
		[split-once/after "123456378" 3]				[ [] [] ]
		[split-once/last "123456378" 3]					[ [] [] ]
		[split-once/last/after "123456378" 3]			[ [] [] ]

		[split-once "123456378" #"3"]					[ [] [] ]
		[split-once/after "123456378" #"3"]				[ [] [] ]
		[split-once/last "123456378" #"3"]				[ [] [] ]
		[split-once/last/after "123456378" #"3"]		[ [] [] ]

		[split-once "123456378" #"/"]					[[] [] ]
		[split-once/after "123456378" #"/"]				[[] [] ]
		[split-once/last "123456378" #"/"]				[[] [] ]
		[split-once/last/after "123456378" #"/"]		[[] [] ]
	]
	
;	foreach [blk res] split-once-tests [test blk res]
;	halt
]

;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------

;?? Do we need a case sensitive option?

split-ctx: context [

	all-are?: func [    ; every? all-are? ;; each? is-each? each-is? are-all? all-of?
		"Returns true if all items in the series match a test"
		series	[series!]
		test	"Test to perform against each value; must take one arg if a function"
	][
		either any-function? :test [
			foreach value series [if not test :value [return false]]
			true
		][
			if word? test [test: to lit-word! form test]
			either integer? test [
				parse series compose [some quote (test)]
			][
				parse series [some test]
			]
		]
	]

	delim-types: exclude default! make typeset! [integer! block! any-function! event!]

	;-------------------------------------------------------------------------------

	; This might actually be cleaner as a simple loop, but with parse we might
	; also be able to compose the ops in so [/before/at/after] map to
	; [to | thru] + [dlm | none] and /count maps to [N | []] when composed.

	split-delimited: function [
		series [series!]
		delim
		/before "Include delimiter in the value following it"
		/at     "(default) Do not include delimiter in results"
		/after  "Include delimiter in the value preceding it"
		/count ct [integer!]
		/local v
	][
		;dbg "delimiter; split at every instance"
		if not find delim-types type? :delim [cause-error 'script 'invalid-arg [delim]]
		
		;dlm-len: either series? dlm [length? dlm] [1]   ; any-string? instead of series?
		;if all [any-string series  tag? dlm] [dlm-len: add 2 dlm-len]			; tag length doesn't include brackets
		rule: [
			collect any [
				keep copy v [to [delim | end]] ;keep (v)
				delim ;dlm-len skip  ; is there enough speed gain to make 'skip worth it?
				[end keep (make series 0) | none]
			]
		]
		
		parse series rule
	]

	split-delimited: function [
		series [series!]
		delim
		/before "Include delimiter in the value following it"
		/at     "(default) Do not include delimiter in results"
		/after  "Include delimiter in the value preceding it"
		; TBD: is count worth supporting?
		;/count ct [integer!] "Maximum number of splits; remainder of series is the last"
		/local v
	][
		; Do we allow blocks as delims? If not, we have to do something
		; else for standard parse rules that pass thru to this.
		dbg ["Split-delimited" mold series mold delim]
		;if not find delim-types type? :delim [cause-error 'script 'invalid-arg [delim]]
		if all [
			not find delim-types type? :delim 
			not block? :delim
		][cause-error 'script 'invalid-arg [delim]]
		
		rule-core: case [
			before [[
				keep copy v [opt [ahead delim skip] to [delim | end]]
			]]
			after  [[
				keep copy v [thru [delim | end]]
			]]
			'else  [[
				keep copy v [to [delim | end]]
				delim
				[end keep (make series 0) | none]
			]]
		]
		parse series compose/only [collect any (rule-core)]

	]

	; refinements aren't set in a funcs context this way it seems.
;	set-from-opts: func [opts [block!]][
;		foreach val opts [if word? :val [set val true]]
;	]
	has?: func [series value][to logic! find/only series value]
	
	split-delimited: function [
		series [series!]
		delim
		/before "Include delimiter in the value following it"
		/at     "(default) Do not include delimiter in results"
		/after  "Include delimiter in the value preceding it"
		; TBD: is count worth supporting?
		/count ct [integer!] "Maximum number of splits; remainder of series is the last"
		/with opts [block!]  "Block of options to use in place of refinements (unknown words will leak)"
		/local v
	][
		; Do we allow blocks as delims? If not, we have to do something
		; else for standard parse rules that pass thru to this.
		dbg ["Split-delimited" mold series mold delim]
		;if not find delim-types type? :delim [cause-error 'script 'invalid-arg [delim]]
		if all [
			not find delim-types type? :delim 
			not block? :delim
		][cause-error 'script 'invalid-arg [delim]]
		
		; Set refinement/var vals if a matching named option exists
		;if opts [set-from-opts opts]
		;if opts [foreach val opts [if word? :val [set val true]]]
		before: has? opts 'before
		at:     has? opts 'at
		after:  has? opts 'after
		if count:  has? opts 'count [ct: opts/count]
		; Set refinement args from options
		;if count [ct: opts/count]
		
		print [@before: before @at: at @after: after @count: ct @with: mold opts]
		
		rule-core: case [
			before [[
				keep copy v [opt [ahead delim skip] to [delim | end]]
			]]
			after  [[
				keep copy v [thru [delim | end]]
			]]
			'else  [[
				keep copy v [to [delim | end]]
				delim
				[end keep (make series 0) | none]
			]]
		]
		either count [
			; Copy up to (count) parts
			parts: parse series compose/only [collect (ct) (rule-core) mark:]
			; Then tack on the remaining data as the last part
			append/only parts copy mark
		][
			parse series compose/only [collect any (rule-core)]
		]

	]

	;-------------------------------------------------------------------------------


	trace: on
	dbg: either trace [:print][:none]

;-------------------------------------------------------------------------------

	block-of-ints?: func [value][
		all [block? :value  attempt [all-are? reduce value integer!]]
	]
	block-of-funcs?: func [value][
		all [block? :value  attempt [all-are? reduce value :any-function?]]
	]

	set 'split function [
		"Split a series into pieces; fixed or variable size, fixed number, or at delimiters"
		series [series!] "The series to split"
		;!! need a more general name for this param now, spec or rule maybe.
		dlm    ;[block! integer! char! bitset! any-string! any-function!] "Split size, delimiter(s), predicate, or rule(s)." 
		/local s v
	][
		;-------------------------------------------------------------------------------
		;-- Parse rules
		;
		; Dialected rule handlers MUST set 'res
		=num: =once: =mod: =ord: =pos: =dlm: =ct: none
		split-rule: [
			(=num: =once: =mod: =ord: =pos: =dlm: =ct: none)
			
			; Single delim, just in a block rather than as a direct arg
			; Into N parts
			'into set =num integer! opt [['parts | 'pieces | 'chunks]] (
				dbg ['>> 'split-into-N-parts]
				res: split-into-N-parts series =num
			)

			| (print 'xxxxx) [
				[
					'once (=once: yes) opt delim-modifier=
					| opt delim-modifier= opt 'every
				]
				opt ordinal=	; implies 'once
				[
					delimiter=
					| position=
				]
				opt count=
				(
					print ['=num =num '=once =once '=mod =mod '=ord =ord '=pos =pos '=dlm mold =dlm '=ct =ct]
					res: 'TBD
					;-----
					opts: reduce [=mod =ord]
					if =once [repend opts ['count 1]]
					if =ct  [repend opts ['count =ct]]
					res: split-delimited/with series =dlm opts
					;-----
;					case [
;						=once [
;							case [
;								=mod = 'at     [res: split-delimited        series =dlm]
;								=mod = 'before [res: split-delimited/before series =dlm]
;								=mod = 'after  [res: split-delimited/after  series =dlm]
;							]
;						]
;						=mod = 'at     [res: split-delimited        series =dlm]
;						=mod = 'before [res: split-delimited/before series =dlm]
;						=mod = 'after  [res: split-delimited/after  series =dlm]
;					]
				)
			]

			| [delimiter= (
				dbg "delimiter (in block); split at every instance"
				res: split-delimited series =dlm
				)
			]


		]
		delimiter=: [
			;'as-delim any-type! ("Treat as literal value, not position or rule")
			'as-delim set =dlm [integer! | block!] ;("Treat as literal value, not position or rule")
			| not [
				integer!
				| block! 
				| any-function!
				| unset!
			  ]
			  set =dlm any-type!
		]
		position=: [set =pos integer!] ; TBD enforce `positive?`
		delim-modifier=: [
			set =mod ['at | 'before | 'after] ; ("before+first/after+last make no sense") 
		]
		ordinal=: [set =ord ['first | 'last]] ; | Nth] ("Implies once")], 'times = count
		count=: [set =ct integer! 'times]
		
		;-------------------------------------------------------------------------------

		size: :dlm									;-- alias for readability in size-based rules
		
		;!!----------------------------------------
		;!! Case handlers MUST set 'res or 'rule !!
		;!!----------------------------------------
		case [
			; The most common case is simple splitting at every delimiter.
			; To allow all delimiter types except what we explicitly forbid,
			; we have to check those. 
			find delim-types type? :dlm [
				dbg "delimiter; split at every instance"
				res: split-delimited series dlm
			]
			integer? :dlm [
				dbg "integer; split into chunks of its size"
				if size < 1 [cause-error 'Script 'invalid-arg size]
				rule: [collect [any [keep copy series 1 size skip]]]
			]
			; alt way to check
			;all [not integer? :dlm  not block? :dlm  not any-function? :dlm][
			;]
			any-function? :dlm [
				dbg "function; filter into pass/fail"
				res: filter series :dlm
			]
			; Do we want to make it easier on the user, for common cases,
			; by reducing here?
			;
			block-of-ints? :dlm [
				dbg "block of ints"
				res: split-var-parts series :dlm
			]
			; Do we want to make it easier on the user, for common cases,
			; by reducing here?
			block-of-funcs? :dlm [
				dbg "block of funcs"
				res: partition series :dlm
			]
			
			block? :dlm [
				dbg "going into block dlm"
				; Now we have to decide if we let them use any old parse rule, 
				; in addition to valid dialected spec blocks.
;				case [
;					parse dlm into-N-parts= []
;					; Not a dialected split spec. Use as a parse rule directly.
;					'else []
;				]
				; dialected rule handlers MUST set 'res
				; What if we COMPOSE dlm here, so the user just has to use parens
				; for things like charsets? Otherwise the calls get a bit uglier
				; on the user side. 
				either all [parse dlm split-rule  res][
					dbg "dialected block DONE"
					; A dialected rule was handled and the result was set.
					; Nothing else to do here.
				][
					dbg "Using block as parse rule"
					; Not a dialected split spec. Use as a parse rule directly.
					res: split-delimited series dlm
				]
			]
			'else [
				dbg "Else"
				cause-error 'Script 'invalid-arg :dlm
			]
		]
		
		; If res has been set, it was e.g., a simple delimiter, filter, or
		; parition, and processing is already done. Otherwise, a parse rule
		; should have been set for us to process here.
		if not res [
			either rule [
				;dbg ["Rule:" mold rule]
				res: parse series rule
			][
				; Rule wasn't set, so their split spec was invalid
				;cause-error 'Script 'invalid-arg dlm
				print "Rule wasn't set, so their split spec was invalid"
				print [tab mold :dlm tab mold res]
				;halt
			]
		]
		
		;print [tab '>>>>>> mold res]
		return res
		
	]

;-------------------------------------------------------------------------------

	test: func [block expected-result /local res err] [
		if error? set/any 'err try [
			print [mold/only :block newline tab mold res: do block]
			if res <> expected-result [print [tab 'FAILED! tab 'expected mold expected-result]]
		][
			print [mold/only :block newline tab "ERROR!" mold err]
		]
	]

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

	test [split "a.b.c" "."]     ["a" "b" "c"]
	test [split "c c" " "]       ["c" "c"]
	test [split "1,2,3" " "]     ["1,2,3"]
	test [split "1,2,3" ","]     ["1" "2" "3"]
	test [split "1,2,3," ","]    ["1" "2" "3" ""]
	test [split "1,2,3," charset ",."]    ["1" "2" "3" ""]
	test [split "1.2,3." charset ",."]    ["1" "2" "3" ""]

	;!! Seen as dialected delimiter in block if we don't require `once|every`
	test [split "-a-a" ["a"]]    ["-" "-" ""]
	test [split "-a-a'" ["a"]]    ["-" "-" "'"]

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

	;-------------------------------------------------------------------------------

	test [split [1 2.3 /a word "str" #iss x: :y <T>] [:number? :any-string?]]	[[1 2.3] ["str" <T>] [/a word #iss x: :y]]
	
	;-------------------------------------------------------------------------------

	; datatypes and typesets split at every delimiter, because you can achieve
	; the filter/partition behavior with funcs. But is this behavior useful?
	; Not as much because it throws away the delimiting value. In order to be
	; more useful, you need to use before/after.
	; TBD update expected results.
	test [split [1 2.3 /a word "str" #iss x: :y] refinement!]	[[1 2.3] [word "str" #iss x: :y]]
	test [split [1 2.3 /a word "str" #iss x: :y] number!]		[[] [] [/a word "str" #iss x: :y]]
	test [split [1 2.3 /a word "str" #iss x: :y] any-word!]	[[1 2.3 /a] ["str" #iss] [] []]

;	test [split [1 2.3 /a word "str" #iss x: :y] :refinement!]	[[/a] [1 2.3 word "str" #iss x: :y]]
;	test [split [1 2.3 /a word "str" #iss x: :y] :number!]		[[1 2.3] [/a word "str" #iss x: :y]]
;	test [split [1 2.3 /a word "str" #iss x: :y] :any-word!]	[[/a word #iss x: :y] [1 2.3 "str"]]

	;-------------------------------------------------------------------------------
	test [split [1 2 3 4 5 6]      [into 2 parts]]    [[1 2 3] [4 5 6]]
	test [split "1234567812345678" [into 2 parts]]  ["12345678" "12345678"]
	test [split "1234567812345678" [into 3 parts]]  ["12345" "67812" "345678"]
	test [split "1234567812345678" [into 5 parts]]  ["123" "456" "781" "234" "5678"]

	; Dlm longer than series
	test [split "123"   [into 6 parts]]			["1" "2" "3" "" "" ""] ;or ["1" "2" "3"]
	test [split [1 2 3] [into 6 parts]]			[[1] [2] [3] [] [] []] ;or [[1] [2] [3]]
	test [split quote (1 2 3) [into 6 parts]]	[(1) (2) (3) () () ()] ;or [(1) (2) (3)]
	;test [split [1 2 3] [into 6 parts]]     [[1] [2] [3] none none none] ;or [1 2 3]


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

	test [split "1,2,3" [at #","]]     	["1" "2" "3"]
	test [split "1,2,3" [before #","]]  ["1" ",2" ",3"]
	test [split "1,2,3" [after #","]]   ["1," "2," "3"]

	test [split ",1,2,3," [at #","]]      ["" "1" "2" "3" ""]
	;!! These are a bit tricky to reason about. The delimiter goes with
	;	the next or previous value, so what constitutes an empty field
	;	at the end, as with simple splitting? These results make the
	;	most sense to me, but I'm only 90% confident in that choice.
	test [split ",1,2,3," [before #","]]  [",1" ",2" ",3" ","]	; delim goes with next value
	test [split ",1,2,3," [after #","]]   ["," "1," "2," "3,"]  ; delim goes with prev value

	test [split "1 2 3" [at #","]]     	["1 2 3"]
	test [split "1 2 3" [before #","]]  ["1 2 3"]
	test [split "1 2 3" [after #","]]   ["1 2 3"]

	test [split "aaa" [before #"a"]]  ["a" "a" "a"]

	test [split "PascalCaseName" charset [#"A" - #"Z"]] ["" "ascal" "ase" "ame"]
	test [split "PascalCaseName" reduce ['before charset [#"A" - #"Z"]]] ["Pascal" "Case" "Name"]

	test [split "PascalCaseNameAndMoreToo" reduce [charset [#"A" - #"Z"] 3 'times]] ["" "ascal" "ase" "ameAndMoreToo"]
	test [split "PascalCaseNameAndMoreToo" reduce ['before charset [#"A" - #"Z"] 3 'times]] ["Pascal" "Case" "Name" "AndMoreToo"]
	test [split "PascalCaseNameAndMoreToo" reduce ['after charset [#"A" - #"Z"] 3 'times]] ["P" "ascalC" "aseN" "ameAndMoreToo"]
	test [split "Pascal^/Case^/Name^/And^/More^/Too^/" reduce ['after newline 3 'times]] ["Pascal^/" "Case^/" "Name^/" {And^/More^/Too^/}]
	test [split "^/Pascal^/Case^/Name^/And^/More^/Too^/" reduce ['after newline 3 'times]] ["^/" "Pascal^/" "Case^/" "Name^/" {And^/More^/Too^/}]

	test [split "camelCaseNameAndMoreToo" reduce ['once charset [#"A" - #"Z"]]] ["camel" "aseNameAndMoreToo"]
	test [split "camelCaseNameAndMoreToo" reduce ['once 'before charset [#"A" - #"Z"]]] ["camel" "CaseNameAndMoreToo"]
	test [split "camelCaseNameAndMoreToo" reduce ['once 'after charset [#"A" - #"Z"]]] ["camelC" "aseNameAndMoreToo"]
	
;	test [split/at [1 2.3 /a word "str" #iss x: :y]  4    []]	[[1 2.3 /a word] ["str" #iss x: :y]]
;	;!! Splitting /at with a non-integer excludes the delimiter from the result
;	test [split/at [1 2.3 /a word "str" #iss x: :y] "str" []]	[[1 2.3 /a word] [#iss x: :y]]
;	test [split/at [1 2.3 /a word "str" #iss x: :y] 'word []]	[[1 2.3 /a] ["str" #iss x: :y]]
]

;-------------------------------------------------------------------------------

