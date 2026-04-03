asect 0x00
monitor: ext
default_handler: ext

dc monitor, 0
dc default_handler, 0
dc default_handler, 0
dc default_handler, 0
dc default_handler, 0
align 0x80

rsect exc_handlers
default_handler>
    halt

rsect monitor
prog1: ext
prog2: ext
monitor>
    #ldi r0, 0x0100
    #ldw r0, r7
    #jsr prog1
    br prog1
end.
