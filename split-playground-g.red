Red [
    Title:  "Comparative playground for splitting functions in Red"
    Author: "Galen Ivanov"
    Notes:  "Based on code by Toomas Vooglaid and Gregg Irwin"
]

#include %split.red
#include %split-r.red
#include %help.red

play: context [

    suite: #include %practice-split-suite-1.red
    tasks: make block! 50
    len: length? suite
    over-dial: off
    over-ref: off
    prompt: "Enter the delimiter and press <Enter> to split"
    color-right: 60.230.120
    color-wrong: brick + 50.70.40
    session-file: none
    
    tabs: [dialected-delimiter dialected-btn refinement-delimiter refinement-btn
           c1 c2 c3 c4 c5 c6 c7 c8 lmt dialected-delimiter]
           
    clrs: [unattempted: white correct: color-right incorrect: color-wrong]
    clrs-b: [unattempted: (linen - 10.10.10) correct: color-right incorrect: color-wrong]
    
    cur-task: 1
  
    task-stats: make object! [
        id: #00
        desc: ""                   ; not used
        input: none
        goal: none
        hint: ""                   ; not used
        dial-status: 'unattempted  ; [unattempted | wrong | correct]
        dial-solution: ""        ; stores the last correct solution  
        dial-tries: copy []
        ref-status: 'unattempted
        ref-tries: copy []
        ref-solution: ""          ; stores the last correct solution   
        refinements: copy []        ; stores the refinements for the correct solution
        notes: ""
        difficulty: 0                   ; task rating 1 - 10
        importance: 0
        dialected-rating: 0         ; 1 - 10
        refinement-rating: 0        ; 1 - 10
    ] 
    
     init-tasks: does [collect [foreach task suite [keep/only to-block make task-stats task]]]
    
    update-status: func [
        n [number!] {Task number}
        /local t
    ][
        t: pick tasks n
        rejoin [
            t/id space
            mold t/input " -> "
            mold t/goal space
            "Dialected: " t/dial-status space
            "Refinements: " t/ref-status space
        ]
    ]
    
    does-on-over: func [face n][    
        face/data: not face/data
        info-text/text: either face/data [update-status n][""]
    ]
    
    task-buttons: collect [ 
        repeat n len [
            keep compose/deep [
                task (form n)
                [load-task (n) set-focus dialected-delimiter]
                on-over [does-on-over face (n)]
            ]
        ]    
    ]
    
    task-boxes: collect [
        repeat n len [
            left: to-set-word rejoin ["Stat-d-" n]  ; dialected
            right: to-set-word rejoin ["Stat-r-" n] ; refinement-based
            keep compose/deep [
                (left)  task-status on-over [does-on-over face (n)] pad -3x0 
                (right) task-status on-over [does-on-over face (n)] 
            ]
        ]
    ]

    star-callback: func [
        name
        n
        field
    ][
        update-stars name n
        tasks/:cur-task/(to-word field): n
    ]
    
    make-stars: func [
        name [string!]
        type [word!]
        field 
    ][
        collect [
            keep [pad 0x-15] 
            repeat n 10 [
                keep to-set-word rejoin [name "-" n]
                keep type
                keep/only compose [star-callback (name) (n) (field)]
                keep compose/deep [
                    on-over [
                        face/data: not face/data
                        info-text/text: either face/data [
                            rejoin ["Rate this task " (n)]
                        ][""]
                    ]
                ]
            keep [pad -8x0]
            ]
        ]    
    ]
    
   
    update-stars: func [name n][
        repeat i n [
            set to-path reduce [to-word rejoin [name "-" i] 'text] "★"
        ]
        repeat k 10 - n [
            set to-path reduce [to-word rejoin [name "-" k + n] 'text] "☆" 
        ]
    ]
    
    set-ref-checkboxes: func [n][
        clear refinements/data
        foreach-face refs [
            case  [ 
                face/type = 'check [
                    if face/data: to-logic find tasks/:n/refinements w: to-word face/text [
                       append refinements/data w
                ]
                ]
                face/type = 'field [
                    p: find tasks/:n/refinements 'limit
                    either p [face/text: form p/2 append refinements/data copy/part p 2][clear face/text]
                ]
            ]
        ]
    ]
    
    update-task-stats: does [
        repeat n length? tasks [
            left: to-path  reduce [to-word rejoin ["Stat-d-" n] 'color]  ; dialected
            right: to-path reduce [to-word rejoin ["Stat-r-" n] 'color]  ; refinement-based
            set left  do select clrs tasks/:n/dial-status
            set right do select clrs tasks/:n/ref-status
        ]
    ]
    
    load-task: func [n /local t][
        t: suite/:n
        id/text: rejoin ["Task " form t/id]
        input-text/text: mold t/input
        goal-text/text: mold t/goal
        cur-task: n
        clear dialected-delimiter/text
        clear dialected-result/text
        clear dialected-call/text
        clear refinement-delimiter/text
        clear refinement-result/text
        clear refinement-call/text
        clear task-notes/text
        task-notes/text: copy tasks/:n/notes
        dialected-result/color: do select clrs-b tasks/:n/dial-status
        refinement-result/color: do select clrs-b tasks/:n/ref-status
        
        set-ref-checkboxes n
        
        sol: dialected-delimiter/text: switch tasks/:n/dial-status [
            correct  [tasks/:n/dial-solution]
            incorrect [last tasks/:n/dial-tries]
        ]
        unless empty? sol [check-dialected dialected-delimiter]
        
        sol: refinement-delimiter/text: switch tasks/:n/ref-status [
            correct  [tasks/:n/ref-solution]
            incorrect [probe form first load last tasks/:n/ref-tries]
        ]
        unless empty? sol [check-refinements refinement-delimiter]

        update-stars "star" tasks/:n/difficulty
        update-stars "importance" tasks/:n/importance
        update-stars "star-d" tasks/:n/dialected-rating
        update-stars "star-r" tasks/:n/refinement-rating
    ]
        
    make-filename: does [
        t: now
        rejoin [t/year "-" t/month "-" t/day "-" t/hour "-" t/minute "-" t/second]
    ]
    
    make-rule: function [
    data  "Content from user input field"
    /local fn arg
    ][
        compose=: [
            'compose/deep/only | 'compose/only/deep | 'compose/deep | 'compose/only | 'compose
            | 'reduce
        ]
        val: data
        case [
            any [word? val get-word? val][get val]
            block? val [
                case [
                    parse val [['charset | 'make 'bitset!] set arg [string! | block!]] [
                        charset arg
                    ]
                    ; compose or reduce
                    parse val [set fn compose= set arg [string! | block!]] [
                        do compose [(fn) arg]
                    ]
                    'else [
                        val
                    ]
                ]
            ]
            'else [        ; char! integer! string!
                val
            ]
        ]
    ]
    
    check-dialected: func [
        face
        /local result correct? rule
    ][   

        call: reduce ['split <input>]
        ;append/only call make-rule face/text
        append/only call face/data
        dialected-call/text: mold/only call
        
        if error? set/any 'err try [
            result: mold split load input-text/text make-rule face/data
            dialected-result/data: result 
        ][
            dialected-result/data: "I don't understand that. Maybe try reduce/compose."
            print mold err
        ]
        
        append tasks/:cur-task/dial-tries now
        append tasks/:cur-task/dial-tries append copy [] mold face/data
        correct?: equal? load result suite/:cur-task/goal
        dialected-result/color: reduce pick [color-right color-wrong] correct?
        either correct? [
            info-text/text: "Correct!"
            tasks/:cur-task/dial-status: 'correct
            tasks/:cur-task/dial-solution: copy face/text
            set to-path reduce [to-word rejoin ["Stat-d-" cur-task] 'color] color-right
        ][
            unless tasks/:cur-task/dial-status = 'correct [
                set to-path reduce [to-word rejoin ["Stat-d-" cur-task] 'color] color-wrong
                tasks/:cur-task/dial-status: 'incorrect
            ]    
        ]
    ]
    
    check-refinements: func [
        face
        /local result correct? 
    ][
        call: copy [<input>]
        delim: face/data
        either  error? set/any 'err try [
            do mold delim
        ][
            refinement-result/data: "I don't understand that."
            print mold err
        ][
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
            refinement-result/text: result: mold either empty? refinements/data [
                insert call 'split
                split-r load input-text/text :delim
            ][
                if found: find r-data: copy refinements/data 'limit [lmt: found/2 remove next found]
                insert/only call to-path append copy [split] r-data
                if found [append call lmt]
                split-r/with load input-text/text :delim refinements/data
            ]
            refinement-call/text: mold/only call
            append tasks/:cur-task/ref-tries now
            append/only tasks/:cur-task/ref-tries mold reduce [face/data copy refinements/data]
            
            correct?: equal? load result suite/:cur-task/goal
            refinement-result/color: reduce pick [color-right color-wrong] correct?
            either correct? [
                info-text/text: "Correct!"
                tasks/:cur-task/ref-status: 'correct
                tasks/:cur-task/ref-solution: copy face/text
                tasks/:cur-task/refinements: copy refinements/data
                set to-path reduce [to-word rejoin ["Stat-r-" cur-task] 'color] color-right
            ][
                unless tasks/:cur-task/ref-status = 'correct [
                    set to-path reduce [to-word rejoin ["Stat-r-" cur-task] 'color] color-wrong
                    tasks/:cur-task/ref-status: 'incorrect
                ]    
            ]    
        ]    
    ]
    
    move-focus: func [face][set-focus get select tabs face]
    
    difficulty: make-stars "star" 'star2 "difficulty"
    importance: make-stars "importance" 'star2 "importance"
    stars-d: make-stars "star-d" 'star2 "dialected-rating"
    stars-r: make-stars "star-r" 'star2 "refinement-rating"
    
    confirm: has [answer][
        answer: false
        view/no-wait/flags [
            Title "Save changes?"
            below
            text "Do you want to save the current session?"
            across
            button "Yes" [answer: true unview]
            button "No" [answer: false unview]
            
        ][modal no-min no-max]
        do-events
        answer
    ]
    
    load-session: does [
        if session-file: request-file/file %sessions/ [
            if exists? session-file [tasks: reduce load session-file]
            update-task-stats
            load-task 1
            info-text/text: form session-file
        ]
    ]
    
    save-session: does [
        write session-file mold tasks
        info-text/text: form rejoin [session-file " was saved"]
    ]
    
    start-session: does [
        tasks: init-tasks
        session-file: rejoin [
            %sessions/practice-split-
            make-filename
            %.red
        ]
    ]
    
    new-session: does [
        start-session
        update-task-stats
        load-task 1
    ]
    
; -------------------------------------------------
    start-session
; ------------------------------------------------
    
    view compose [
        title "Compare dialected and refinement-based split"
        backdrop linen
        
        on-create [
            load-task 1
            info-text/text: rejoin ["Session: " copy/part session-file find session-file dot]
            set-focus dialected-delimiter
        ]
        
        style task: button 30x30 data off
        style task-status: base 15x3 white data off
        style lbl: text 375x25 font-color black font-size 11
        style dark: text 360x25 (linen - 10.10.10) font-color black font-size 12
        style dark-short: text 310x25 (linen - 10.10.10) font-color black font-size 10
        style label: text 55 font-size 10 font-color black
        style fld: field 320x25 (linen + 20.20.20) font-color black font-size 10 data off
        style btn: button 35x25 
        style question: text 320x25 font-color black font-size 10
        style star: base 28x28 linen "☆" font-size 23 font-color gold
        style star2: base 25x25 linen "☆" font-size 20 font-color gold
        
        below
        across space 5x5 (task-buttons) return
        across (task-boxes) return
        across
        id: text "Task 01" font-size 15 font-color black
        return pad 0x-10
        across
        panel linen [
            below
            lbl "Here is your input:"
            pad 0x-10            
            input-text: dark
        ]
        panel linen[
            below
            lbl "Your goal is to get this result:"
            pad 0x-10
            goal-text: dark
        ]    
        return
        pad 0x-15
        below
        across
        panel linen [  ; Dialected
            below        
            lbl  "Please specify appropriate delimiter for dialected split:"
            pad 0x-10 across
            dialected-delimiter: fld [check-dialected face]
            on-over [info-text/text: either over-dial: not over-dial [prompt][""]]
            on-key-down [if event/key = tab [move-focus 'dialected-delimiter]]
            dialected-btn: btn "Split" [check-dialected dialected-delimiter]
            on-key-down [if event/key = tab [move-focus 'dialected-btn]]
            return below
            panel 375x50 linen [
                text 350x50 "[before | after | first | last | once | times | into | as-delim | first by then by]"
                font-size 10 font-color black
            ]
            across label "Your call:" 
            dialected-call: dark-short "" return
            across label "Result"
            dialected-result: dark-short
        ]  
        
        panel linen[  ; Refinemets
            below
            at 0x0 refinements: field hidden data []
            lbl "Please specify delimiter and select appropriate refinements:"
            pad 0x-10 across
            refinement-delimiter: fld [check-refinements face]
            on-over [info-text/text: either over-dial: not over-dial [prompt][""]]
            on-key-down [if event/key = tab [move-focus 'refinement-delimiter]]
            refinement-btn: btn "Split" [check-refinements refinement-delimiter]
            on-key-down [if event/key = tab [move-focus 'refinement-btn]]

            return below
            refs: panel linen [
                origin 0x0 
                style ref: check 70 [alter refinements/data to-word next face/text]
                c1: ref "/before" on-key-down [if event/key = tab [move-focus 'c1]]
                c3: ref "/first"  on-key-down [if event/key = tab [move-focus 'c3]]
                c5: ref "/parts"  on-key-down [if event/key = tab [move-focus 'c5]]
                c7: ref "/rule"   on-key-down [if event/key = tab [move-focus 'c7]]
                pad -2x5 text 30 "/limit"
                return
                pad 0x-15
                c2: ref "/after"  on-key-down [if event/key = tab [move-focus 'c2]]
                c4: ref "/last"   on-key-down [if event/key = tab [move-focus 'c4]]
                c6: ref "/group"  on-key-down [if event/key = tab [move-focus 'c6]]
                c8: ref "/value"  on-key-down [if event/key = tab [move-focus 'c8]] pad -2x0
                lmt: field 40 hint "limit" on-unfocus [
                    either integer? face/data [
                        either find refinements/data 'limit [
                            put refinements/data 'limit face/data
                        ][
                            append refinements/data compose [limit (face/data)]
                        ]
                    ][
                        if found: find refinements/data 'limit [remove/part found 2]
                    ]
                ]
                on-key-down [if event/key = tab [move-focus 'lmt]]
            ]
            across label "Your call:"
            refinement-call: dark-short "" return
            across label "Result"
            refinement-result: dark-short
            
        ] return
        
        question "How convenient was the dialected solution?" pad 85x0
        question "How convenient was the refinement-based solution?" return 
        (stars-d) pad 190x15 (stars-r)  return
        question "How hard was this task?"
        pad 90x0 question "Please write down your comments on this task:" return 
        (difficulty) return
        question "How important is this usecase?" return 
        (importance)
        pad 190x-35 task-notes: area 360x70 (linen + 20.20.20)
        on-unfocus [tasks/:cur-task/notes: copy face/text]
        return
        pad 410x0
        button "Help" [show-help]
        pad 100x0
        button "New"  [if confirm [save-session] new-session]
        button "Load" [if confirm [save-session] load-session]
        button "Save" [save-session]
        return
        info-text: text 775x18 (linen - 10.10.10) "" font-color black font-size 10
    ]
]
