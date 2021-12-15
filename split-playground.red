Red []
#include %split.red
#include %split-r.red
#include %client-tools.red
context [
	suite: #include %practice-split-suite-1.red
	i: none
	tests: collect [repeat i length? suite [keep rejoin ["Task #" i]]]
	make-rule: function [
		data  "Content from user input field"
		/local fn arg
	][
		compose=: ['compose/deep/only | 'compose/only/deep | 'compose/deep | 'compose/only | 'compose | 'reduce]
		val: data
		case [
			any [word? val get-word? val][get val]
			block? val [
				case [
					parse val [['charset | 'make 'bitset!] set arg [string! | block!]] [
						charset arg
					]
					parse val [set fn compose= set arg [string! | block!]] [
						do compose [(fn) arg]
					]
					'else [val]
				]
			]
			'else [val]
		]
	]

	
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
			foreach-face refs [case [
				face/type = 'check [face/data: false] 
				face/type = 'field [clear face/text]
			]]
			clear dial-call/text
			clear ref-call/text
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
				call: reduce ['split <input>] ;load input-series/text
				call: mold/only either 'charset = first face/data [append call face/data] [append/only call make-rule face/data]
				dialected-result/text: mold result: split load input-series/text make-rule face/data
				dialected-result/color: reduce pick [green red] equal? result selected/goal
				dial-call/text: call
			]
			pad 0x60
			text "Your call:"
			pad 0x-10
			dial-call: text bold 300 ""
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
				call: copy [<input>]
				case [
					find [word! get-word! lit-word! path! get-path! lit-path!] type?/word :delim [append call delim delim: get :delim]
					all [
						block? delim 
						empty? intersect refinements/data [value rule]
						not find/match trim/head face/text #"["
						word? delim/1 
						any-function? get delim/1
					][append call delim delim: do delim]
					'else [append/only call delim]
				]
				refinement-result/text: mold result: either empty? refinements/data [
					insert call 'split
					split-r load input-series/text :delim
				][
					if found: find r-data: copy refinements/data 'limit [lmt: found/2 remove next found]
					insert/only call to-path append copy [split] r-data
					if found [append call lmt]
					split-r/with load input-series/text :delim refinements/data
				]
				ref-call/text: mold/only call
				refinement-result/color: reduce pick [green red] equal? result selected/goal
			]
			return
			refs: panel [
				origin 0x0 
				style ref: check 55 [if face/data [alter refinements/data to-word next face/text]]
				ref "/before"	ref "/first"	ref "/parts"	ref "/rule" 	pad -2x5 text 30 "/limit"
				return
				pad 0x-15
				ref "/after"	ref "/last"		ref "/group"	ref "/value"	pad -2x0
				field 40 hint "limit" on-unfocus [
					either integer? face/data [
						either find refinements/data 'limit [
							put refinements/data 'limit face/data
						][
							append refinements/data compose [limit (face/data)]
						]
					][
						if found: find refinements/data 'limit [remove/part found 2]
					]
					;probe refinements/data
				]
			]
			return
			text "Your call:"
			return
			pad 0x-10
			ref-call: text bold 300 ""
			return
			text "Result:"
			return
			pad 0x-10
			refinement-result: text 300 white font-size 10
		]
		return
		button "Share" [
			tests: load %sessions/2021-12-14-16-0-22.0.txt
			probe send-request/data https://www.toomasv.red/split/receive.php 'PUT 
				to-json collect [keep/only collect [foreach i extract tests/1 2 [keep to-word i]] foreach block tests [keep/only extract/index block 2 2]]
		]
		button "Quit"  [unview]
	]
]