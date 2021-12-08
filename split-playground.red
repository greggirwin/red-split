Red []
#include %split.red
#include %split-r.red
context [
	suite: #include %practice-split-suite-1.red
	i: none
	tests: collect [repeat i length? suite [keep rejoin ["Task #" i]]]
	view [
		title "Compare dialected and refinement-based split"
		text "Please select a splitting task:"
		return
		pad 0x-10
		drop-down 620 font-size 10 data tests on-change [
			selected: suite/(face/selected)
			input-series/text: mold selected/input
			expected-result/text: mold selected/goal
			clear dialected-delimiter/text
			clear dialected-result/text
			dialected-result/color: white
			clear refinement-delimiter/text
			clear refinement-result/text
			refinement-result/color: white
			clear refinements/data
			foreach-face refs [face/data: false]
		]
		return
		text 300 "Input series:"
		pad 10x0
		text 300 "Expected result:"
		return
		pad 0x-10
		input-series:    text 300 white font-size 10 ;input to split
		pad 10x0
		expected-result: text 300 white font-size 10 ;expected result
		return pad -10x0
		panel [ ;Gregg's
			below
			text 300x30 wrap "Please specify appropriate delimiter for dialected split:"
			dialected-delimiter: field 300 font-size 10 [  ;delim DSL
				local [result]
				dialected-result/text: mold result: split load input-series/text face/data
				dialected-result/color: reduce pick [leaf brick] equal? result selected/goal
			]
			pad 0x60
			text "Result:"
			pad 0x-10
			dialected-result: text  300 white font-size 10
		]
		pad -10x0
		panel [ ;Toomas'
			text 300x30 wrap "Please specify delimiter and select appropriate refinements:"
			return
			at 0x0 refinements: field hidden data []
			refinement-delimiter: field 300 font-size 10 [
				local [result]
				;probe type? 
				delim: face/data
				case [
					find [word! get-word!] type?/word :delim [delim: get :delim]
					all [
						block? delim 
						empty? intersect refinements/data [before after value rule]
						not find/match trim/head face/text #"["
						word? delim/1 
						any-function? get delim/1
					][delim: do delim]
				]
				refinement-result/text: mold result: either empty? refinements/data [
					split-r load input-series/text :delim
				][
					split-r/with load input-series/text :delim refinements/data
				]
				refinement-result/color: reduce pick [green red] equal? result selected/goal
			]
			return
			refs: panel [
				origin 0x0 
				style ref: check 70 [if face/data [alter refinements/data to-word next face/text]]
				ref "/before"	ref "/first"	ref "/parts"	ref "/rule"
				return
				pad 0x-10
				ref "/after"	ref "/last"		ref "/group"	ref "/value"
			]
			return
			text "Result:"
			return
			pad 0x-10
			refinement-result: text 300 white font-size 10
		]
		return
		button "Quit" [unview]
	]
]