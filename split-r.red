Red [
  todo: {
    1. tail and last (reverse)
    2. complete groups
  }
]
;#include %assert.red

context [
	;types: exclude default! make typeset! [integer! any-function! block! event!]
	refs: [before after at first last tail groups each limit quoted only by into]
	arity?: function [fn [any-function!]][i: 0 parse spec-of :fn [opt string! some [word! opt block! opt string! (i: i + 1)]] i]
	block-of?: func [input type][
		all [
			block? :input
			parse  :input [some type]
		]
	]
	sum-abs: function [block [block!]][out: 0 foreach i block [out: out + absolute i]]
	prod: function [block [block!]][out: 1 foreach i block [out: out * i] out]
	fn: fns: s: e: none
	make-fn: function [delim /with funcs /extern fn s e][
		arity: arity? :delim
		if not find [1 2] arity [cause-error 'script 'invalid-arg [:delim]]
		arg: pick [[s/1][s/1 s]] 1 = arity
		case [
			with [
				i: length? append funcs :delim
				compose [s: if (to-paren compose [quote (to-paren compose/deep [attempt [(to-path reduce [bind 'funcs :split-r i]) (arg)]])]) skip]
			]
			true [
				fn: :delim
				compose [s: if (to-paren compose/deep [e: attempt [fn (arg)]]) [if (all [series? e (head s) = (head e)]) :e | skip]]
			]
		]
	]
	make-quoted: function [delimiter [block!]][
		delim: copy [] 
		foreach item delimiter [
			append delim compose/only [quote (item)]
		]
	]
	
	set 'split-r function [
		"Split series according to specified delimiter"
		series     [series!]  "Series to split"
		delimiter  [default!] "Delimiter on which to split"
		/by     "Dummy (default) refinement for compatibility with dialect"
		/before "Split before the delimiter"
		/after  "Split after the delimiter"
		/at     "Split before and after the delimiter"
		/first  "Split on first delimiter / keep first chunk only"
		/last   "Split on last delimiter / keep last chunk only"
		/tail   "Split starting from tail"
		/groups  "Split series into delimiter-specified groups"
		/each   "Treat each element in block-delimiter individually"
		/limit  "Limit number of splittings / chunks to keep"
			ct  [integer!]
		/quoted "Treat delimiter as quoted"
		/only   "Omit empty chunks and rest (i.e. not specified)"
		/with   "Add options in block"
			options [block!]
		/case
		/local _ 
		/extern fn fns s e
	][
		;Set refinements
		if with [
			if not empty? opts: intersect refs options [
				 set bind opts :split-r true
				if limit [ct: select options 'limit]
			]
		]
		system/words/case [
			word? :delimiter [delimiter: to-lit-word delimiter]
			path? :delimiter [delimiter: to-lit-path delimiter]
		]
		;Clarify type of delimiter
		delim-type: system/words/case delim-cases: [
			quoted-each?:   all [quoted each block? :delimiter]['quoted-each]
			quoted ['quoted]
			int?:       integer? :delimiter [
				if :delimiter > 0 [
					if 0 = size: to integer! (length? series) / delimiter [size: length? series]
					size: max 1 size
				]
				'int
			]
			fn?:        any-function? :delimiter ['fn]
			int-block?: block-of? :delimiter integer! ['int-block]
			fn-block?:  block-of? :delimiter any-function? ['fn-block]
			to-logic all [block? :delimiter not empty? intersect refs :delimiter] [DSL?: yes 'DSL]
			all [series? delimiter empty? delimiter][;Treat empty delimiter as 1
				delimiter: 1 
				size: to integer! (length? series) / delimiter
				int?: yes 'int
			]
			parse?:   block? :delimiter [
				funcs: clear []
				forall delimiter [
					system/words/case [
						all [
							find [get-word! get-path!] type?/word delimiter/1 
							any-function? f: get delimiter/1
						][change/only delimiter make-fn/with :f funcs]
						paren? delimiter/1 [change delimiter do delimiter/1]
					]
				]
				delimiter: compose/deep/only delimiter
				'parse
			]
			simple?:  true ['simple]
		]

		;Construct delimiter
		delim: switch/default delim-type make-delim: [
			quoted-each [make-quoted :delimiter]
			quoted [compose/only [quote (:delimiter)]]
			fn [make-fn :delimiter]
			DSL [parse delimiter [
				opt [['before 'and 'after | 'at] (at: true) | 'before (before: true) | 'after (after: true) | 'by (by: true)]
				opt ['first (first: true) | 'last (last: true)]
				opt [ahead [integer! [end | 'only]] set delimiter integer! | set ct integer! (limit: true)]
				[s: 'quoted (quoted: true) opt ['each (each: true)] set delimiter skip 
				| 'into set delimiter skip opt 'groups (groups: true)
				| [ 
				    paren! (delimiter: do s/1)
				  | [get-word! | get-path!] (delimiter: get s/1)
				  | [word! | path!] (delimiter: get s/1)
				  | set delimiter skip 
				  ]
				] (
				  delim-type: system/words/case delim-cases 
				  delim: switch/default delim-type make-delim [:delimiter]
				)
				opt ['only (only: true)]
			] delim]
		] [
			system/words/case [
				any [
					find [get-word! set-word! get-path! set-path!] type?/word :delimiter
				][reduce ['quote :delimiter]]
				true [:delimiter]
			]
		]
		;Construct inner main rule
		main: compose/deep/only system/words/case [
			groups [
				out: none
				system/words/case [
					int? [
						either delim <= 0 [[keep (quote (copy []))]][
							rest: (length? series) % delim
							system/words/case [
								all [tail only] []
								all [first only] [[keep copy _ (size + pick [1 0] rest > 0) skip]]
								first [[opt [keep copy _ (size) skip] [end | keep copy _ thru end]]]
								only [[(rest) [keep copy _ (size + 1) skip] (delim - rest) [keep copy _ (size) skip]]]
								true [[keep copy _ (size) skip]]
							]
						]
					]
					int-block? [
						out: copy [s: if (to-paren compose [(quote (length? s)) >= (prod delim)])]
						ints: copy delim
						i: take ints
						res: compose [keep copy _ (i) skip]
						while [i: take ints][res: compose/deep/only [collect [(i) (res)]]]
						append out res
					]
					fn-block? [] 
					all [block? delim not fn? each] [
						out: make block! len: 1 + length? delim
						loop len [append/only out copy []]
						blk: copy delim
						res: copy [s: ]
						forall blk [
							append res compose [(blk/1) (to-paren compose [quote (to-paren compose [append pick out (index? blk) s/1])]) |]
						]
						either only [
							append res compose [skip]
						][
							append res compose [skip (to-paren compose [quote (to-paren compose [append pick out (1 + length? blk) s/1])])]
						]
					]
					true [
						out: copy []
						system/words/case [
							only [[keep (delim) | skip]]
							true [[keep (delim) | s: skip (quote (append out s/1))]]
						]
					]
				]
			]
			int? [either delim <= 0 [[keep (quote (copy []))]][[keep copy _ (delim) skip]]]
			int-block? [
				sum-ints: sum-abs delimiter 
				[
					if (quote ((length? series) >= sum-ints)) 
					(quote (delim: head delim)) 
					while [
						if (quote (not tail? delim)) 
						(quote (i: delim/1 delim: next delim)) 
						[
						  if (quote (i < 0))(quote (i: absolute i))
						  i skip
						| keep copy _ i skip
						] series:
					]
				]
			]
			at or (before and after) [system/words/case [
				only [[s: keep copy _ to [(delim) | if (quote (not head? s)) end] any keep (delim) opt end]]
				;only [[keep copy _ to [(delim) | end] any keep (delim) opt end]]
				true [[keep copy _ to (delim) keep (delim)]]
			]]
			after [[keep copy _ thru (delim)]]
			before [system/words/case [
				only [[keep copy _ [(delim) to [(delim) | end]]]]
				true [[keep copy _ [opt (delim) to [(delim) | end]]]]
			]]
			true [system/words/case [
				all  [first only] [[s: keep copy _ to [(delim) | if (quote (not head? s)) end]]]
				only [[keep copy _ to [(delim) | end] any (delim) opt end]]
				true [[keep copy _ to (delim) (delim)]]
			]]
		]
		
		;Add stepper if needed
		step: system/words/case [
			
		]
		if step [append main reduce ['| step]]
		
		;Make looper
		rule: to-block system/words/case [
			limit [reduce [0 ct]]
			any [first last] ['opt]
			all [groups int?] [delim];[system/words/case [int? [delim]]]
			only ['some]
			true ['any]
		]
		;Modify looper
		system/words/case [
			int-block? []
			groups []
			all [only (at or (before and after))][insert rule compose/only [any keep (delim)]]
			all [before only][insert rule compose/only [to (delim)]]
			all [after only][insert rule compose/only [any (delim)]]
			only [insert rule compose/only [any (delim)]]
		]
		;Construct rule
		append/only rule main
		;Construct and add rest if needed
		rest: if not only [
			system/words/case [
				any [
					all [int? not groups]
					int-block?
					before and not after
					all [groups any [first last limit]]
				] [[end | keep copy _ thru end]]
				true [[keep copy _ thru end]]
			]
		]
		if rest [append/only rule rest]
		
		;Prepare final
		if tail or last [series: tail series]
		
		;Prepare result
		;reduce [delim size]
		result: system/words/case [
			all [groups int?] [make block! delim + 1]
			int? [either delim > 0 [make block! to integer! delim / size + 1][make block! 2]]
			all [groups block? :delim] [make block! 1 + length? delim]
			true [copy []]
		]
		;Do it 
		;probe 
		final: compose/only [collect into result (rule)]
		either case [
			parse/case series final
		][
			parse series final
		]
		system/words/case [
			groups [
				system/words/case [
					all [block? delim not fn? each][
						if empty? system/words/last out [
							remove back system/words/tail out
						] result: out
					]
					all [block? out not groups] [result: reduce either only [[result]][[result out]]]
				]
			]
			tail or last [reverse result]
		]
		result
	]
	comment {
	#assert [
		;Test delimiter-types, no refinements
		[[0] [1 b 2 c 3 d]]  = split-r [0 a 1 b 2 c 3 d] 'a
		[[0] [1] [2] [3] []] = split-r [0 a 1 b 2 c 3 d] word!
		[[0 a] [b 2 c] [d]]  = split-r [0 a 1 b 2 c 3 d] :odd?
		[[0] [1 b] [c 3 d]]  = split-r [0 a 1 b 2 c 3 d] ['a | quote 2]
		[[0] [b 2] [d]]      = split-r [0 a 1 b 2 c 3 d] [word! :odd?]
		[#{CA} #{} #{ED}]    = split-r #{CAFE FEED} #{FE}
		
		;Test before, after, at
		[[0] [a 1 b 2 c 3 d]]       = split-r/before [0 a 1 b 2 c 3 d] 'a
		[[0] [a 1] [b 2] [c 3] [d]] = split-r/after  [0 a 1 b 2 c 3 d] number!
		[[0 a] 1 [b 2 c] 3 [d]]     = split-r/at     [0 a 1 b 2 c 3 d] :odd?

		;Test quoted
		[[0 a 1 b] [c 3 d 4 e]]     = split-r/quoted    [0 a 1 b 2 c 3 d 4 e] 2
		[[0 a 1 b] [2 c] [3 d 4 e]] = split-r/at/quoted [0 a 1 b [2 c] 3 d 4 e] [2 c]

		;Test first, limit
		[[0] [1 b 2 c 3 d]]     = split-r/first        [0 a 1 b 2 c 3 d] word!
		[[0] [1] [2 c 3 d]]     = split-r/limit        [0 a 1 b 2 c 3 d] word! 2
		[[0] [a 1] [b 2 c 3 d]] = split-r/before/limit [0 a 1 b 2 c 3 d] word! 2
		
		;Test only
		[[0]]         = split-r/first/only        [0 a 1 b 2 c 3 d] word!
		[[0] [1]]     = split-r/limit/only        [0 a 1 b 2 c 3 d] word! 2
		[[a 1] [b 2]] = split-r/before/limit/only [0 a 1 b 2 c 3 d] word! 2

		;Test sized chunks
		[[0 a] [1 b] [2 c] [3 d]]         = split-r      [0 a 1 b 2 c 3 d] 2
		[[0 a] [1 b 2] [c 3 d]]           = split-r      [0 a 1 b 2 c 3 d] [2 3]
		[[0 a] [1 b 2]]                   = split-r/only [0 a 1 b 2 c 3 d] [2 3]
		["DD" "MM" "YYYY" "SS" "MM" "HH"] = split-r      "DDMMYYYY/SSMMHH" [2 2 4 -1 2 2 2]
		
		;Test grouping
		[[0 a 1 b] [2 c 3 d] []]  = split-r/groups      [0 a 1 b 2 c 3 d] 2
		[[0 a 1 b] [2 c 3 d] [4]] = split-r/groups      [0 a 1 b 2 c 3 d 4] 2
		[[0 a 1 b 2] [c 3 d 4]]   = split-r/groups/only [0 a 1 b 2 c 3 d 4] 2

		;Test dialect
		[[0 a 1 b] [c 3 d]]         = split-r [0 a 1 b 2 c 3 d]     [by quoted 2]
		[[a 1] [b 2]]               = split-r [0 a 1 b 2 c 3 d]     [before 2 word! only]
		[[0 a] [1 b 2] [c 3 d 4 e]] = split-r [0 a 1 b 2 c 3 d 4 e] [by first [2 3]]
		[[[0 a] [1 b] [2 c]]]       = split-r [0 a 1 b 2 c 3 d 4 e] [into [2 3] groups only]
		
		;Test case
		["a" "A" ""] = split-r      "abAB" "B"
		["abA" ""]   = split-r/case "abAB" "B"
	]
	}
]