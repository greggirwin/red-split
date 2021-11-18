# Split

Much of this was extracted from %help.txt for %practice-split.red.
Need to update some formatting for MD versus the help system
@toomasv wrote.

Briefly, I worked with @giesse on the design of Rebol's split func, with
the goal of making it dialected, covering many types of splitting. I
started one for Red some time back, taking the idea further. @toomasv
created a refinement-based version for comparison.

The repo also contains an experimental idea for design and learning
(%practice-split.red). A question that's been nagging at me is how we
can do evidence based language design.

---

# Goals and plan

First we need to clear up purpose for the design.

Then we need clear presentation of the alternatives of design.

And finally we should estimate how well do alternative design decisions
serve the stated purpose.

## Purpose of splitting

Abstract-theoretically splitting should enable breaking any series into
chunks according to any criteria appropriate for given series.

Practically it should, according to Red philosophy, make common cases of
splitting easy and all cases possible.

## My (ToomasV's) idea of specifics:

Splitting should occur according to delimiter, which may determine value
on which to split and/or position where to split. Value can be given
literally, by pattern (type, alternatives or sequence or hierarchy of
delimiter values) and dynamically with function. Position can be
determined by size of chunks, number of chunks or dynamically with
function returning next splitting position in series. By default
splitting should break whole series by given delimiter permissively,
i.e. allowing partial matches (reminder/rest) to be included. Further,
partial (aka limited) splitting should be supported, so as to split
limited number of times, still including reminder in result. Finally
restricted splitting should be supported, returning only requested
number of chunks and/or excluding empty chunks, and ignoring reminder.

## Alternative designs

Several specialized functions and dialected split making use of these.
(Currently there are following specialized functions: partition (or
group - IMO it should be separated from this split-bundle), split-into-
N-parts, split-fixed-parts, split-var-parts, split-at-index, split-once,
and split-ctx/split-delimited with refinements.)

Single split with refinements and dialect.

## Evaluation

This will need more playing, and implementation of %practice-split-
r.red.

Specialized functions can probably be implemented more efficiently, but
to be pliable, they should include possibility of limited and restricted
splitting. They also cause a little "explosion" of supportive functions
with long multi-part names.

Single split with refinements avoids explosion of specialized functions,
is more Red-like, but probably less efficient than specialized single-
purpose functions.

---

# Terminology

Defining some terms will help us talk about the design.

Consider these drafts. Particularly in light of the design chat on `at`
vs `skip` and `position` vs `index` in general docs for series related
...positions. 

*Delimiter:* See Separator.

*Dialect:* A domain specific sub-language in the context of a more general language.

*Keyword:* A word with special meaning in a language or dialect.

*Part:* A piece, chunk, segment, slice, or region of a Red series.

*Position:* An offset or index in a Red series. Indexes start at 1, offsets start at 0.

*Rule:* How to split, in general, may be considered a rule, or spec. But there are also `parse` rules.

*Separator:* A value specifying the boundary between separate, independent regions.



# The SPLIT Interface

## Dialected

```
  USAGE:
     SPLIT series dlm

  DESCRIPTION: 
     Split a series into parts, by delimiter, size, number, function, type, 
     or advanced rules. 
     
     SPLIT is a function! value.

  ARGUMENTS:
     series [series!] "The series to split."
     dlm    {Dialected rule (block), part size (integer), predicate (function),
             or separator.}
```

## Refinement based

```
  USAGE:
     SPLIT-R series delimiter

  DESCRIPTION: 
     Split series according to specified delimiter. 
     SPLIT-R is a function! value.

  ARGUMENTS:
     series       [series!] "Series to split."
     delimiter    [default!] "Delimiter on which to split."

  REFINEMENTS:
     /by          => Dummy (default) refinement for compatibility with dialect.
     /before      => Split before the delimiter.
     /after       => Split after the delimiter.
     /at          => Split before and after the delimiter.
     /first       => Split on first delimiter / keep first chunk only.
     /last        => Split on last delimiter / keep last chunk only.
     /tail        => Split starting from tail.
     /groups      => Split series into delimiter-specified groups.
     /each        => Treat each element in block-delimiter individually.
     /limit       => Limit number of splittings / chunks to keep.
        ct           [integer!] 
     /quoted      => Treat delimiter as quoted.
     /only        => Omit empty chunks and rest (i.e. not specified).
     /with        => Add options in block.
        options      [block!] 
     /case        => 
```

