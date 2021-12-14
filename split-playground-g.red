Red [
    Title:  "Comprative playground for splitting functins in Red"
    Author: "Galen Ivanov"
    Notes:  "Based on code by Toomas Vooglaid and Gregg Irwin"
    status: "WIP"
]

#include %split.red
#include %split-r.red

play: context [
    
    suite: #include %practice-split-suite-1.red
    len: length? suite
    tests: collect [repeat i len [keep rejoin ["Task #" i]]]
    status: copy ""
    
    over-dial: off
    over-ref: off
    prompt: "Enter the delimiter and press <Enter> to split"
    
    cur-task: 1
  
    task-stats: make object! [
        id: #00
        desc: ""
        input: none
        goal: none
        hint: ""
        time: none                 ; not yet implemented
        dial-status: 'unattempted  ; [unattempted | wrong | correct]
        dial-solution: none        ; stores the last correct solution  
        dial-tries: copy []
        ref-status: 'unattempted
        ref-tries: copy []
        ref-solution: none          ; stores the last correct solution   
        refinements: copy []        ; stores the refinements for the correct solution
        notes: ""
        rating: 0                   ; task rating 1 - 10
        dialected-rating: 0         ; 1 - 10
        refinement-rating: 0        ; 1 - 10
        
    ] 
    
    tasks: collect [foreach task suite [keep/only to-block make task-stats task]]
    
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
            "Time: " t/time
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
                on-over [does-on-over face (n)]
                on-down [load-task (n)]
            ]
        ]    
    ]
    
    task-boxes: collect [
        repeat n len [
            left: to-set-word rejoin ["Stat-d-" n]  ; dialected
            right: to-set-word rejoin ["Stat-r-" n] ; refinement-based
            keep compose/deep [
                (left)  task-status on-over [does-on-over face (n)] pad -6x0 
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
    
    load-task: func [n /local t][
        t: suite/:n
        id/text: rejoin ["Task " form t/id]
        input-text/text: mold t/input
        goal-text/text: mold t/goal
        cur-task: n
        clear refinement-delimiter/text
        clear dialected-result/text
        clear refinement-result/text
        clear dialected-delimiter/text
        clear refinement-delimiter/text
        if sol: tasks/:n/dial-solution [dialected-delimiter/text: copy sol]
        if sol: tasks/:n/ref-solution  [refinement-delimiter/text: copy sol]
        dialected-result/color: (linen - 10.10.10)
        refinement-result/color: (linen - 10.10.10)
        update-stars "star" tasks/:n/rating
        update-stars "star-d" tasks/:n/dialected-rating
        update-stars "star-r" tasks/:n/refinement-rating
        set-ref-checkboxes n
    ]
    
    ;probe task-boxes
    
    make-filename: does [
        t: now
        unless exists? %sessions [make-dir %sessions]
        rejoin [%sessions/ t/year "-" t/month "-" t/day "-" t/hour "-" t/minute "-" t/second ".txt"]
    ]

    stars: make-stars "star" 'star "rating"
    stars-d: make-stars "star-d" 'star2 "dialected-rating"
    stars-r: make-stars "star-r" 'star2 "refinement-rating"
    
    view compose [
        title "Compare dialected and refinement-based split"
        backdrop linen
        
        on-create [load-task 1]
        
        style task: button 32x32 data off
        style task-status: base 15x4 white data off
        style lbl: text 430x25 font-color black font-size 11
        style dark: text 430x25 (linen - 10.10.10) font-color black font-size 12
        style fld: field 430x30 (linen + 20.20.20) font-color black font-size 12 data off
        style star: base 28x28 linen "☆" font-size 23 font-color gold
        style star2: base 25x25 linen "☆" font-size 20 font-color gold
        
        below
        across (task-buttons) return
        pad 0x-5 across (task-boxes) return
        across
        id: text "Task 01" font-size 20 font-color black
        pad 0x5 (stars) return
        pad 0x-10
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
        pad 0x-10
        across
        panel linen [  ; Dialected
            below        
            lbl  "Please specify appropriate delimiter for dialected split:"
            pad 0x-10 across
            dialected-delimiter: fld [
                local [result correct? rule]
                if word? rule: face/data [rule: get rule]
                result: try [split load input-text/text rule]
                dialected-result/text: either error? result [
                    "Unknown rule"    
                ][
                    mold result
                ]
                append tasks/:cur-task/dial-tries now
                append/only tasks/:cur-task/dial-tries to-block face/data
                correct?: equal? result suite/:cur-task/goal
                dialected-result/color: reduce pick [(green - 5.15.10) brick] correct?
                either correct? [
                    info-text/text: "Correct!"
                    tasks/:cur-task/dial-status: 'correct
                    tasks/:cur-task/dial-solution: mold face/data
                    set to-path reduce [to-word rejoin ["Stat-d-" cur-task] 'color] green
                ][
                    unless tasks/:cur-task/dial-status = 'correct [
                        set to-path reduce [to-word rejoin ["Stat-d-" cur-task] 'color] red
                    ]    
                ]
                correct?: false
                
            ]
            on-over [info-text/text: either over-dial: not over-dial [prompt][""]]
            return below
            panel 400x50 linen [
                ; to be updated
                text "[before | after | first | last | once | times | into | any | as-delim | first by then by]"
            ]
            dialected-result: dark
        ]
        panel linen[  ; Refinemets
            below
            at 0x0 refinements: field hidden data []
            lbl "Please specify delimiter and select appropriate refinements:"
            pad 0x-10 across
            refinement-delimiter: fld [
                local [result correct?]
                delim: face/data
                case [
                    find [word! get-word!] type?/word :delim [delim: get :delim]
                    all [
                        block? delim 
                        empty? intersect refinements/data [value rule];before after
                        not find/match trim/head face/text #"["
                        word? delim/1 
                        any-function? get delim/1
                    ][delim: do delim]
                ]
                result: try [
                    either empty? refinements/data [
                        split-r load input-text/text :delim
                    ][
                        split-r/with load input-text/text :delim refinements/data
                    ]
                ]    
                refinement-result/text: either error? result [
                    "Unknown rule"    
                ][
                    mold result
                ]
                append tasks/:cur-task/ref-tries now
                append/only tasks/:cur-task/ref-tries reduce [face/data copy refinements/data]
                
                correct?: equal? result suite/:cur-task/goal
                refinement-result/color: reduce pick [(green - 5.15.10) brick] correct?
                either correct? [
                    info-text/text: "Correct!"
                    tasks/:cur-task/ref-status: 'correct
                    tasks/:cur-task/ref-solution: mold face/data
                    tasks/:cur-task/refinements: copy refinements/data
                    set to-path reduce [to-word rejoin ["Stat-r-" cur-task] 'color] green
                ][
                    unless tasks/:cur-task/ref-status = 'correct [
                        set to-path reduce [to-word rejoin ["Stat-r-" cur-task] 'color] red
                    ]    
                ]
            ]
            
            on-over [info-text/text: either over-ref: not over-ref [prompt][""]]

            return below
            refs: panel linen [
                origin 0x0 
                style ref: check 65  [alter refinements/data to-word next face/text]
                ref "/before"    ref "/first"    ref "/parts"    ref "/rule"     pad -2x5 text 30 "/limit"
                return
                pad 0x-15
                ref "/after"    ref "/last"        ref "/group"    ref "/value"    pad -2x0
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
            ]
            refinement-result: dark
        ]    
        return
        pad 0x-20 text "Preferences" font-size 18 font-color black 
        return
        text 100x20 "Dialected" pad 0x-10 (stars-d)
        return text "Refinement-based" pad 0x-10 (stars-r)
        pad 450x0 button "Save" [write make-filename mold tasks]
        return
        info-text: text 900x18 (linen - 10.10.10) "" font-color black font-size 10
    ]
]