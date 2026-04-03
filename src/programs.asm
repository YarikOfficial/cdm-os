rsect programs
prog1>
    ldi r1, 10
    ldi r2, 20
    add r1, r2, r3
    ldi r7, after_prog
    jsr r7

prog2>
    ldi r4, 7
    ldi r5, 8
    add r4, r5, r6
    ldi r7, after_prog
    jsr r7

after_prog>
    halt

end