### INTERRUPT TABLE ###
asect 0x00
core_init: ext
default_handler: ext
key_handler: ext

# Таблица векторных прерываний (IVT)
dc core_init, 0 # Вектор запуска/сброса, начальный PS
dc default_handler, 0 # Невыровненный SP
dc default_handler, 0 # Невыровненный PC
dc default_handler, 0 # Недопустимая инструкция
dc default_handler, 0 # Double Fault
dc key_handler, 0 # Прерывания клавиатуры
align 0x80 # Зарезервировать место для других IVT


### HANDLERS ###
rsect exc_handlers

default_handler>
    halt

key_handler>
    ldi r0, 0xF000 # Символ на клавиатуре и статус
    ldw r0, r1
    ldi r0, 5
    add r0, r1

    rti


### CORE ###
rsect os_core

prog1: ext
prog2: ext

# Code
core_init>
    ldi r0, 0x8000 # Меняем указатель стека
    stsp r0

    ei # enable interrupts
loop:
    wait # wait for an interrupt
    #int 5
    br loop # loop forever ;)
    di # disable interrupts
    
end.
