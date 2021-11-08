Red [
  todo: {
    1. tail and last (reverse)
    2. complete into
  }
]
;#include %assert.red

context [
	;types: exclude default! make typeset! [integer! any-function! block! event!]
	refs: [before after around first last tail each limit quoted only by into]
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
	set-before: does [set bind 'before :split-r yes]
	series: to-block series!
	check-series: function [types][all [
		not empty? intersect series types
		empty? exclude types series
	]]
	make-fn: function [delim /with funcs /extern fn s e /local b][
		arity: arity? :delim
		if not find [1 2 3] arity [cause-error 'script 'invalid-arg [:delim]]
		types: copy []
		parse spec-of :delim [opt string! some [skip [set b block! (append/only types b) | (append/only types copy [])] opt string!]]
		arg: switch arity [
			1 [either check-series types/1 [[s]][[s/1]]] ; Needs /before to not eat item
			2 [case [
				check-series types/1 [[s s/1]] ; First arg is series. Needs /before to not eat item
				check-series types/2 [[s/1 s]] ; Second arg is series. Needs /before to not eat item
				true [set-before [s/-1 s/1]]   ;Usually comparison, by default split between items
			]]
			3 [[s/-1 s/1 s]] ;Total control, needs to use /before to not eat item
		]
		case [
			with [
				i: length? append funcs :delim
				either op? :delim [
					compose [s: if (to-paren compose [
						quote (to-paren compose/deep [
							fn: (to-get-path reduce [bind 'funcs :split-r i]) 
							attempt [(arg/1) fn (arg/2)]
						])
					]) skip]
				][
					compose [s: if (to-paren compose [
						quote (to-paren compose/deep [
							attempt [(to-path reduce [bind 'funcs :split-r i]) (arg)]
						])
					]) skip]
				]
			]
			true [
				fn: :delim
				either op? :delim [
					compose [s: if (to-paren compose/deep [e: attempt [(arg/1) fn (arg/2)]]) skip]
				][
					compose [s: if (to-paren compose/deep [e: attempt [fn (arg)]]) 
						[if (all [series? e (head s) = (head e)]) :e | skip]
					]
				]
			]
		]
	]
	word-cases: [
		case [compose/only system/words/case [
			lit-word? item [[ahead lit-word! quote (item)]] 
			word? item [[ahead word! (to-lit-word item)]] 
			true [[quote (item)]]
		]]
		item == quote | ['|]
		true [compose/only either lit-word? item [[ahead lit-word! quote (item)]][[quote (item)]]]
	]
	make-quoted: function [delimiter [block!] case][
		delim: copy [] 
		foreach item delimiter [
			append delim system/words/case bind word-cases :make-quoted
		]
	]
	transform: function [delimiter funcs][
		forall delimiter [
			system/words/case [
				find [change insert replace] delimiter/1 [cause-error 'script 'invalid-arg [:delimiter]]
				all [
					find [get-word! get-path!] type?/word delimiter/1 
					any-function? f: get delimiter/1
				][change/only delimiter make-fn/with :f funcs]
				paren? delimiter/1 [
					change delimiter d: do delimiter/1 
					if word? delimiter/1 [d: attempt [get delimiter/1] if block? :d [transform d funcs]]
				]
				block? delimiter/1 [transform delimiter/1 funcs]
				word?  delimiter/1 [d: attempt [get delimiter/1] if block? :d [transform d funcs]]
			]
		]
	]
	de-lf: func [s][foreach b s [if block? b [new-line/all b no]]]
	
	set 'split-r function [
		"Split series according to specified delimiter"
		series     [series!]  "Series to split"
		delimiter  [default!] "Delimiter on which to split"
		/by     "Dummy (default) refinement for compatibility with dialect"
		/before "Split before the delimiter"
		/after  "Split after the delimiter"
		/around "Split before and after the delimiter"
		/first  "Split on first delimiter / keep first chunk only"
		/last   "Split on last delimiter / keep last chunk only"
		/tail   "Split starting from tail"
		/into   "Split into delimiter-specified (possibly nested) groups"
		/each   "Treat each element in block-delimiter individually"
		/limit  "Limit number of splittings / chunks to keep"
			ct  [integer!]
		/quoted "Treat delimiter as quoted"
		/only   "Omit empty chunks and rest (i.e. not specified)"
		/morph  "Transform splitted chunks"
			as
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
				if delimiter > 0 [
					if 0 = size: to integer! (length? series) / delimiter [size: length? series]
					size: max 1 size
				]
				'int
			]
			;pair? :delimiter ['pair] ;;???
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
				transform delimiter funcs
				delimiter: compose/deep/only delimiter
				'parse
			]
			simple?:  true ['simple]
		]

		;Construct delimiter
		delim: switch/default delim-type make-delim: [
			quoted-each [make-quoted :delimiter case]
			quoted [
				item: :delimiter 
				compose/only system/words/case bind word-cases :split-r
			]
			fn [make-fn :delimiter]
			DSL [parse delimiter [
				opt [['before 'and 'after | 'around] (around: true) | 'before (before: true) | 'after (after: true) | 'by (by: true)]
				opt ['first (first: true) | 'last (last: true)]
				opt [ahead [integer! [end | 'only]] set delimiter integer! | set ct integer! (limit: true)]
				[s: 'quoted (quoted: true) opt ['each (each: true)] set delimiter skip 
				| 'into set delimiter skip opt 'groups (into: true)
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
			into [
				out: none
				system/words/case [
					int? [
						either delim <= 0 [[keep (quote (copy []))]][
							rest: (length? series) % delim
							system/words/case [
								all [tail only] []
								all [first only] [[keep copy _ (size + pick [1 0] rest > 0) skip]]
								first [[opt [keep copy _ (size) skip] [end | keep copy _ thru end]]]
								true [[(rest) [keep copy _ (size + 1) skip] (delim - rest) [keep copy _ (size) skip]]]
								;only [[(rest) [keep copy _ (size + 1) skip] (delim - rest) [keep copy _ (size) skip]]]
								;true [[keep copy _ (size) skip]]
							]
						]
					]
					;delim-type = 'pair [ ;;???
					;]
					int-block? [
						out: copy [s: if (to-paren compose [(quote (length? s)) >= (prod delim)])]
						ints: copy delim
						i: take ints
						res: compose [keep copy _ (i) skip]
						while [i: take ints][res: compose/deep/only [collect [(i) (res)]]]
						append out res
					]
					fn-block? [] 
					all [block? delim] [
						out: make block! len: length? delim
						loop len [append/only out copy []]
						blk: copy delim
						res: copy [s:]
						forall blk [
							i: index? blk
							out: at head out i
							system/words/case [
								head? blk [
									foreach o out [
										append o [append/only out/1 copy/part series s]
									]
								]
								last? blk [
									append pick head out i compose [e: copy (path: to-path compose [out (i - 1)]) clear (path)]
								]
								true [
									foreach o out [
										append o compose [append/only (to-path compose [out (i)]) copy (path: to-path compose [out (i - 1)]) clear (path)]
									]
								]
							]
						]
						out: head out
						forall blk [
							append/only res blk/1
							append/only res to-paren compose [quote (to-paren out/(index? blk))]
							either last? blk [append res [keep (quote (e)) series:]][append res quote series:]
							append res '|
						]
						foreach o out [clear o]
						;either only [
							append res 'skip
						;][
						;	append res compose [skip (to-paren compose [quote (to-paren compose [append pick out (1 + length? blk) s/1])])]
						;]
						res
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
			around or (before and after) [system/words/case [
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
			all [into int?] [delim];[system/words/case [int? [delim]]]
			only ['some]
			true ['any]
		]
		;Modify looper
		system/words/case [
			int-block? []
			into []
			all [only (around or (before and after))][insert rule compose/only [any keep (delim)]]
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
					all [int? not into]
					int-block?
					before and not after
					;all [into any [first last limit]]
				] [[end | keep copy _ thru end]]
				into [
					if all [not int? block? :delim] [compose/deep [
						[s: opt [
							if (to-paren compose [not empty? (path: to-path compose [out (-1 + length? out)])]) 
							(to-paren compose [e: (to-paren compose [copy append (path) copy/part series s clear (path)]) keep (quote (e))])
						]]
					]]
				]
				true [[keep copy _ thru end]]
			]
		]
		if rest [append/only rule rest]
		
		;Prepare final
		if tail or last [series: tail series]
		
		;Prepare result
		;reduce [delim size]
		result: system/words/case [
			all [into int?] [make block! delim + 1]
			int? [either delim > 0 [make block! to integer! delim / size + 1][make block! 2]]
			all [into block? :delim] [make block! 1 + length? delim]
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
			into [
				
				system/words/case [
					all [block? delim not fn? each][
						if empty? system/words/last out [
							remove back system/words/tail out
						] result: out
					]
					;block? delim [if not empty? b: back back out [append result b]]
					;all [block? out not into] [result: reduce either only [[result]][[result out]]]
				]
				de-lf result
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
		
		;Test before, after, around
		[[0] [a 1 b 2 c 3 d]]       = split-r/before [0 a 1 b 2 c 3 d] 'a
		[[0] [a 1] [b 2] [c 3] [d]] = split-r/after  [0 a 1 b 2 c 3 d] number!
		[[0 a] 1 [b 2 c] 3 [d]]     = split-r/around     [0 a 1 b 2 c 3 d] :odd?

		;Test quoted
		[[0 a 1 b] [c 3 d 4 e]]     = split-r/quoted    [0 a 1 b 2 c 3 d 4 e] 2
		[[0 a 1 b] [2 c] [3 d 4 e]] = split-r/around/quoted [0 a 1 b [2 c] 3 d 4 e] [2 c]

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
		[[0 a 1 b] [2 c 3 d] []]  = split-r/into      [0 a 1 b 2 c 3 d] 2
		[[0 a 1 b] [2 c 3 d] [4]] = split-r/into      [0 a 1 b 2 c 3 d 4] 2
		[[0 a 1 b 2] [c 3 d 4]]   = split-r/into/only [0 a 1 b 2 c 3 d 4] 2

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