Red [
    Title:  "Comparative playground for splitting functions in Red"
    Author: "Galen Ivanov"
    Notes:  "Based on code by Toomas Vooglaid and Gregg Irwin"
    Needs:  view
    Icon:   %split-lab.ico
]

#include %split.red
#include %split-r.red
help-new: #include %help-new.txt
help-dia: #include %help-dialect.txt
help-ref: #include %help-refinement.txt
#include %help.red


play: context [

    suite: copy orig-suite: #include %practice-split-suite-2.red
    tasks: make block! 50
    len: length? suite
    
	over-dial: 
    over-ref: 
	over-mode:
	over-new: 
	over-load: off 
	
	color-right: 60.230.120
    color-wrong: brick + 50.70.40
    session-file: none
    default-dir: none
    mode: 'predefined   ; or 'sandbox
    
	prompt: "Enter the delimiter and press <Enter> to split"
	mode-prompt: [
	    predefined: "Switch to sandbox mode to play with your own test cases"
		sandbox: "Switch to predefined tasks mode"
	]
	new-prompt: [
	    predefined: "Start a new predefined session"
		sandbox: "Start a new sandbox session"
	]
	load-prompt: [
	    predefined: "Load an existing predefined session"
		sandbox: "Load an existing sandbox session"
	]
	
    
    
    tabs: [dialected-delimiter dialected-btn refinement-delimiter 
           c1 c2 c3 c4 c5 c6 c7 c8 lmt refinement-btn dialected-delimiter
           task-notes help-btn new-btn load-btn save-btn dialected-delimiter]
           
    clrs:  [unattempted: white correct: color-right incorrect: color-wrong]
    clrs-b: [unattempted: (linen - 10.10.10) correct: color-right incorrect: color-wrong]
    
    cur-task: 1
  
    task-stats: make object! [
        id: #00
        desc: ""                   ; not used
        input: ""
        goal: ""
        hint: ""                   ; not used
        dial-status: 'unattempted  ; [unattempted | wrong | correct]
        dial-solution: ""          ; stores the last correct solution  
        dial-tries: []
        ref-status: 'unattempted
        ref-tries: []
        ref-solution: ""           ; stores the last correct solution   
        refinements: []            ; stores the refinements for the correct solution
        notes: ""
        difficulty: 0              ; task rating 1 - 10
        importance: 0
        dialected-rating: 0        ; 1 - 10
        refinement-rating: 0       ; 1 - 10
        category: ""               ; not used 
    ] 
    
    init-tasks: does [
        suite: switch mode [
            predefined [orig-suite]
            sandbox [collect [loop 21 [keep/only copy []]]]
        ]

        t: collect [
            foreach task suite [
                keep/only to-block make task-stats task
            ]
        ]
        
        if mode = 'sandbox [      
            n: 0 
            forall t [t/1/id: n: n + 1]  ; enumerate the custom tasks
        ]
        t
    ]
    
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
            keep [pad 0x-13] 
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
        
        checks: switch tasks/:n/ref-status [
            correct     [tasks/:n/refinements]
            incorrect   [last load last tasks/:n/ref-tries]
            unattepmted [copy []]
        ]
        
        foreach-face refs [
            case  [ 
                face/type = 'check [
                    if face/data: to-logic find checks w: to-word face/text [
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
    
    load-task: func [n /local t sol][
        t: tasks/:n
        id/text: rejoin ["Task " form n]
        if mode = 'sandbox [insert id/text "Custom "]
        clear input-text/text
        unless empty? txt: t/input [input-text/text: mold txt]
        clear goal-text/text
        unless empty? txt: t/goal [goal-text/text: mold txt]
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
            correct   [copy tasks/:n/dial-solution]
            incorrect [copy last tasks/:n/dial-tries]
        ]
        
        unless empty? sol [check-dialected dialected-delimiter]
        
        sol: refinement-delimiter/text: switch tasks/:n/ref-status [
            correct   [copy tasks/:n/ref-solution]
            incorrect [mold first load last tasks/:n/ref-tries]
        ]
        unless empty? sol [check-refinements refinement-delimiter]

        update-stars "star" tasks/:n/difficulty
        update-stars "importance" tasks/:n/importance
        update-stars "star-d" tasks/:n/dialected-rating
        update-stars "star-r" tasks/:n/refinement-rating
    ]
    
    prev-task: does [
        cur-task: cur-task - 1
        if zero? cur-task [cur-task: len]
        load-task cur-task
    ]
    
    next-task: does [
        cur-task: cur-task % len + 1
        load-task cur-task
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
        /local result correct? unknown
    ][   
        unknown: false   
        call: reduce ['split <input>]
        append/only call face/data
        dialected-call/text: mold/only call
        
        tsk: tasks/:cur-task
        if mode = 'sandbox [
            tsk/input: load input-text/text
            tsk/goal: load goal-text/text
        ]
        
        if error? set/any 'err try [
            result: mold split load input-text/text make-rule face/data
            dialected-result/text: result 
        ][
            dialected-result/text: "I don't understand that. Maybe try reduce/compose."
            unknown: true
        ]
        
        repend tsk/dial-tries [now copy face/text]
        correct?: equal? result mold load goal-text/text
        dialected-result/color: reduce pick [color-right color-wrong] correct?
        either correct? [
            info-text/text: "Correct!"
            tsk/dial-status: 'correct
            tsk/dial-solution: copy face/text
            set to-path reduce [to-word rejoin ["Stat-d-" cur-task] 'color] color-right
        ][
            info-text/text: either unknown ["Error"]["Wrong!"]
            unless tsk/dial-status = 'correct [
                set to-path reduce [to-word rejoin ["Stat-d-" cur-task] 'color] color-wrong
                tsk/dial-status: 'incorrect
            ]    
        ]
    ]
    
    check-refinements: func [
        face
        /local result correct? 
    ][
        
        call: copy [<input>]
        delim: face/data
        tsk: tasks/:cur-task
        if mode = 'sandbox [
            tsk/input: load input-text/text
            tsk/goal: load goal-text/text
        ]
        
        ;either error? set/any 'err try [do mold delim][
        ;    refinement-result/data: "I don't understand that."
        ;    info-text/text: "Error"
        ;    refinement-call/text: mold/only call
        ;    refinement-result/color: color-wrong
        ;    append tsk/ref-tries now
        ;    append/only tsk/ref-tries mold reduce [face/data copy refinements/data]
        ;    unless tsk/ref-status = 'correct [
        ;        set to-path reduce [to-word rejoin ["Stat-r-" cur-task] 'color] color-wrong
        ;        tsk/ref-status: 'incorrect
        ;    ]
        ;    if found: find r-data: copy refinements/data 'limit [lmt: found/2 remove next found]
        ;    insert/only call to-path append copy [split] r-data
        ;    if found [append call lmt]
        ;    refinement-call/text: mold/only call
        ;    ;print mold err
        ;][
            case [
                find [word! get-word! path! get-path!] type?/word :delim [append call delim delim: get :delim]
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
            append tsk/ref-tries now
            append/only tsk/ref-tries mold reduce [face/data copy refinements/data]

            correct?: equal? result mold load goal-text/text
            refinement-result/color: reduce pick [color-right color-wrong] correct?
            either correct? [
                info-text/text: "Correct!"
                tsk/ref-status: 'correct
                tsk/ref-solution: copy face/text
                tsk/refinements: copy refinements/data
                set to-path reduce [to-word rejoin ["Stat-r-" cur-task] 'color] color-right
            ][
                info-text/text: "Wrong!"
                unless tsk/ref-status = 'correct [
                    set to-path reduce [to-word rejoin ["Stat-r-" cur-task] 'color] color-wrong
                    tsk/ref-status: 'incorrect
                ]    
            ]
        ;]    
    ]
    
    move-focus: func [face][set-focus get select tabs face]  ; naive tab support
        
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
            button "No"  [answer: false unview]
            
        ][modal no-min no-max]
        do-events
        answer
    ]
    
    make-filename: does [
        t: now
        rejoin [t/year "-" t/month "-" t/day "-" t/hour "-" t/minute "-" to-integer t/second]
    ]
    
    load-session: func [
        /latest /local files
    ][
        default-dir: select [predefined: %sessions/ sandbox: %custom-sessions/] mode
      
        session-file: either latest [
            files: sort/reverse read default-dir
            unless empty? files [
                while [
                    all [
                        not find/match files/1 "practice-split-"
                        not tail? files
                    ]
                ][
                    files: next files
                ]
                if files [rejoin [default-dir files/1]]            
            ]    
            
        ][
            request-file/file default-dir
        ]

        either session-file [
            either exists? session-file [
                tasks: reduce load session-file
                ; check the format
                either empty? difference extract tasks/1 2 words-of task-stats [
                    update-task-stats
                    info-text/text: form session-file
                    load-task 1
                ][
                    alert "Invalid format! Starting a new session."
                    start-session
                ]    
            ][
                start-session
            ]    
        ][
            start-session
        ]
    ]
    
    save-session: does [
        dirize session-file
        write session-file mold tasks
        info-text/text: form rejoin [session-file " was saved"]
    ]
    
    start-session: does [
        tasks: init-tasks
        update-task-stats
        session-file: rejoin [   
            normalize-dir default-dir
            'practice-split-
            make-filename
            %.red
        ]
    ]
    
    new-session: does [
        start-session
        update-task-stats
        load-task 1
    ]
    
    switch-modes: does [
        if confirm [save-session]
        switch mode [
            predefined [
                mode: 'sandbox
                mode-btn/text: "Predefined mode"
                input-text/enabled?: true
                input-text/color: (linen + 20.20.20)
                goal-text/enabled?: true
                goal-text/color: (linen + 20.20.20)
                id/text: "Custom task 01"
                make-dir %custom-sessions/
                load-session/latest
            ]
            sandbox [
                mode: 'predefined
                mode-btn/text: "Sandbox mode"
                input-text/enabled?: false
                input-text/color: (linen - 5.5.5)
                goal-text/enabled: false
                goal-text/color: (linen - 5.5.5)
                id/text: "Task 01"
                load-session/latest
            ]
        ]
    ]
    
   ;print "start" 
    
    view/options compose [
        title "Compare dialected and refinement-based split"
        backdrop linen
        
        style task: button 30x30 data off
        style task-status: base 15x3 white data off
        style lbl: text 375 font-color black font-size 10
        style dark: field 360 (linen - 5.5.5) disabled font-color black font-size 12
        style dark-short: field 310 (linen - 5.5.5) font-color black font-size 10
        style label: text 55 font-size 10 font-color black
        style fld: field 320 (linen + 20.20.20) font-color black font-size 10 data off
        style hlp: button 80X35
        style btn: button 35 
        style question: text 320 font-color black font-size 10
        style star: base 28x28 linen "☆" font-size 23 font-color gold
        style star2: base 25x25 linen "☆" font-size 20 font-color gold
        
        below
        across space 5x5 (task-buttons) return
        across (task-boxes) return
        across
        id: text 200 "Task 01" font-size 15 font-color black
        pad 470x5 
        mode-btn: button "Sandbox mode" [switch-modes]
		on-over [info-text/text: either over-mode: not over-mode [select mode-prompt mode][""]]
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
            on-over [info-text/text: either over-ref: not over-ref [prompt][""]]
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
                c8: ref "/value"  on-key-down [if event/key = tab [move-focus 'c8]] 
                pad -2x0
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
        pad 190x-35 task-notes: area 370x70 (linen + 20.20.20)
        on-unfocus [tasks/:cur-task/notes: copy face/text]
        return
        
        hlp "General Help" [show-help/with help-new];%help-new.txt]
        hlp "Dialect notes" [show-help/with help-dia];%help-dialect.txt]
        hlp "Refinements notes" [show-help/with help-ref];%help-refinement.txt]
        
        pad 390x10
        new-btn:  button "New"  [if confirm [save-session] new-session]
		on-over [info-text/text: either over-new: not over-new [select new-prompt mode][""]]
        load-btn: button "Load" [if confirm [save-session] load-session]
		on-over [info-text/text: either over-load: not over-load [select load-prompt mode][""]]
        on-create [load-task 1]  
        return
        info-text: text 775x18 (linen - 10.10.10) "" font-color black font-size 10
    ][
        text: "Practice Split"

        actors: make object! [
            on-create: function [face event] [
                make-dir %sessions/
                either last sort read %sessions/ [load-session/latest][start-session]
                info-text/text: rejoin ["Session: " copy/part session-file find session-file dot]
                set-focus dialected-delimiter
            ]
                
            on-close: function [face event] [save-session]
            on-key: function [face event] [
                switch event/key [
                    F1  [show-help/with help-new];%help-new.txt]
                    F2  [show-help/with help-dia];%help-dialect.txt]
                    F3  [show-help/with help-ref];%help-refinement.txt]
                    page-up    [prev-task]
                    page-down  [next-task]
                ]
            ]
        ]
   ]
]
