Red []
ctx: context [
	sum-abs: function [block [block!]][out: 0 foreach i block [out: out + absolute i]]
	prod:    function [block [block!]][out: 1 foreach i block [out: out * i] out]
	integers?: function [sizes /positive][
		all [
			block? sizes 
			parse sizes [some [i: integer! if (any [not positive positive? i/1])]]
		]
	]
	
	split-into-N-parts: function [
		"Split series into N parts"
		series [series!] 
		N      [integer!]
		/with options
		/limit ct [integer!]
		;/tail
		/only
	][
		if with [set [only limit ct] options]
		out: make block! either limit [ct + 1][N]
		len: to integer! (length? series) / N
		rest: (length? series) % N
		main: N - rest
		if limit [
			rest: min rest ct 
			main: max 0 ct - rest 
		]
		body: [
			part: copy/part series len*
			if not all [only empty? part] [
				append/only out part
				series: skip series len*
			]
		]
		len*: len + 1
		loop rest body
		len*: len
		loop main body
		if all [not only limit not tail? series][append/only out series]
		out
	]

	split-fixed-parts: function [
		"Split series into N-sized parts, last part possibly shorter"
		series [series!]  "The series to split"
		size   [integer!] "Size of each part"
		/with options
		/limit ct
		/only
	][
		if size < 1 [cause-error 'Script 'invalid-arg [size]]
		if with [set [only limit ct] options]
		div: either limit [ct][round/ceiling/to (length? series) / size 1]
		out: make block! div + 1
		loop div [
			if not all [only empty? series][
				append/only out copy/part series size
				series: skip series size
			]
		]
		if all [not only limit not tail? series][append/only out series]
		out
	]

	split-var-parts: function [
		"Split a series into variable size pieces"
		series [series!] "The series to split"
		sizes  [block!]  "Must contain only integers; negative values mean ignore that part"
		/with options
		/limit ct 
		/only
	][
		if not integers? sizes [cause-error 'script 'invalid-arg [sizes]]
		if with [set [only limit ct] options]
		size: sum-abs sizes
		full: to integer! (length? series) / size
		div: case [
			limit [either only [min ct full][ct]] 
			only  [full] 
			true  [round/ceiling/to (length? series) / size 1]
		]
		out: make block! div + 1
		loop div [
			if not all [only empty? series][
				foreach len sizes [
					either positive? len [
						append/only out copy/part series len 
						series: skip series len
					][
						series: skip series negate len
					]
				]
			]
		]
		if all [not only limit not tail? series][append/only out series]
		out
	]
	
	split-nested-parts: function [
		"Split a series into hierarchy of nested parts"
		series [series!]
		sizes  [block!]
		/with options
		/limit ct 
		/only
	][
		if not integers?/positive sizes [cause-error 'script 'invalid-arg [sizes]]
		if with [set [only limit ct] options]
		size: prod sizes
		full: to integer! (length? series) / size
		div: case [
			all [limit only] [min ct full]
			limit [ct] 
			only  [full] 
			true  [round/ceiling/to (length? series) / size 1]
		]
		out: make block! len: length? sizes
		loop len [append/only out copy []]
		repeat idx length? sizes [
			sz: sizes/:idx
			case [
				idx = 1 [block: compose [append/only out/1 copy/part series (sz) series: skip series (sz)]]
				true [block: compose/only [loop (sz) (block) append/only pick out (idx) copy pick out (idx - 1) clear pick out (idx - 1)]]
			]
		]
		loop div block
		out: out/:len
		if not any [only not limit tail? series][append/only out series]
		out
		
	]

	set 'split-r2 func [
		series    [series!]  "Series to split"
		delimiter [default!] "Defines splitting pattern"
		/before
		/after
		/around
		;/at            "Where splitting should occur"
		;	'where     "Can be `before`, `after` or `around`"
		/groups        "Split series into specified groups"
		/limit         "Split limited times"
			 ct [integer!] "Negative numbers - split from tail"
		/only          "Restrict result to match spec exactly"
		/case          "Interpret delimiter literally (case-sensitively)"
		/parse         "Interpret delimiter as parse rule"
	][
		system/words/case [
			all [not case integer? :delimiter] [
				either groups [
					split-into-N-parts/with series delimiter reduce [only limit ct]
				][  split-fixed-parts/with  series delimiter reduce [only limit ct]]
			]
			all [not case integers? :delimiter] [
				either groups [
					split-nested-parts/with series delimiter reduce [only limit ct]
				][  split-var-parts/with    series delimiter reduce [only limit ct]]
			]
			any-function? :delimiter [
					
			]
			parse [
				
			]
			true [
				count: 0
				if all [before after][around: not before: after: false]
				seek: copy [find]
				match: copy 'find/match/tail
				
				system/words/case [
					before [
						if case [
							seek: to path! append seek 'case
							append match 'case 
						]
						comment {;This accepts before/only from the beginning (with first element not starting with delimiter)
						proc: compose/deep [
							;If series does not start with delimiter 
							;try to keep to first delimiter
							if all [
								not (match) series delimiter 
								s1: (seek) series delimiter
								any [not limit ct >= count: count + 1]
							][
								keep/only copy/part series s1
								series: s1
							]
							while [
								;As series should begin with delimiter
								;skip it before searching for next delimiter
								s1: (seek) (match) series delimiter delimiter
							][
								;Break if limit is reached before tail
								all [limit count: count + 1 count > ct break]
								keep/only copy/part series s1
								series: s1
							]
							if all [
								not tail? series 
								any [all [only not limit] not only]
							][
								keep/only series 
								series: tail series 
								;all [limit count: count + 1]
							]
							if all [not only limit count < ct][
								loop ct - count [keep/only copy series]
							]
						]}
						proc: compose/deep [
							;If series does not start with delimiter 
							;try to keep to first delimiter
							if all [
								not (match) series delimiter 
								s1: (seek) series delimiter
							][
								if all [not only any [not limit ct > count: count + 1]][
									keep/only copy/part series s1
								]
								series: s1
							]
							while [
								;As series should begin with delimiter
								;skip it before searching for next delimiter
								s1: (seek) (match) series delimiter delimiter
							][
								;Break if limit is reached before tail
								all [limit count: count + 1 count > ct break]
								keep/only copy/part series s1
								series: s1
							]
							if all [
								not tail? series 
								any [all [only any [not limit count < ct]] not only]
							][
								keep/only series 
								series: tail series 
								;all [limit count: count + 1]
							]
							if all [not only limit count < ct][
								loop ct - count [keep/only copy series]
							]
						]
					]
					after  [
						append seek 'tail
						if case [append seek 'case]
						seek: to path! seek
						proc: compose/deep [
							while [
								s1: (seek) series delimiter
							][
								;Break if limit is reached before tail
								all [limit count: count + 1 count > ct break]
								keep/only copy/part series s1
								;Advance series
								series: s1
							]
							if not any [
								tail? series 
								only
							][
								keep/only series 
								series: tail series 
								;all [limit count: count + 1]
							]
							if all [not only limit count < ct][
								loop ct - count [keep/only copy series]
							]
						]						
					]
					around [
						if case [
							seek: to path! append seek 'case
							append match 'case 
						]
						proc: compose/deep [
							while [
								s1: (seek) series delimiter
							][
								part: copy/part series s1
								if not all [only empty? part][
									;Break if limit is reached before tail
									all [limit count: count + 1 count > ct break]
									keep/only part
								]
								;Advance series behind delimiter
								series: (match) s1 delimiter
								;Keep delimiter
								part: copy/part s1 series
								either single? part [keep part][keep/only part]
							]
							if not only [
								keep/only series 
								series: tail series 
								if all [limit ct > count][
									loop ct - count [keep/only copy series]
								]
							]
						]						
					]
					true   [
						if case [
							seek: to path! append seek 'case
							append match 'case 
						]
						proc: compose/deep [
							while [
								s1: (seek) series delimiter
							][
								part: copy/part series s1
								if not all [only empty? part][
									;Break if limit is reached before tail
									all [limit count: count + 1 count > ct break]
									keep/only part
								]
								;Advance series behind delimiter
								series: (match) s1 delimiter
							]
							if not only [
								keep/only series 
								series: tail series 
								if all [limit ct > count][
									loop ct - count [keep/only copy series]
								]
							]
						]						
					]
				]
				collect proc
			]
		]
	]
]