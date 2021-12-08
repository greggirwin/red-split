Red [
	Title:   "Red SPLIT functions"
	Author:  "Gregg Irwin"
	Adapted: "For use as refinement-based instead of dialect-based"
	Adaptation: "Toomas Vooglaid"
	File: 	 %split.red
	Tabs:	 4
	Rights:  "Copyright 2021 All Mankind. No rights reserved."
	License: 'MIT
]
context [
	trace: off
	dbg: either all [trace][:print][:none]

	blockify: func [value][compose/only [(:value)]]  

	has?: func [series value][to logic! find/only series value]

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
		/first
		/last
		/limit ct
		/with opts
		/local p
	][
		if parts < 1 [cause-error 'Script 'invalid-arg parts]
		if parts = 1 [return blockify series] 
		if with [set [first last limit ct] opts]
		sizes: part-sizes length? series parts
		if first [limit: yes ct: 1]
		case [last [sizes: copy/part back tail sizes 1] limit [sizes: copy/part sizes ct ct: 1]]
		opts: reduce [first last limit ct]
		split-var-parts/with series sizes opts
	]

	split-fixed-parts: function [
		"If the series can't be evenly split, the last value will be shorter"
		series [series!]  "The series to split"
		size   [integer!] "Size of each part"
		/first
		/last
		/limit ct
		/with opts
	][
		if size < 1 [cause-error 'Script 'invalid-arg size]
		if with [set [first last limit ct] opts]
		if first [limit: yes ct: 1]
		either last [
			append/only res: copy [] copy/part series (length? series) - size
			append/only res copy/part skip tail series negate size size
			;insert/only res head clear skip series (length? series) - size
			res
		][
			rule: [any [keep copy series 1 size skip s:]]
			change rule either limit [ct]['any]
			res: parse series [collect rule]
			if all [limit not tail? series][append/only res copy s]
			res
		]
	]

	split-var-parts: function [
		"Split a series into variable size pieces"
		series [series!] "The series to split"
		sizes  [block!]  "Must contain only integers; negative values mean ignore that part"
		/first
		/last
		/limit ct
		/with opts
	][
		if with [set [first last limit ct] opts]
		if first [limit: yes ct: 1]
		if not parse sizes [some integer!][ cause-error 'script 'invalid-arg [sizes] ]
		either last [
			sizes: reverse copy sizes
			series: tail series
			res: collect [keep collect [
				foreach len sizes [
					either positive? len [
						keep/only copy/part series series: skip series negate len
					][
						series: skip series len ()						;-- return unset so that nothing is added to output
					]
				]]
			]
			reverse res
			if not head? series [insert/only res copy/part head series series]
			res
		][
			rule: [
				while [not tail? series][
					foreach len sizes [
						either positive? len [
							keep/only copy/part series series: skip series len
						][
							series: skip series negate len ()			;-- return unset so that nothing is added to output
						]
					]
				]
			]
			change/part rule either limit [[loop ct]][[while [not tail? series]]] 2
			res: collect rule
			if all [limit not tail? series] [append/only res copy series]
			res
		]
	]

	split-var-parts2: function [
		"Split a series into variable size pieces"
		series [series!] "The series to split"
		sizes  [block!]  "Must contain only integers; negative values mean ignore that part"
		/only "Keep patterns as separate blocks"
	][
		if not parse sizes [some integer!][ cause-error 'script 'invalid-arg [sizes] ]
		collect [
			while [not tail? series][
				res: collect [
					foreach len sizes [
						either positive? len [
							keep/only copy/part series series: skip series len
						][
							series: skip series negate len
							()										;-- return unset so that nothing is added to output
						]
					]
				]
				either only [keep/only res][keep res]
			]
		]
	]

	delim-types: exclude default! make typeset! [integer! block! any-function! event!]

	split-delimited: function [
		"Split series at every occurrence of delim"
		series [series!]
		delim  "Delimiter marking split locations"
		/before "Include delimiter in the value following it"
		/after  "Include delimiter in the value preceding it"
		/first  "Split at the first occurrence of value"
		/last   "Split at the last occurrence of value"
		/limit ct [integer!] "Maximum number of splits to perform; remainder of series is the last"
		/with opts [block!]  "Block of options to use in place of refinements (internal)"
		/local v 
	][
		if with [set [before after first last limit ct] opts]
		if first [limit: yes ct: 1]
		if all [ct  ct < 1] [cause-error 'Script 'invalid-arg ct]
		result: copy []
		either last [
			either pos: case [
				after [find/last/tail series delim]
				'else [find/last series delim]
			][
				unless all [before head? series][append/only result copy/part series series: pos]
				case [
					before [append/only result copy series]
					after  [if not tail? series [append/only result copy series]]
					'else  [append/only result copy find/tail series delim]
				]
			][
				append/only result copy series
			]
		][
			find-next: case [
				before [[pos: find any [find/match/tail series delim  series] delim]]
				after  [[pos: find/tail series delim]]
				'else  [[pos: find series delim pos1: find/match/tail pos delim]]
			]
			keep-found: [
				append/only result copy/part series pos
				series: either any [before after][pos][pos1]
				if all [tail? series not any [before after]][
					append/only result copy series
				]
			]
			either limit [
				loop ct compose [(find-next) unless pos [append result copy series series: tail series break] (keep-found)]
			][
				while find-next keep-found
			]
			if not tail? series [append/only result copy series]
		]
		result
	]

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
	block-of-ints?: func [value][
		all [block? :value  attempt [all-are? reduce value integer!]]
	]
	block-of-funcs?: func [value][
		all [block? :value  attempt [all-are? reduce value :any-function?]]
	]

	series: to-block series!
	is-series?: function [types][
		all [
			not empty? intersect series t: collect [foreach t types [
				keep to-block either typeset? ts: get t [ts][t]
			]]
			empty? exclude t series
		]
	]
	
	split-by-func: function [
		series
		fn
		/before
		/after
		/first
		/last
		/limit ct
		/with opts "(internal)"
	][
		if with [set [before after first last limit ct] opts]
		if first [limit: yes ct: 1]
		result: copy []
		types: parse spec-of :fn [
			opt string! 
			collect any [word! [keep block! | keep (copy [])] opt string!]
		]
		call: switch/default arity: length? types [
			1 [either is-series? types/1 [[fn pos]][[fn pos/1]]] 
			2 [before: yes either op? :fn [[pos/-1 fn pos/1]][[fn pos/-1 pos/1]]]  ; Usually comparison, split between items
		][cause-error 'script 'invalid-arg [:fn]]
		either last [pos: back series: tail series][pos: series]
		step: pick [-1 1] last
		find-next: [
			res: attempt call
			any [all [res not all [before head? pos]] tail? pos: skip pos step]
		]
		cases: [
			integer? res [if res = 0 [break] pos1: skip pos res]
			all [series? res  same? head res head pos][if res = pos [break] pos1: res]
			true == res [pos1: next pos]
			true [pos1: any [find pos res  tail pos]]
		]
		keep-found: [
			case cases
			append/only result copy/part series either after [pos1][pos]
			series: either before [pos][pos1]
			if all [tail? series not any [before after limit]][append/only result copy series]
			pos: pos1
		]
		
		either last [
			until [
				any [
					res: attempt call
					pos: skip stop: pos step
				]
				any [res  head? stop]
			] 
			case cases
			either res [
				if not all [before head? pos][
					append/only result copy/part head series either after [pos1][pos]
				]
				if not all [after tail? pos1] [append/only result copy either before [pos][pos1]]
			][
				append/only result copy series
			]
		][
			case [
				limit [loop ct compose [until find-next  (keep-found)]]
				'else [while [until find-next all [res not tail? pos]] keep-found]
			]
			if not tail? series [append/only result copy series]
		]
		result
	]
	
	prod: function [block [block!]][out: 1 foreach i block [out: out * i]]
	collect-groups: function [
		series [series!]
		delim  [block!]
	][
		collect [
			either single? delim [
				return copy/part series delim/1
			][
				step: prod rest: next delim
				loop delim/1 [
					keep/only collect-groups series rest
					series: skip series step
				]
			]
		]
	]
	split-into-groups: function [
		series [series!]
		delim  [block!]
		/first
		/last
		/limit ct
		/with opts
	][
		if with [set [first last limit ct] opts]
		if first [limit: yes ct: 1]
		step: prod delim
		if last [series: skip tail series negate step]
		rule: [
			while [not tail? series] [
				keep/only collect-groups series delim 
				series: skip series step
			]
		]
		change/part rule either limit [[loop ct]][[while [not tail? series]]] 2
		collect rule
	]
	
	split-group: function [
		series [series!]
		delim  [block!]
		;/first
		;/last
		;/limit ct
		;/with opts
	][
		if with [set [before after first last limit ct] opts]
		if first [limit: yes ct: 1]
		results: make block! len: length? delim
		loop len [append/only results copy []] 
		res: copy []
		forall delim [
			i: index? delim
			results: at head results i
			case [
				head? delim [
					foreach o results [
						append o [append/only results/1 copy/part series s]
					]
				]
				last? delim [
					append pick head results i compose [
						e: copy (path: to-path compose [results (i - 1)]) clear (path)
					]
				]
				true [
					foreach o results [
						append o compose [
							append/only (to-path compose [results (i)]) copy (path: to-path compose [results (i - 1)]) clear (path)
						]
					]
				]
			]
		]
		results: head results
		forall delim [
			append res case [
				last? delim [compose/deep/only [s: [(delim/1) | end]]]
				true [compose/only [s: (delim/1)]]
			]
			append/only res to-paren compose [quote (to-paren results/(index? delim))]
			if last? delim [append res [keep (quote (e))]]
			append res quote series:
			append res '|
		]
		tmp: copy skip find/reverse/tail back tail res '| 2
		take/last tmp
		append res compose/deep [skip opt [end s: (tmp)]]
		foreach o results [clear o]
		res: compose/deep res
		parse series [collect any [res]]
	]
	
	split-by-rule: function [
		series [series!]
		delim  [block!]
		/before
		/after
		/first
		/last
		/limit ct
		/with opts
	][
		if with [set [before after first last limit ct] opts]
		if first [limit: yes ct: 1]
		either last [
			series: tail series
			rule: [
				any [s: 
				  delim e: [
					if (before) opt [if (not head? s) keep (copy/part head s s)] :s keep copy _ thru end
				  | if (after) keep (copy/part head s e) [end | keep copy _ thru end]
				  | keep (copy/part head s s) :e keep copy _ thru end
				  ]
				| if (head? s) keep copy _ thru end
				| (s: back s) :s
				]
			]
		][
			rule: [
				any [
				  if (before) keep copy _ [opt delim to [delim | end]]
				| if (after)  keep copy _  thru [delim opt end | end]
				| keep copy _ to [delim | end] opt [delim s: opt [end keep (copy s)] :s]
				] [end | keep copy _ to end]
			]
			change rule either limit [ct]['any]
		]
		parse series [collect rule]
	]
	
	set 'split-r function [
		"Split a series into parts, by delimiter, size, number, function, type, or advanced rules"
		series [series!] "The series to split"
		dlm    "Dialected rule (block), part size (integer), predicate (function), or delimiter." 
		/before
		/after
		/first
		/last
		/parts
		/group
		/limit ct
		/value
		/rule
		/with opts
		/local s v ;rule
	][
		if with [set bind opts :split-r true]
		;foreach o opts [print [o get o]]
		case [
			any [find delim-types type? :dlm value] [
				res: split-delimited/with series dlm reduce [before after first last limit ct]
			]
			integer? :dlm [
				res: either parts [
					split-into-N-parts/with series dlm reduce [first last limit ct]
				][
					split-fixed-parts/with  series dlm reduce [first last limit ct]
				]
			]
			block-of-ints? :dlm [
				res: either group [
					split-into-groups/with series dlm reduce [first last limit ct]
				][
					split-var-parts/with   series dlm reduce [first last limit ct]
				]
			]
			any-function? :dlm [
				res: split-by-func/with series :dlm reduce [before after first last limit ct]
			]
			block? :dlm [
				res: case [
					group [split-group series dlm];TBD /with reduce [first last limit ct]]
					rule  [split-by-rule/with series dlm reduce [before after first last limit ct]]
					true  [split-delimited/with series dlm reduce [before after first last limit ct]]
				]
			]
			'else [
				cause-error 'Script 'invalid-arg :dlm
			]
		]
		return res		
	]
]