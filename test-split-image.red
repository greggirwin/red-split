Red [
    Title: "split-image"
    Author: "Galen Ivanov"    
    needs view
]

#include %split-image.red

img: load %"Images/Explosion 1.png"
fnt: load %Images/GEO-FONT_T.png

res: split-image img 64 64
letters: split-image fnt 32 30
abc: " !`' % '() +,-./0123456789;\/= ? ABCDEFGHIJKLMNOPQRSTUVWXYZ"
msg: uppercase "Powered by Red. Greetings to all reducers out there. Coded by Galen in 2021."
txt: collect [
    keep [scale 0.5 0.5]
    keep [scroll: translate 600x0]
    repeat n length? msg [
        keep compose [image (pick letters index? find abc msg/:n) (as-pair n * 32 330)]
    ]
]

frame: 1
phi: 0

refresh: has [
    img pos n
][
    repeat n 5 [
        img: to-path reduce [to-word rejoin ["expl" n] 2]
        set img res/(n * 2 + frame % 25 + 1) 
        pos: to-path reduce [to-word rejoin ["expl" n] 3]
        set pos as-pair to integer! 120 * (cosine 25 * n + phi) + 128
                             to integer! 60 * (sine 2 * (25 * n + phi)) + 68
    ]                    
    phi: phi % 360 + 1
    frame: frame % 25 + 1
    scroll/2: scroll/2 - 3x0
    if scroll/2/x < -2500 [scroll/2: 600x0]
]

view compose/deep [
    title "Old school"
    base black 320x200 rate 60 draw [
        expl1: image (res/1) 128x68
        expl2: image (res/2) 128x68
        expl3: image (res/3) 128x68
        expl4: image (res/4) 128x68
        expl5: image (res/5) 128x68
        (txt)
    ]
    on-time [refresh]
]
