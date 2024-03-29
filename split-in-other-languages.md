# Split in some programming languages

<table>
    <tr><th>Language</th><th>Functions / Methods</th></tr>
    <tr><th colspan="2"><a href="https://doc.rust-lang.org/stable/std/primitive.str.html#method.split">Rust</a></th></tr>
    <tr><td>.split(pat)</td><td>An iterator over substrings of this string slice, separated by characters matched by a pattern.
The pattern can be a &str, char, a slice of chars, or a function or closure that determines if a character matches.</td></tr>
    <tr><td>.split_terminator(pat)</td><td>Equivalent to split, except that the trailing substring is skipped if empty.
This method can be used for string data that is terminated, rather than separated by a pattern.</td></tr>
    <tr><td>.splitn(n, pat)</td><td>... restricted to returning at most n items...</td></tr>
    <tr><td>.split_once(delim)</td><td>Splits the string on the first occurrence of the specified delimiter and returns prefix before delimiter and suffix after delimiter.</td></tr>
    <tr><td>.split_inclusive(pat)</td><td>... leaves the matched part as the terminator of the substring...</td></tr>
    <tr><td>.split_ascii_whitespace()</td><td>Splits a string slice by ASCII whitespace.
The iterator returned will return string slices that are sub-slices of the original string slice, separated by any amount of ASCII whitespace.</td></tr>
    <tr><td>.split_whitespace()</td><td>... ‘Whitespace’ is defined according to the terms of the Unicode Derived Core Property White_Space.</td></tr>
    <tr><td>.split_at(mid)</td><td>Divide one string slice into two at an index.
The argument, mid, should be a byte offset from the start of the string. It must also be on the boundary of a UTF-8 code point.
The two slices returned go from the start of the string slice to mid, and from mid to the end of the string slice.</td></tr>
    <tr><td>.split_at_mut(mid)</td><td>Divide one mutable string slice into two at an index...</td></tr>
    <tr><td>.rsplit(pat)</td><td>... yielded in reverse order...</td></tr>
    <tr><td>.rsplit_terminator(pat)</td><td></td></tr>
    <tr><td>.rsplitn(n, pat)</td><td>... starting from the end of the string, restricted to returning at most n items.</td></tr>
    <tr><td>.rsplit_once(delim)</td><td>Splits the string on the last occurrence of the specified delimiter...</td></tr>
    <tr><th colspan="2"><a href="https://docs.python.org/3.10/genindex-S.html">Python</a></th></tr>
    <tr><td>split([separator [maxsplit]])</td><td><p>Return a list of the words in the string, using sep as the delimiter string. If maxsplit is given, at most maxsplit splits are done (thus, the list will have at most maxsplit+1 elements). If maxsplit is not specified or -1, then there is no limit on the number of splits (all possible splits are made).</p><p>If sep is given, consecutive delimiters are not grouped together and are deemed to delimit empty strings (for example, '1,,2'.split(',') returns ['1', '', '2']). The sep argument may consist of multiple characters (for example, '1<>2<>3'.split('<>') returns ['1', '2', '3']). Splitting an empty string with a specified separator returns [''].</p><p>If sep is not specified or is None, a different splitting algorithm is applied: runs of consecutive whitespace are regarded as a single separator, and the result will contain no empty strings at the start or end if the string has leading or trailing whitespace. Consequently, splitting an empty string or a string consisting of just whitespace with a None separator returns [].</p></td></tr>
    <tr><td>rsplit([separator [maxsplit]])</td><td>Except for splitting from the right, rsplit() behaves like split().</td></tr>
    <tr><td>splitlines([keepends])</td><td><p>Return a list of the lines in the string, breaking at line boundaries. Line breaks are not included in the resulting list unless keepends is given and true.</p><p>Unlike split() when a delimiter string sep is given, this method returns an empty list for the empty string, and a terminal line break does not result in an extra line:</p></td></tr>
    <tr><td>bytes.split(sep=None, maxsplit=- 1)</td><td><p>Split the binary sequence into subsequences of the same type, using sep as the delimiter string. If maxsplit is given and non-negative, at most maxsplit splits are done (thus, the list will have at most maxsplit+1 elements). If maxsplit is not specified or is -1, then there is no limit on the number of splits (all possible splits are made).</p><p>If sep is given, consecutive delimiters are not grouped together and are deemed to delimit empty subsequences (for example, b'1,,2'.split(b',') returns [b'1', b'', b'2']). The sep argument may consist of a multibyte sequence (for example, b'1<>2<>3'.split(b'<>') returns [b'1', b'2', b'3']). Splitting an empty sequence with a specified separator returns [b''] or [bytearray(b'')] depending on the type of object being split. The sep argument may be any bytes-like object.</p></td></tr>
    <tr><td>bytearray.split(sep=None, maxsplit=- 1)</td><td>^...</td></tr>
    <tr><td>bytes.rsplit(sep=None, maxsplit=- 1)</td><td>Except for splitting from the right, rsplit() behaves like split().</td></tr>
    <tr><td>bytearray.rsplit(sep=None, maxsplit=- 1)</td><td>^...</td></tr>
    <tr><th colspan="2"><a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/split">JavaScript</a>, <a href="https://tc39.es/ecma262/multipage/text-processing.html#sec-string.prototype.split">ECMAScript</a></th></tr>
    <tr><td>split([separator [limit]])</td><td>Divides a String into an ordered list of substrings, puts these substrings into an array, and returns the array.  The division is done by searching for a pattern; where the pattern is provided as the first parameter in the method's call. When found, separator is removed from the string, and the substrings are returned in an array. If separator is a regular expression with capturing parentheses, then each time separator matches, the results (including any undefined results) of the capturing parentheses are spliced into the output array. If the separator is an array, then that Array is coerced to a String and used as a separator. </td></tr>
    <tr><th colspan="2"><a href="https://pkg.go.dev/strings@go1.17.3">Go</a></th></tr>
    <tr><td>Split(s, sep)</td><td>Slices s into all substrings separated by sep and returns a slice of the substrings between those separators.
