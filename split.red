Red [
	Title:   "Red SPLIT functions"
	Author:  "Gregg Irwin"
	File: 	 %split.red
	Tabs:	 4
	Rights:  "Copyright 2021 All Mankind. No rights reserved."
	License: 'MIT
]

;?? Should we use `sep` for separator, rather than `dlm/delim` for delimiter?
;	It has a few advantages: 1) It's position vs value agnostic, 2) There is
;	really only one viable abbreviation, 3) It has a vowel in the middle.

comment [
	s: "a,b,c,d"
	profile/show/count [
		[split s comma]
		[split-once s comma]
		[split-once/last s comma]
		[split-at-index s 4]
		[split-once/after/last s comma]
		[split s [once after last #","]]
	] 10000
]

e.g.: :comment

;-------------------------------------------------------------------------------

trace: off
show-all?: no
dbg: either all [trace][:print][:none]

;-------------------------------------------------------------------------------

; Using PARTITION in place of this now. One less func here. And a good test.
;filter: function [
;	"Returns two blocks: items that pass the test, and those that don't"
;	series [series!]
;	test [any-function!] "Test (predicate) to perform on each value; must take one arg"
;	/only "Return a single block of values that pass the test"
;	; Getting only the things that don't pass a test means applying NOT
;	; to the test and using /ONLY. Applying NOT means making a lambda.
;	; Not hard, for people who understand anonymous funcs.
;	;/pass "Return a single block of values that pass the test"
;	;/fail "Return a single block of values that fail the test"
;][
;	either only [
;		; Preallocate as may slots as the original series uses
;		collect/into [foreach value series [if test :value [keep/only :value]]] make series length? series
;		; Non-preallocating
;		;collect [foreach value series [if test :value [keep/only :value]]]
;	][
;		result: reduce [copy [] copy []]	;?? Should we preallocate `length? series` space here?
;		foreach value series [
;			append/only pick result make logic! test :value :value
;		]
;		result
;	]
;]

map-each: func [
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
;map-ex: func [
;	"Evaluates a function for all values in a series and returns the results."
;	series [series!]
;	fn [any-function!] "Function to perform on each value; called with value, index, series args"
;][
;	collect [
;		repeat i length? series [
;			keep/only fn series/:i :i :series
;		]
;	]
;]
;res: map-ex [1 2 3 a b c #d #e #f] :form
;res: map-ex [1 2 3 a b c #d #e #f] func [v i] [reduce [i v]]
;res: map-ex [1 2 3 a b c #d #e #f] func [v i s] [reduce [i v s]]

blockify: func [value][compose [(:value)]]

partition: function [   ; GROUP ?
	"Group values by matching tests (predicates); last group didn't match any"
	series [series!] "Each value is passed to each test, in turn, until one matches"
	tests  [any-function! block!]  "Block of single-arity functions; unset results not supported"
	/only "Don't return values that fail all tests"
][
	; So the caller can just use get-words in a block. Otherwise 99.9%
	; of callers will have to use `reduce` themselves.
	tests: either block? :tests [attempt [reduce tests]][blockify :tests]
	;tests: attempt [reduce compose [(tests)]]	; blockify single func args
	; No arity or type checking for given predicate funcs yet.
	if not parse tests [some any-function!] [
		cause-error 'Script 'invalid-arg [tests]
	]
	; Result will be a block of blocks.
	result: copy []
	; Allocate space for each test in results. No ARRAY in Red (yet).
	do [ ; Wrapped in DO, because nested funcs make the compiler unhappy
		add-group: does [append/only result copy []]			
		loop length? tests [add-group]	; passing results go here
		if not only [add-group]			; failing results go here
	]
;	loop length? tests [append/only result copy []]	; passing results go here
;	if not only [append/only result copy []]		; failing results go here
;	loop add length? tests 1 [
;		append/only result copy []
;	]
	; Loop over the series, trying each value against each predicate.
	; As soon as a value matches one, move to the next value. That is,
	; values can't appear in more than one predicate result. You get
	; each value back exactly once, just redistributed.
	foreach value series [
		match?: false
		; Repeat lets us easily access the associated result sub-block.
		repeat i length? tests [
			; Unset results are truthy, but we need to use set/any to suport them.
			match?: attempt [tests/:i :value]
			;match?: to logic! attempt [tests/:i :value]
			; Add this element to the block for the current predicate
			; and break so it's not added to others.
			if match? [append/only result/:i :value  break]
		]
		; If none matched, put it in the default block where no predicate
		; matched, unless they say they didn't want those values (with /only).
		if not only [
			if not match? [append/only last result :value]
		]
	]
;	if only [remove back tail result]	; drop last (empty) part
	result
]
;data: [0.5 1 2 3.4 5.6 7 8.9 0 100]
;partition data [:integer? :float?]
;partition/with data [:lesser? :greater?] [3 7]
;partition/with data [:lesser? :greater?] 3

;-------------------------------------------------------------------------------

; refinements aren't set in a funcs context this way it seems.
;	set-from-opts: func [opts [block!]][
;		foreach val opts [if word? :val [set val true]]
;	]
has?: func [series value][to logic! find/only series value]
	
;-------------------------------------------------------------------------------

split-into-N-parts: function [
	"If the series can't be split evenly, the last value will be longer"
	series [series!]
	parts [integer!]
	/local p
][
	if parts < 1 [cause-error 'Script 'invalid-arg parts]
	if parts = 1 [return copy series]
	count: parts - 1
	part-size: to integer! round/down divide length? series parts  ; don't need round/down, except as a doc.
	if zero? part-size [part-size: 1]
	;!! split-fixed-parts may return an extra part due to rounding.
	;	so we can't just drop it in here.
	;res: split-fixed-parts series part-size
	res: collect/into [
		parse series [
			count [copy p part-size skip (keep/only p)]
			copy p to end (keep/only p)
		]
	] make block! parts
	;-- If the result is too short, i.e., less items than 'size, add
	;   empty items to fill it to 'size.
	;   We loop here, because insert/dup doesn't copy the value inserted.
	;!! This could be done based on a refinement, the idea being that
	;	it could create a LOT of extra parts, even due to a typo or an
	;	injection attack of some kind. The real question, though, is
	;	what is most useful.
	if parts > length? res [
		; Make a filler value of the same type as the series
		loop (parts - length? res) [append/only res make series 0]
	]
	
	res
]
;@Toomasv
;split-into-N-parts: function [
;	"If the series can't be evenly split, the last value will be longer"
;	series [series!]
;	parts [integer!]
;	;/into out [block!]
;][
;	if parts < 1 [cause-error 'Script 'invalid-arg parts]
;	;if parts = 1 [return copy series]
;	;out: any [out make block! div]
;	out: make block! parts
;	until [
;		size: max 1 to integer! (length? series) / parts
;		part: copy/part series size
;		series: skip series size
;		append/only out any [part copy []]
;		zero? parts: parts - 1
;	]
;	head out	; need this or we get UNTIL's result
;]


; @Toomasv, based on @hiiamboris' distribution logic
part-sizes: function [
	total [integer!] "Total length of, e.g., series to split."
	parts [integer!] "Number of parts to split total into, using a balanced distribution"
][
    m: total / parts
    s: 0 
    sizes: collect [
        repeat i parts [
            idx: round/to i * m 1 
            keep idx - s 
            s: idx
		]
	]
]
split-into-N-parts: function [
	"Split series into parts using a balanced distribution."
	series [series!]
	parts  [integer!]
][
	if parts < 1 [cause-error 'Script 'invalid-arg parts]
	if parts = 1 [return copy series]

	sizes: part-sizes length? series parts
	res: make block! length? sizes
	collect/into [
		foreach size sizes [
			keep/only copy/part series size
			series: skip series size
		]
	] res
]


split-fixed-parts: function [
	"If the series can't be evenly split, the last value will be shorter"
	series [series!]  "The series to split"
	size   [integer!] "Size of each part"
][
	if size < 1 [cause-error 'Script 'invalid-arg size]
	parse series [collect [any [keep copy series 1 size skip]]]
]
; preallocate
;split-fixed-parts: function [
;	"If the series can't be evenly split, the last value will be shorter"
;	series [series!]  "The series to split"
;	size   [integer!] "Size of each part"
;][
;	if size < 1 [cause-error 'Script 'invalid-arg size]
;	res: make block! round/ceiling (length? series) / size
;	parse series [collect into res [any [keep copy series 1 size skip]]]
;	res
;]
;@Toomasv
;split-fixed-parts: function [
;	"If the series can't be evenly split, the last value will be shorter"
;	series [series!]  "The series to split"
;	size   [integer!] "Size of each part"
;][
;	if size < 1 [cause-error 'Script 'invalid-arg size]
;	;div: round/ceiling/to 1.0 * (length? series) / size 1
;	div: round/ceiling (length? series) / size
;	out: make block! div
;	loop div [append/only out copy/part series series: skip series size]
;	out
;;	collect/into [
;;		loop div [keep/only copy/part series series: skip series size]
;;	] make block! div
;]

; TBD should the sizes block support a 'skip keyword instead of using
; negative integer values? That means giving up map-each, but is more
; self-documenting and only a little more verbose. The key being that
; it's a little more code for us, and a little more for the user, in
; return for clarity. Clarity is almost always worth it.
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
split-var-parts: function [
	"Split a series into variable size pieces, running over the entire series"
	series [series!] "The series to split"
	sizes  [block!]  "Must contain only integers; negative values mean ignore that part"
][
	if not parse sizes [some integer!][ cause-error 'script 'invalid-arg [sizes] ]
	collect [
		while [not tail? series][
			keep map-each len sizes [
				either positive? len [
					copy/part series series: skip series len
				][
					series: skip series negate len
					()										;-- return unset so that nothing is added to output
				]
			]
		]
	]
]

;@Toomasv
;split-var-parts: function [
;	"Split a series into variable size pieces"
;	series [series!] "The series to split"
;	sizes  [block!]  "Must contain only integers; negative values mean ignore that part"
;	/only
;][
;	if not parse sizes [some integer!][ cause-error 'script 'invalid-arg [sizes] ]
;
;	set [len sumdlm lendlm] reduce [length? series  sum sizes  length? sizes]
;	div: case [
;		all [only len >= sumdlm][lendlm]
;		all [only len <  sumdlm][
;			s: 0
;			forall sizes [
;				if len <= s: s + sizes/1 [
;					break/return also index? sizes sizes: head sizes
;				]
;			]
;		]
;		all [not only len <= sumdlm][lendlm]
;		all [not only len >  sumdlm][1 + lendlm]
;	]
;	out: make block! div
;	loop div [
;		sz: any [first sizes length? series]
;		append/only out copy/part series series: skip series sz
;		sizes: next sizes
;	] 
;	out
;]
;e.g. [
;	blk: [a b c d e f g h i j k]
;	split-var-parts blk [1 2 3]
;	split-var-parts blk [1 -2 3]
;	split-var-parts blk [1 -2 3 10]
;]

; The naming and behavior on this are tricky. In Red, index 1 is *before* the
; first value. But `pick series 1` *is* the first value ("Returns the series 
; value at a given index"). For a human, specifying the *size* of the first
; part makes sense, with 0 meaning an empty part. Including "relative" or
; split-at-skip for naming isn't great either, because /skip's meaning in
; other funcs is then conflated over splitting into many parts.
; > Indexes start at 1, offsets start at 0
split-at-index: function [
	"Split the series at the given index (think SKIP not AT); returns the two parts."
	series [series!]
	index  [integer!]
	/last  "Split at index back from tail"
][
	if last [index: subtract length? series index]
	reduce [copy/part series index   copy at series index + 1]
]

split-once: function [
	"Split the series at a position or value, returning the two halves."
	series [series!]
	delim  "Delimiting value, or index (think SKIP not AT) if an integer"
	;?? Is there merit to this, or is it better to have the user explicitly
	;?? cast integer values?
	/value "Split at delim value, not index, if it's an integer"
	/before "Include delimiter in the second half; implies /value"
	;/at     "(default) Do not include delimiter in results if /value"
	/after  "Include delimiter in the first half; implies /value"
	;/first "(default) Split at the first occurrence of value"
	/last  "Split at the last position occurrence of value"
	;/Nth n "Nth occurrence of a value delimiter" ;!!! I don't think we need this !!!
	/with opts [block! none!]  "Block of options to use in place of refinements"
	;/local p-1 p-2
][
	; Set refinement/var vals if a matching named option exists
	;if opts [set-from-opts opts]
	;if opts [foreach val opts [if word? :val [set val true]]]
	if opts [	; ?? do we want to OR refinements and options together, or override like this?
		before: has? opts 'before
		;at:     has? opts 'at
		after:  has? opts 'after
		;first:  has? opts 'first
		last:   has? opts 'last
	]

	either all [integer? delim  not any [value before after]] [
		dbg 'split-once-at-index
		either last [
			split-at-index/last series :delim
		][
			split-at-index series :delim
		]
	][
		; A big question is whether to use find/only or make it a refinement. 
		; Users can double block if needed. e.g. [[a b c]] = /only [a b c]
		dbg 'split-once-at-value
		if all [
			string? series
			not char? :delim		; This is an optimization, no need for FORM+LENGTH?
			not bitset? :delim		; This is important for functionality
		][delim: form :delim]
		drop-len: case [			; are we keeping or dropping the delimiter
			any [before after]	[0]	; keep it
			;!! The bitset test isn't needed here, as 'else handles it, but
			;	is it better to be explicit about them?
			;bitset? :delim 		[1]	; charsets have to be treated as chars, but their length is based on bits used
			series? :delim 		[length? :delim]
			'else	 			[1]	; Scalar values in blocks, and charsets
		]
		; No way to apply or refine funcs in Red yet, so this is a bit ugly/redundant.
		p-1: case [
			;all [before last]	[dbg 'BL  find/last series delim]	; = last
			all [after  last]	[dbg 'AL  find/tail/last series delim]
			;before 			[dbg 'B_  find series delim]		; = 'else
			after  				[dbg 'A_  find/tail series delim]
			last   				[dbg '_L  find/last series delim]	; = [before last]
			'else  				[dbg '__  find series delim]		; = before
		]
		; We can do it this way too, at the price of do+compose, or 
		; more elaboarate do-refined as I've explored, which boils
		; down to that. Given that this func splits the source only
		; once, always, that's a larger overhead than in the more
		; general split case where the results outweigh it by far.
		; But we're already also doing a lot of other work in this
		; func, so clarity should probably win.
		;fn: 'find 
		;fn: 'find/last
		;p-1: do compose [(fn) series delim]
		;p-1: do reduce/into [fn series delim] clear []
		
		; From the above case block, we can see that the exceptional cases are
		; when no refinement, or only /last is used. i.e. simple splitting.
		;print ['drop drop-len 'p-1 mold p-1 'p-2 mold p-2]
		reduce either p-1 [
			;p-2: either any [before after] [p-1][skip p-1 drop-len]
			p-2: skip p-1 drop-len
			[copy/part series p-1   copy p-2]
		][
			[copy series]
		]
	]
]

;-------------------------------------------------------------------------------

;?? Do we need a case sensitive option?

split-ctx: context [

	all-are?: func [    ; every? all-are? ;; each? is-each? each-is? are-all? all-of?
		"Returns true if all items in the series match a test"
		series	[series!]
		test	"Test to perform against each value; must take one arg if a function"
	][
		either any-function? :test [
			do [
				foreach value series [if not test :value [return false]]	;!! this doesn't compile
			]
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

	;?? What should the behavior be if the delimiter is an empty series,
	;   i.e. zero length? Other langs treat it as split at every value.
	split-delimited: function [
		"Split series at every occurrence of delim"
		series [series!]
		delim  "Delimiter marking split locations"
		/before "Include delimiter in the value following it"
		/at     "(default) Do not include delimiter in results"
		/after  "Include delimiter in the value preceding it"
		/first  "Split at the first occurrence of value; implies /count 1"
		/last   "Split at the last occurrence of value; implies /count 1"
		; TBD: is count worth supporting?
		/count ct [integer!] "Maximum number of splits to peform; remainder of series is the last"
		/with opts [block!]  "Block of options to use in place of refinements"
		/local v
	][
		; Do we allow blocks as delims? If not, we have to do something
		; else for standard parse rules that pass thru to this.
		dbg ["Split-delimited" mold series mold delim]
		;if not find delim-types type? :delim [cause-error 'script 'invalid-arg [delim]]

;		if all [
;			not find delim-types type? :delim 
;			not block? :delim
;		][cause-error 'script 'invalid-arg [delim]]
		; Blocks and integers require special treatment, to use them as parse rules.
;		if any [
;			not find delim-types type? :delim 
;			block? :delim
;		][delim: reduce ['quote delim]]
;		if all [
;			not find delim-types type? :delim 
;			not block? :delim
;		][delim: reduce ['quote delim]]
		
		; Set refinement/var vals if a matching named option exists
		;if opts [set-from-opts opts]
		;if opts [foreach val opts [if word? :val [set val true]]]
		;print mold opts
		if opts [
			before: has? opts 'before
			at:     has? opts 'at
			after:  has? opts 'after
			first:  has? opts 'first
			last:   has? opts 'last
			if count:  has? opts 'count [ct: opts/count]
			if any [first last][count: true ct: 1]
			; Set refinement args from options
			;if count [ct: opts/count]
		]

		if all [ct  ct < 1] [cause-error 'Script 'invalid-arg ct]
		
		dbg ['delim= mold delim 'before= before 'at= at 'after= after 'first= first 'last= last 'count= ct 'with= mold opts]

		; get-word/set-word values are treated specially in parse, so 
		; we have to quote them to use them as delimiter values.
		if any [get-word? :delim  set-word? :delim] [
			delim: compose [quote (delim)]
		]
		;!! ?? If we DO parens, it saves the user composing them, which is
		;	   the more common case than using them as values, which can
		;	   still then be done with AS-DELIM.
		if paren? :delim [delim: do delim]
		
		; This is only here because /last isn't as easy to do with parse.
		; Possible of course, just not as clean or obvious. Have to
		; profile, but find may also be faster.
		; But the wrinkle going the other way is that it's nice to have
		; the dialect mark special values (ints and blocks) with `quote`
		; so we can just pass that along for parse when /last isn't used.
		; That means we have to undecorate them, from `[quote <value>]`
		; back to a plain value for use with split-once. Note that this
		; is only an issue when coming from the dialected block processor,
		; because a user calling this func directly would never do that.
		; Would they? It does make it a special case.
		;	split-delimited series [quote [abc]]
		;	split-delimited/with series [quote 123] [last]
		;	etc.
		; So we add opts [dialected-call] to denote an internal dispatch. 
		; Ick.
		;?? And there is STILL the issue of whether we want to support
		;	/only, but users can nest the value in another block if 
		;	they need to do that, so I think we're OK there.
		if ct = 1 [
			either all [
				block? delim
				has? opts 'dialected-call
				parse delim ['quote any-type!]
			][
				return split-once/with series delim/2 opts
			][
				return split-once/with series delim opts
			]
		]
				
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
			dbg ['split-delimited-with-count ct]
			; Copy UP TO <count> parts
			parts: parse series compose/only [collect 1 (ct) (rule-core) mark:]
			; Then tack on the remaining data as the last part, but not if
			; they specified more parts than were available.
			if all [
				ct <= length? parts
				not empty? mark
			][append/only parts copy mark]
			parts	; be sure to return the parts
		][
			parse series compose/only [collect any (rule-core)]
		]
	]

	;-------------------------------------------------------------------------------


	block-of-ints?: func [value][
		all [block? :value  attempt [all-are? reduce value integer!]]
	]
	block-of-funcs?: func [value][
		all [block? :value  attempt [all-are? reduce value :any-function?]]
	]

;	; common char keywords
;	dash:		#"-"
;	underscore:	#"_"
;	colon:		#":"
;	equal:		#"="

	set 'split function [
		;"Split a series into parts; fixed or variable size, fixed number, or at delimiters"
		;"Split a series into parts, by delimiter, size, number, or advanced rules"
		"Split a series into parts, by delimiter, size, number, function, type, or advanced rules"
		series [series!] "The series to split"
		;!! need a more general name for this param now, spec or rule maybe.
		;dlm    ;[block! integer! char! bitset! any-string! any-function!] "Split size, delimiter(s), predicate, or rule(s)." 
		dlm    "Dialected rule (block), part size (integer), predicate (function), or delimiter." 
		/local s v rule
	][
		;-------------------------------------------------------------------------------
		;-- Parse rules
		;
		; Dialected rule handlers MUST set 'res
		=num: =once: =mod: =ord: =pos: =dlm: =ct: =char-word: none
		=sub-rule: none ; multi-split rules
		split-rule: [
			(=num: =once: =mod: =ord: =pos: =dlm: =ct: =char-word: =sub-rule: none)
			
			multi-split=
			
			; Single delim, just in a block rather than as a direct arg
			; Into N parts
			| 'into set =num integer! opt 'parts (  ; [['parts | 'pieces | 'chunks]]
				dbg 'split-into-N-parts
				res: split-into-N-parts series =num
			)

			| [
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
					dbg ['=num =num '=once =once '=mod =mod '=ord =ord '=pos =pos '=dlm mold =dlm '=ct =ct]
					;-----
					opts: reduce [=mod =ord]
					if =once [repend opts ['count 1]]
					if =ct  [repend opts ['count =ct]]
					; Not sure if I want to use ANY here, but it's a thought. It makes
					; it go through split-delimited when it really shouldn't for cases
					; where =pos is set. That should go directly to split-at-index,
					; which split-delimited now has logic handling for, to dispatch.
					; There it checks if the split count is 1, calls split-once, and
					; split-once checks the various options in play to dispatch to
					; split-at-index when appropriate. split-once is pretty ugly, as is
					; the refinement/opts propagation, but that logic would otherwise
					; pollute split-delimited, which has a nice, clear, small set of
					; parse rules right now. And while it seems like it shouldn't be
					; too bad to add it there, the fly in the ointment is /last, which
					; will make the rules for that quite different. Maybe still a net
					; win, but not beautiful.
					append opts 'dialected-call
					;!! I think there's a missing branch here. If 'every is used, and/or
					;	we have =pos rather than =dlm, `split-fixed-parts` should be
					;	called instead of split-delimited. BUT `split-fixed-parts` has
					;	no support for `opts` currently.
					res: split-delimited/with series any [=pos =dlm] opts
				)
			]

			| [delimiter= (
				dbg "delimiter (in block); split at every instance"
				res: split-delimited series =dlm
				)
			]


		]
;		sub-rule=: [
;			char-word= (=sub-rule: =char-word)
;			| delimiter= (=sub-rule: =delimiter)
;			| set =sub-rule any-type!
;		]
		multi-split=: [
			;!! Use any-type! while exploring ideas
			;opt 'first 'by set =sub-rule any-type! (
			opt 'first 'by [char-word= (=sub-rule: =char-word) | set =sub-rule any-type!] (
			;opt 'first 'by delimiter= (=sub-rule: =delimiter) (
			;opt 'first 'by sub-rule= (
				dbg "multi-split"
				;print ['multi type? :=sub-rule mold :=sub-rule]
				sub-series: split series :=sub-rule
				;print ['MS-1 mold series =sub-rule mold sub-series]
			)
			sub-split=
			(res: sub-series)
		]
		sub-split=: [
			;'then  opt 'by set =sub-rule any-type! (
			'then  opt 'by [char-word= (=sub-rule: =char-word) | set =sub-rule any-type!] (
				;print ['multi-sub type? :=sub-rule mold :=sub-rule]
				sub-series: collect [foreach sub sub-series [keep/only split sub :=sub-rule]]
			)
			; Nesting deeper isn't straightforward using this model, because
			; every level comes back with more deeply nested results. 2 levels
			; gives us 2D results, 3D results might be generally useful enough
			; to support, but beyond that I don't see much value. Not that 
			; deeper dimensions aren't valuable, but we're talking about 
			; delimited dimensions, where more dimensions means more chance of
			; conflict, more need for escaping, etc. In the case of numbers, 
			; you really just want to serialize those structures for efficiency.
			;opt sub-split=
		]
		;!! words referring to standard char! values may benefit from special 
		;	treatment. You can then use 'as-delim to treat them as words when
		;	needed, but those will likely be far less common.
		char-word=: [
			set =char-word [
				'null | 'newline | 'slash | 'escape | 'comma | 'lf | 'cr
				| 'space | 'tab | 'dot | 'dbl-quote 
				;| 'dash | 'underscore | 'colon | 'equal
			](
				;print ['char-word =char-word]
				=char-word: get =char-word
			)
		]
		delimiter=: [
			;'as-delim any-type! ("Treat as literal value, not position or rule")
			'as-delim set =dlm [integer! | block! | word! | paren!] ( ;("Treat as literal value, not position, rule, or char! keyword")
				=dlm: reduce ['quote =dlm]
			)
			| char-word= (=dlm: =char-word)
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
		count=: [opt ['up 'to] set =ct integer! 'times]
		
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
				;?? Should this split-at-index or split-fixed-parts? The reasoning
				;	for split-fixed-parts is that it's closer to splitting at every
				;	delimiter when a value is used as the lone arg to split, which
				;	also maps well to splitting flat blocks into fixed size records.
				dbg "integer; split-fixed-parts, split into chunks of its size"
				res: split-fixed-parts series dlm
				;dbg "integer; split-at-index"
				;res: split-at-index series dlm
				;if size < 1 [cause-error 'Script 'invalid-arg size]
				;rule: [collect [any [keep copy series 1 size skip]]]
			]
			; alt way to check
			;all [not integer? :dlm  not block? :dlm  not any-function? :dlm][
			;]
			any-function? :dlm [
				dbg "function; filter into pass/fail"
				;res: filter series :dlm
				res: partition series [:dlm]
			]
			; Do we want to make it easier on the user, for common cases,
			; by reducing here?
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
			
;			any [get-word? :dlm  set-word? :dlm] [
;				dbg probe "get/set-word"
;				res: split-delimited series :dlm
;			]

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
				;?? What if we COMPOSE dlm here, so the user just has to use parens
				;   for things like charsets? Otherwise the calls get a bit uglier
				;   on the user side. 
				either all [parse dlm split-rule  res][
					dbg "dialected block DONE"
					; A dialected rule was handled and the result was set.
					; Nothing else to do here.
					;TBD ensure res was set. :^)
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

]