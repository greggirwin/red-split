Red [
    Title: "split-image"
    Author: "Galen Ivanov"    
]

context [
    split-side: func [
        size [integer!]
        step [integer!]
        /local parts
    ][
        either step > size [
           reduce [size]
        ][
            parts: make block! n: to-integer size / step
            append/dup parts step n
            total: sum parts
            if positive? rem: size - total [append parts rem]
            parts
        ]    
    ]
    
    fix-sizes: func [
        size  [integer!]
        steps [block!]  
        /local parts
    ][
        parts: make block! 10
        total: 0
        forall steps [
            append parts steps/1
            total: total + absolute steps/1
            if total >= size [break]
        ]
        either positive? rem: size - total [
            append parts rem
        ][
            change back tail parts rem + last parts
        ]
        parts
    ]
    
    init-side: func [
        size  [integer!]
        parts [integer! block!]
    ][
        either integer? parts [split-side size parts][fix-sizes size parts]
    ]

    init-grid: func [
        size [pair!]
        x-sz [integer! block!]
        y-sz [integer! block!]
    ][
        xs: init-side size/x x-sz
        ys: init-side size/y y-sz
        reduce [xs ys]
    ]
    
    set 'split-image function [
        img  [image!]
        x-sz [integer! block!]
        y-sz [integer! block!]
    ][
        res: init-grid img/size x-sz y-sz
        xs: res/1
        ys: res/2
        y-offs: 0
        
        collect [
            foreach y ys [
                if positive? y [
                    x-offs: 0
                    foreach x xs [
                        if positive? x [
                            keep draw/transparent as-pair x y compose [
                                image (img) crop (as-pair x-offs y-offs) (as-pair x-offs + x y-offs + y)
                            ]
                        ]
                        x-offs: x-offs + absolute x
                    ]
                ]    
                y-offs: y-offs + absolute y
            ]
        ]
    ]
]
