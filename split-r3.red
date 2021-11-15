Red []
context [
    before:            func [s item][find any [find/match/tail s item  s] item]
    before-case:       func [s item][find/case any [find/match/tail/case s item  s] item]
    before-only:       func [s item][find/only any [find/match/tail/only s item  s] item]
    before-case-only:  func [s item][find/case/only any [find/match/tail/case/only s item  s] item]
    after:             func [s item][find/tail s item]
    after-case:        func [s item][find/tail/case s item]
    after-only:        func [s item][find/tail/only s item]
    after-case-only:   func [s item][find/tail/case/only s item]
    around:            func [s item][any [find/match/tail s item  find s item]]
    around-case:       func [s item][any [find/case/match/tail s item  find/case s item]]
    around-only:       func [s item][any [find/only/match/tail s item  find/only s item]]
    around-case-case:  func [s item][any [find/case/only/match/tail s item  find/case/only s item]]
    default:           func [s item][find s item]
    default-case:      func [s item][find/case s item]
    default-only:      func [s item][find/only s item]
    default-case-only: func [s item][find/case/only s item]
    trim: false
    split-n: function [s n] [
        r: make block! n  
        part: (length? e: s) / n  
        repeat i round/ceiling n [
	    chunk: copy/part e e: skip s round/ceiling/to part * i 1
            if not all [trim empty? chunk] [append/only r chunk]
        ] r
    ]

    set 'split function [
        series [series!]
        delim  [default!]
        /before
        /after
        /around
        /groups
        /case
	/only
	/trim
	/limit ct
    ][
	self/trim: trim
        find-next: system/words/case [
            before [system/words/case [
		all [case only] [:self/before-case-only] case [:self/before-case] only [:self/before-only] true [:self/before]]
	    ] 
            after  [system/words/case [
		all [case only] [:self/after-case-only] case [:self/after-case] only [:self/after-only] true [:self/after]]
	    ] 
            around [system/words/case [
		all [case only] [:self/around-case-only] case [:self/around-case] only [:self/around-only] true [:self/around]]
	    ] 
            num?: all [number? :delim not case] [
                len: length? series
                unless groups [
                    if percent? delim [delim: len * delim]
                    delim: len / delim
                ]
                :split-n
            ]
            default: true [system/words/case [
		all [case only] [:self/default-case-only] case [:self/default-case] only [:self/default-only] true [:self/default]]
	    ]
        ]
        system/words/case [
            num? [find-next series 1.0 * delim]
            true [
                s: series
		find-match: system/words/case [
		    all [case only] [[find/case/only/match/tail s delim]]
		    case [[find/case/match/tail s delim]]
		    only [[find/only/match/tail s delim]]
		    true [[find/match/tail s delim]]
		]
		looper: either limit [reduce ['loop ct]]['until]
		proc: compose/deep [
                    (looper) [
			not if s: find-next s delim [
			    if not all [empty? chunk: copy/part series s trim][
				keep/only chunk
			    ]
			    if default [s: (find-match)]
			    series: s
			]
                    ]
                    if all [not all [tail? series trim] any [default not tail? series]][keep/only series]
                ]
		collect proc
            ]
        ]
    ]
]