# Types of Splitting


<By Delimiter>(#Split By Delimiter)

<At an Offset/Index/Position>(#Split at a Position)

<Into Equal Parts>(#Split Into Equal Parts)

<Into N Parts>(#Split Into N Parts)

<Into Uneven Parts>(#Split Into Uneven Parts)

<Up To N Times>(#Split Up To N Times)

<By Test Predicate(s)>(#Split By Test Predicates)

<Using Advanced Rules>(#Split Using Advanced Rules)


## Split By Delimiter

Delimited data is a well known format, using a <delimiter>(https://en.wikipedia.org/wiki/Delimiter)
to indicate where one thing stops and the next thing starts. 

This is the most widely used form of splitting. And many languages have
a *split* function. They also almost all follow a fixed pattern with
regard to their spec: *split \[string delimiter opt limit\]*  I have a
hard time believing that the *limit* feature is /so/ widely useful that
it's there on merit. Everybody just copied what came before. Or they
say to use regexes. Some langs also added a refinement to omit empty
results.

What this model lacks is /any other/ useful feature, like splitting at
only the first or last occurrence of the separator. Or /including/ the
separator in the result. For example, you want to split /after/ *:*, 
keeping it with the left part; or split /before/ uppercase characters,
keeping them with the right part. Rust adds some variants, with the
result of having 13 different *split\** functions.

Most telling, for Red, is that other langs only consider strings as
the input and characters (sometimes strings), as the separator. This
makes sense, but is <short-sighted>(#FutureThought) for Red.


## Split Once

Split just once, giving two parts. The data may be marked by a 
delimiting value, or by the size of the either the first or last
part.

## Split Into Equal Parts

Use cases:

*Splitting a large file:* Each part should be no more than N bytes or
may be a dataset where each record is a fixed size. Of course this use
case has limits, and a stream based approach, reading and writing each
part in sequence should be used for very large files.

*Breaking work up:* When data has the potential to cause processing
errors, it can be helpful to work on smaller parts of the data, both
for error handling and user interactions. This is especially true when
cumulative errors or resource constraints come into play.

Design questions:

If the input can't be split evenly, should only the last item be
shorter, or should the last two items be "leveled" so they are as 
close in size as possible? If the part of the data is odd in length,
they still won't be exactly even.

Only last shorter: [gregg]
leveled:           []


## Split Into N Parts

Use cases:

*Distributing work:* You have N workers and want to give each a part of
the data to work on.

*Secure Fragments:* Each part is useless, and can't be decrypted, without
all the others.

Design questions:

https://gitter.im/red/split?at=618909abd78911028a27db26

If the input can't be split evenly, should only the last item be
longer, or should entire result be "leveled" so the parts are as 
close in size as possible?

Only last longer: []
leveled:          [gregg]



## Split Into Uneven Parts

*Small Fixed Values:* _YYYYMMDD_ into _\[YYYY MM DD\]_, or 
_Mon, 24 Nov 1997_ into \["Mon" "24" "Nov" "1997"\].

*Tabular Data:* The much-maligned, but still useful, flat file.

*Schema Based Data:* A schema\/header tells you the size of each part in
a payload.

*Historical Data:* Legacy formats are often based on fixed size fields.

Design questions:

Should the rule be applied only once, or repeatedly across the
entire series?

once:   []
repeat: [toomas gregg boris jose galen]


## Split Up To N Times

When you want to split more than once, but less than every time. This
can be useful if you want to check individual parts, and not split
any more than necessary once you find what you want. Or when there's
more than one "header" part but a trailing payload that may contain
separators.

This is a refinement to other splitting options, for how many times
to apply them. It is not a standalone algorithm.


## Split by Test Predicates

Partition data into groups based on one or more tests.

*Data Analysis:* How many of a particular type of data occur, relative
to others? What are the min\/max or average values for all the numeric
items (first you have to find them)?

*Specialize Processing:* Break data up into groups of small and large
values, or by type, so you can send each to a specific handler.


Design questions:

### Name

NAME: [
    partition []
    group     []
    filter    []
]

## Should it be accessible via the `split` entry point or completely
separate?

part of split: [gregg]
separate:      []

### Should predicates be treated by as group filters or delimiters?

group: [gregg]
delim: [toomas]

### Example

    split [1 a 2 b 3 c] :number?
    ;== [[1 2 3] [a b c]]
    split [1 a 2 b 3 c] [:even? :odd?]
    ;== [[2] [1 3] [a b c]]

Or

    split [1 a 2 b 3 c] :number?
    ;== [[] [a] [b] [c]]]
    split [1 a 2 3 b 4 c] [:even? :odd?]
    ;== [[1 a] [b 4 c]]
    split/group [1 a 2 3 b 4 c] [:even? :odd?]
    ;== [[] [[a] []] [[b] [c]]]
    split/group "a,b.c,d." [comma dot]
    ;== [["a" "b"] ["c" "d"] []]

### Should predicate funcs take one or two args (value or [value series])?

This same question applies to the `map` HOF, which Gregg has done
experimentally with multiple args.

one: []
two: []


## Split Using Advanced Rules

Think *parse+collect*.

Literal values (TBD)

Full parse support, or just a subset (TBD, e.g. actions set/get-words)

https://gitter.im/red/split?at=6186752fa41fd206992955bb (chat about
how much power user have, the risk of things blowing up on them, and
how much flexibility is needed.)

https://gitter.im/red/split?at=618832c5cd4972068b93b1c4



## 2D splitting and splitting images


## Group runs, monotonic split.

Collect items into groups based on the change in values in the series
or matching of a predicate function per Toomas' idea of binary (arity 2)
funcs that know the series position and can compare to that, rather than
strictly an independent value.

Use Cases:

Run length encoding.

Gregg said: On char-change splitting, I consider this a special case,
outside split (group-runs). I think it was @GalenIvanov I chatted to
about it recently, noting that it can be used for RLE (Run Length
Encoding). In Red we can do that at the value level, not just byte
level.

## Split out matching prefix



# Confidence Ratings

Each function is given confidence ratings, based on its design and
implementation. Overall confidence is their average.

A baseline confidence of 8/10 means a function is good enough to be
included in a release. Notes about other reasons to exclude functions
may also be made. For example, a function may be good enough technically
but its purpose doesn't justify inclusion. Inclusion also doesn't mean
the function is design or code complete, just that it's good enough for
comment, even if changes are pending based on existing discussion.

The goal here is to help prioritize work and do an initial release of
some functionality for user feedback and testing.


|         Function         | Design | Code | Purpose | Overall | Notes |
|--------------------------|--------|------|---------|---------|-------|
| Split (dialected)        | ?/10   | ?/10 | ?/10    | ?/10    |       |
| split-r                  | ?/10   | ?/10 | ?/10    | ?/10    |       |
| split-r-v2               | ?/10   | ?/10 | ?/10    | ?/10    |       |
| split-r-v3               | ?/10   | ?/10 | ?/10    | ?/10    |       |
|                          |        |      |         |         |       |
| split-into-N-parts       | ?/10   | ?/10 | ?/10    | ?/10    |       |
| split-fixed-parts        | ?/10   | ?/10 | ?/10    | ?/10    |       |
| split-var-parts          | ?/10   | ?/10 | ?/10    | ?/10    |       |
| split-at-index           | ?/10   | ?/10 | ?/10    | ?/10    |       |
| split-once               | ?/10   | ?/10 | ?/10    | ?/10    |       |
| split-deliimited         | ?/10   | ?/10 | ?/10    | ?/10    |       |
| partition/group          | ?/10   | ?/10 | ?/10    | ?/10    | HOF `filter` |
| split-image              | ?/10   | ?/10 | ?/10    | ?/10    |       |
| 2D data split            | ?/10   | ?/10 | ?/10    | ?/10    |       |
|                          |        |      |         |         |       |
|                          |        |      |         |         |       |
|                          |        |      |         |         |       |
|                          |        |      |         |         |       |

# Priorities

Prior. = Priority for inclusion  
Uses = Use cases (should list if using a number of examples)  
Purpose and Overall may be removed here

Not all options apply to all splitting types. For example, `case` and
`around` make no sense for size-based/offset-based splitting. `Reverse`
with `last` is just a confusing way to express a sensible default of
splitting at the first.

`Once` is technically a special case of `N Times` but may 

|         Option           | Prior. | Uses | Purpose | Overall | Notes |
|--------------------------|--------|------|---------|---------|-------|
| Delimited                | [tv 1] |      |         |         |       |
| N Parts                  | [tv 3] |      |         |         |       |
| Fixed Parts              | [tv 2] |      |         |         |       |
| Variable Sized Parts     | [tv 2] |      |         |         |       |
| At Index                 |        |      |         |         | [tv: /limit .. 1] |
| Once                     |        |      |         |         | [tv: /trim/limit .. 1] |
| N Times (Limit)          | [tv 2] |      |         |         |       |
| Parse Rule               | [tv 3] |      |         |         |       |
| Partition/Group          |        |      |         |         | [tv: should be different func] |
| split-image              |        |      |         |         |       |
| 2D data split            |        |      |         |         |       |
|                          |        |      |         |         |       |
|                          |        |      |         |         |       |
|                          |        |      |         |         |       |
|                          |        |      |         |         |       |
| case sensitive           | [tv 3] |      |         |         |       |
| before                   | [tv 2] |      |         |         |       |
| after                    | [tv 2] |      |         |         |       |
| keep delim (around)      | [tv 3] |      |         |         |       |
| first                    |        |      |         |         | Default, with `last` overriding [tv: /limit .. 1] |
| last                     |        |      |         |         | [tv: /limit .. -1] |
| Nth                      |        |      |         |         | [tv: last split/limit .. n] |
| reverse/tail             | [tv 4] |      |         |         |       |
| only                     |        |      |         |         | [tv: in what meaning - treat arg as block?] |
| quoted/as-delim          |        |      |         |         | [tv: /quoted is meaningful only for parse-based; /as-is is alias for /case; /case, /before, /after, /around imply as-is  for nums] |
| each                     | [tv 2] |      |         |         | [tv: if meant as - interpret block as alternatives] |
| keep empty values        | [tv 3] |      |         |         |       |
| Nested (2 levels)        | [tv 2] |      |         |         |       |
| Nested (> 2 levels)      | [tv 4] |      |         |         |       |
|                          |        |      |         |         |       |
|                          |        |      |         |         |       |
|                          |        |      |         |         |       |
|                          |        |      |         |         |       |


-----------------------------------------------------------------------

# General Design Thoughts

## Always filter?

> Isn't filtering always a part of splitting

No. Breaking data at markers, losslessly is an important use case. The
simple example in strings is a PascalCaseName broken at uppercase
letters, or dialects like draw where you could break at keywords.

## Example for expression splitting

(ToomasV) Something like this to split code into expressions:

    expression: [s: [
      set-word! expression 
      | [word! | path!] if (all [i: info-ctx/get-info :s/1 a: i/arity]) a expression 
      | skip
      ] opt [o: word! if (op? attempt [get/any o/1]) expression]
    ]
    expressions: function [element series][parse series [expression e:] :e]
    exs:  split-r/after body-of :split :expressions

    >> exs/1
    == [
        =num: =once: =mod: =ord: =pos: =dlm: =ct: =char-word: none
    ]
    >> exs/2
    == [
        =sub-rule: none
    ]
    >> exs/3
    == [
        split-rule: [
            (=num: =once: =mod: =ord: =pos: =dlm: =ct: =char-word: =sub-rule: no...



## Should splitting always preserve order? 

General consensus is YES, with splitting into groups and regrouping being
outside `split's` scope. `Split` is the opposite of `join`.

Gregg said:

I think order should be preserved, both for reconstructive purposes
(e.g. split on one dlm and rejoin with another), but also for reasoning.
That is, a completely random result order would be hard to compare to
sources, to see if your splitting rules are being applied as expected.
Grouping can preserve relative order within a group, but can't do more
than that.

@GalenIvanov raises an interesting point about preserving delimiters in
cases where they would normally be removed. Splitting and rejoining
makes the second step like merge (sometimes called zip) of two series.
But what are the use cases, and are they common enough to be a feature
(split is already heavily loaded). Or is a general callback approach
worth supporting. So far I've thought about fixed inputs, and of limited
size. But large inputs and streams should be considered, and aligns with
HOFs, aggregates, and FRP models.

Preserving delimiters also only works in cases where the delimiter is,
itself, a value. That narrows the use cases. And if we account for
before/after already retaining the delimiter, it narrows further.

## Treating values as literal delimiters, rather than sizes, predicates,
or rules.

Quoting in general.

https://gitter.im/red/split?at=6186b8ab9d20982e4f04b5f7


## Misc

Gregg's thoughts on dialect vs refinements. https://gitter.im/red/split?at=6186c5167db1e3753e863ba6

More from Gregg: https://gitter.im/red/split?at=61969e2263c1e83c9516fa70



