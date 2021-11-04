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
    
    get-channel-data: function [
        data    [binary!]
        size    [pair!]
        x-sz    [block!]
        y-sz    [block!]
        channel [word!]
    ][
        offs: select [rgb: 3 alpha: 1] channel
        img-data: make block! (length? xs) * (length? ys) * offs
        
        forall ys [
            either 1 > ys/1 [ 
                data: at data offs * ys/1 * w ; skip the negative spans
            ][
                n: 0
                foreach x xs [              ; just prepare blocks to be used for images
                    if positive? x [
                        append/only img-data reduce [as-pair x ys/1 copy #{}]
                        n: n + 1
                    ]
                ]
                loop ys/1 [                 ; for each row in the current span
                    k: negate n
                    foreach x xs [          ; fill the blocks with data
                        if positive? x [
                            append last first at tail img-data k copy/part data offs * x
                            k: k + 1
                        ]
                        data: next at data offs * absolute x
                    ]    
                ]
            ]    
        ]
        img-data
    ]
    
    set 'split-image function [
        img  [image!]
        x-sz [integer! block!]
        y-sz [integer! block!]
    ][
        res: init-grid img/size x-sz y-sz
        xs: res/1
        ys: res/2
        rgb:   get-channel-data img/rgb   img/size xs ys 'rgb
        alpha: get-channel-data img/alpha img/size xs ys 'alpha
    
        ; combine the rgb and alpha to make animage
        collect [                  
            repeat n length? rgb [
                keep make image! reduce[rgb/:n/1 rgb/:n/2 alpha/:n/2]
            ]
        ]
    ]
]