If s does not contain sep and sep is not empty, Split returns a slice of length 1 whose only element is s.
If sep is empty, Split splits after each UTF-8 sequence. If both s and sep are empty, Split returns an empty slice.
It is equivalent to SplitN with a count of -1. </td></tr>
    <tr><td>SplitN(s, sep, n)</td><td>Slices s into substrings separated by sep and returns a slice of the substrings between those separators.
The count determines the number of substrings to return</td></tr>
    <tr><td>SplitAfter(s, sep)</td><td>Slices s into all substrings after each instance of sep and returns a slice of those substrings.
If s does not contain sep and sep is not empty, SplitAfter returns a slice of length 1 whose only element is s.
If sep is empty, SplitAfter splits after each UTF-8 sequence. If both s and sep are empty, SplitAfter returns an empty slice.
It is equivalent to SplitAfterN with a count of -1. </td></tr>
    <tr><td>SplitAfterN(s, sep, n)</td><td>Slices s into substrings after each instance of sep and returns a slice of those substrings.
The count determines the number of substrings to return</td></tr>
    <tr><td>Fields(s)</td><td>Splits the string s around each instance of one or more consecutive white space characters, as defined by unicode.IsSpace, returning a slice of substrings of s or an empty slice if s contains only white space. </td></tr>
    <tr><td>FieldsFunc(s, f)</td><td>Splits the string s at each run of Unicode code points c satisfying f(c) and returns an array of slices of s. If all code points in s satisfy f(c) or the string is empty, an empty slice is returned.
FieldsFunc makes no guarantees about the order in which it calls f(c) and assumes that f always returns the same value for a given c. </td></tr>
    <tr><td>re.split(s, n)</td><td>Slices s into substrings separated by the expression and returns a slice of the substrings between those expression matches.
