Red []

do %split.red

comment {
	split "abc^M^Jde^Mfghi^Jjk" [crlf | #"^M" | newline]]     ["abc" "de" "fghi" "jk"]
	
	split "abc     de fghi  jk" [some #" "]]                  ["abc" "de" "fghi" "jk"]
	
	split "a,b,c^/d,e^/f,g,h,i^/j,k" [by newline then comma (to word!)]  
		[
			[a b c]
			[d e]
			[f g h i]
			[j k]
		]

		
}
