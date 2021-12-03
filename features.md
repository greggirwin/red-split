SPLIT features and examples
===========================

| **Split series ...**             |              **DIALECTED**                |            **REFINEMENTS**            |         **COMMENTS**        |
|----------------------------------|-------------------------------------------|---------------------------------------|-----------------------------|
| into parts with specified length | `split series 10`                         | `split series 10`                     |                             |
|                                  | `split series [every 10]`                 |                                       |                             |
| into variable-length parts       | `split series [2 2 4 -1]`                 | `split series [2 2 4 -1]`             |                             |
| proportionally into N parts      | `split series [into 10]`                  | `split/n series 10`                   |                             |
|                                  | `split series [into 10 parts]`            |                                       |                             |
| at each delimiter eating it      | `split series "1"`                        | `split series "1"`                    |                             |
| after each delimiter             | `split series [after "1"]`                | `split/after series "1"`              |                             |
|                                  | `split series [after (charset "ab")]`     | `split/after series charset "ab"`     |                             |
| before each delimiter            | `split series [before "1"]`               | `split/before series "1"`             |                             |
| once at delimiter                | `split series [once at 'x]`               | `split/first series 'x`               |                             |
|                                  | `split series [at first 'x]`              |                                       |                             |
| once \[before \| after\] ...     | `split series [once before 'x]`           | `split/before/first series 'x`        |                             |
| at \[first \| last\] delimiter   | `split series [first 'x]`                 | `split/first series 'x`               |                             |
|                                  | `split series [at first 'x]`              |                                       |                             |
|                                  | `split series [last (integer!)]`          | `split/last series integer!`          |                             |
| with fuzzy delimiters            | `split series [any space comma]`          | `split/rule series [any space comma]` |                             |
| with alternative delimiters      | `split series ['a \| 'b]`                 | `split/rule series ['a \| 'b]`        |                             |
| by two levels                    | `split series [first by "," then by " "]` | `split/group series [" " ","]`        |                             |
| by raw delimiter                 | `split series [as-delim 3]`               | `split/value series 3`                |                             |
| by function                      | `split series :fn`     (partition)        | `split series :fn`   (split at true)  |                             |
|                                  |                                           |                                       |                             |
| **PROPOSALS / IDEAS**            |                                           |                                       |                             |
| before and after each delimiter  |                                           | `split/around series "1"`             |                             |
| in turn at each delim in block   |                                           | `split/each   series ["1" "2"]`       |                             |
| with fractional steps            |                                           | `split        series 1.5`             |                             |
|                                  |                                           | `split        series 10%`             |                             |
|                                  |                                           | `split        series [2 20% 30%]`     |                             |
| mixed delimiters                 |                                           | `split        series ["1" 1 10]`      |                             |
|                                  |                                           | `split/each   series ["1" 2 "2"]`     |                             |
| from tail                        |                                           | `split/tail   series 3`               |                             |
| limited number of splits         |                                           | `split/limit  series 3 2`             |                             |
| by any number of levels          |                                           | `split/group series [[2 -1 4] 1 3]`   |                             |
|                                  |                                           | `split/group series [sp comma dot]`   |                             |