The slice returned by this method consists of all the substrings of s not contained in the slice returned by FindAllString. When called on an expression that contains no metacharacters, it is equivalent to strings.SplitN. </td></tr>
    <tr><th colspan="2"><a href="https://search.wolfram.com/?query=split&source=GUIHeader">Wolfram</a></th></tr>
    <tr><td>StringSplit["string"]</td><td>Splits "string" into a list of substrings separated by whitespace.</td></tr>
    <tr><td>StringSplit["string",patt]</td><td>Splits into substrings separated by delimiters matching the string expression patt.</td></tr>
    <tr><td>StringSplit["string",{p1,p2,…}]</td><td>Splits at any of the p(i).</td></tr>
    <tr><td>StringSplit["string",patt->val]</td><td>Inserts val at the position of each delimiter.</td></tr>
    <tr><td>StringSplit["string",{p1->v1,…}]</td><td>Inserts v(i) at the position of each delimiter p(i).</td></tr>
    <tr><td>StringSplit["string",patt,n]</td><td>Splits into at most n substrings.</td></tr>
    <tr><td>StringSplit[{s1,s2,…},p]</td><td>Gives the list of results for each of the s(i).</td></tr>
    <tr><td>SplitBy[list,f]</td><td>Splits list into sublists consisting of runs of successive elements that give the same value when f is applied.</td></tr>
    <tr><td>SplitBy[list,{f1,f2,…}]</td><td>Recursively splits list into sublists by testing elements successively with each of the f(i).</td></tr>
    <tr><td colspan=2>Notes:<br />
        SplitBy[list,…] <i>splits but does not rearrange list.</i><br />
        SplitBy <i>performs comparisons only on adjacent pairs of elements.</i><br />
        SplitBy[list] <i>is equivalent to SplitBy[list,Identity], which is also equivalent to Split[list].</i><br />
        SplitBy[list,{f1,f2}] <i>is equivalent to Map[SplitBy[#,f2]&,SplitBy[list,f1]].</i></td></tr>
    <tr><td>Split[list]</td><td>Splits list into sublists consisting of runs of identical elements.</td></tr>
    <tr><td>Split[list,test]</td><td>Treats pairs of adjacent elements as identical whenever applying the function test to them yields True.</td></tr>
    <tr><td>SequenceSplit[list,patt]</td><td>Splits list into sublists separated by sequences that match the sequence pattern patt. By default gives the list of sublists of list that occur between sequences defined by patt; it does not include the sequences themselves.</td></tr>
    <tr><td>SequenceSplit[list,patt->rhs]</td><td>Inserts rhs at the position of each matched sequence.</td></tr>
    <tr><td>SequenceSplit[list,{patt1->rhs1,…}]</td><td>Inserts rhs(i) at the position of each patt(i). (SequenceSplit[list,{patt(1)->rhs(1),…,patt(a),…}] includes rhs(i) at the position of sequences matching patt(1) but omits sequences matching patt(a).)</td></tr>
    <tr><td>SequenceSplit[list,patt,n]</td><td>Splits into at most n sublists.</td></tr>
    <tr><td>ResourceFunction["StringSplitAfter"]["string"]</td><td>Splits "string" into a list of substrings after each whitespace.</td></tr>
    <tr><td>ResourceFunction["StringSplitAfter"]["string",patt]</td><td>Splits "string" into substrings after delimiters matching the string expression patt.</td></tr>
    <tr><td>ResourceFunction["StringSplitAfter"]["string",{p1,p2,…}]</td><td>Splits "string" after any of the p(i).</td></tr>
    <tr><td>ResourceFunction["StringSplitAfter"]["string",patt->val]</td><td>Replaces each delimiter matching patt with val.</td></tr>
    <tr><td>ResourceFunction["StringSplitAfter"]["string",{p1->v1,…}]</td><td>Replaces each delimiter matching p(i) with v(i).</td></tr>
    <tr><td>ResourceFunction["StringSplitAfter"][{s1,s2,…},p]</td><td>Gives the list of results for each of the s(i).</td></tr>
    <tr><td>ResourceFunction["StringSplitBefore"]["string"]</td><td>Splits "string" into a list of substrings before each whitespace.</td></tr>
    <tr><td>ResourceFunction["StringSplitBefore"]["string",patt]</td><td>Splits "string" into substrings before delimiters matching the string expression patt.</td></tr>
    <tr><td>ResourceFunction["StringSplitBefore"]["string",{p1,p2,…}]</td><td>Splits "string" before any of the p(i).</td></tr>
    <tr><td>ResourceFunction["StringSplitBefore"]["string",patt->val]</td><td>Replaces each delimiter matching patt with val.</td></tr>
    <tr><td>ResourceFunction["StringSplitBefore"]["string",{p1->v1,…}]</td><td>Replaces each delimiter matching p(i) with v(i).</td></tr>
    <tr><td>ResourceFunction["StringSplitBefore"][{s1,s2,…},p]</td><td>Gives the list of results for each of the s(i).</td></tr>
    <tr><td>ResourceFunction["SplitWhen"][list,f]</td><td>Splits list into sublists, splitting after each ei for which f[ei] is True.</td></tr>
    <tr><td>ResourceFunction["SplitByPatterns"][list,{patt1,patt2,…}]</td><td>Splits list into sublists consisting of runs of successive elements that match the same patti.</td></tr>
    <tr><td>ResourceFunction["RandomSplit"][list,n]</td><td>Randomly cuts list into n segments.</td></tr>
    <tr><td>ResourceFunction["RandomSplit"][n]</td><td>Represents an operator form of ResourceFunction["RandomSplit"] that can be applied to an expression.</td></tr>
    <tr><td>ResourceFunction["TrainTestSplit"][data]</td><td>Splits data into a pair of shuffled training and testing sets.</td></tr>
    <tr><td>VideoSplit, AudioSplit, ImageSplitCompare...</td><td></td></tr>
    <tr><th colspan="2"><a href="https://docs.microsoft.com/en-us/dotnet/api/system.string.split?view=net-5.0">.NET</a></th></tr>
    <tr><td>Split(Char, Int32, StringSplitOptions)</td><td>Splits a string into a maximum number of substrings based on a specified delimiting character and, optionally, options. Splits a string into a maximum number of substrings based on the provided character separator, optionally omitting empty substrings from the result.</td></tr>
    <tr><td>Split(String[], Int32, StringSplitOptions)</td><td>Splits a string into a maximum number of substrings based on specified delimiting strings and, optionally, options.</td></tr>
    <tr><td>Split(Char[], Int32, StringSplitOptions)</td><td>Splits a string into a maximum number of substrings based on specified delimiting characters and, optionally, options.</td></tr>
    <tr><td>Split(String[], StringSplitOptions)</td><td>Splits a string into substrings based on a specified delimiting string and, optionally, options.</td></tr>
    <tr><td>Split(String, Int32, StringSplitOptions)</td><td>Splits a string into a maximum number of substrings based on a specified delimiting string and, optionally, options.</td></tr>
    <tr><td>Split(Char[], StringSplitOptions)</td><td>Splits a string into substrings based on specified delimiting characters and options.</td></tr>
    <tr><td>Split(Char[], Int32)</td><td>Splits a string into a maximum number of substrings based on specified delimiting characters.</td></tr>
    <tr><td>Split(Char, StringSplitOptions)</td><td>Splits a string into substrings based on a specified delimiting character and, optionally, options.</td></tr>
    <tr><td>Split(String, StringSplitOptions)</td><td>Splits a string into substrings that are based on the provided string separator.</td></tr>
    <tr><td>Split(Char[])</td><td>Splits a string into substrings based on specified delimiting characters.</td></tr>
    <tr><td colspan=2>See also: https://docs.microsoft.com/en-us/dotnet/api/system.stringsplitoptions?view=net-5.0</td></tr>
    <tr><th colspan="2"><a href="https://docs.oracle.com/javase/7/docs/api/java/lang/String.html">Java</a></th></tr>
    <tr><td>split(String regex)</td><td>Splits this string around matches of the given regular expression.</td></tr>
    <tr><td>split(String regex, int limit)</td><td>Splits this string around matches of the given regular expression.</td></tr>
    <tr><th colspan="2"><a href="https://docs.racket-lang.org/reference/pairs.html#%28def._%28%28lib._racket%2Flist..rkt%29._splitf-at">Racket</a></th></tr>
    <tr><td>(split-at lst pos) → list? any/c </br> lst : any/c </br> pos : exact-nonnegative-integer?</td><td>Splits a list at position.</br> Returns the same result as (values (take lst pos) (drop lst pos))</br>except that it can be faster, but it will still take time proportional to pos.</td></tr>
    <tr><td>(splitf-at lst pred) → list? any/c</br>lst : any/c</br> pred : procedure?
</td><td> Splits a list by predicate.</br>Returns the same result as (values (takef lst pred) (dropf lst pred)) except that it can be faster.</td></tr>
    <tr><td>(split-at-right lst pos) → list? any/c</br>lst : any/c</br>pos : exact-nonnegative-integer?
</td><td> Splits a list at position from the end.</br>Returns the same result as (values (drop-right lst pos) (take-right lst pos)) except that it can be faster, but it will still take time proportional to the length of lst.
</td></tr>
    <tr><td>(splitf-at-right lst pred) → list? any/c</br>lst : any/c</br>pred : procedure?
</td><td> Like takef, dropf, and splitf-at, but combined with the from-right functionality of take-right, drop-right, and split-at-right.
</td></tr>
    <tr><td>(split-common-prefix l r [same?]) → list? list? list?</br>l : list?</br>r : list?</br>same? : (any/c any/c . -> . any/c) = equal?
</td><td> Returns the longest common prefix together with the tails of l and r with the common prefix removed.</br>Example:</br>(split-common-prefix '(a b c d) '(a b x y z))</br>'(a b)</br>'(c d)</br>'(x y z)
</td></tr>
</table>

See also:

- [Haskell](https://hackage.haskell.org/package/split-0.2.3.4/docs/Data-List-Split.html)
