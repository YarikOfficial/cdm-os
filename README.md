# cdm-os

Учебный мини-OS / monitor для процессора **CdM-16** в **Logisim**.

## Что уже сделано

- запуск процессора через IVT
- `monitor`, который передает управление программам
- несколько программ в одном ROM-образе
- выбор программы через launcher
- тесты арифметики на регистрах

## Тестовый код программы 
asect 0x00 
monitor: ext
default_handler: ext
after_prog: ext
prog1: ext
prog2: ext

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
monitor>
    ldi r0, 0x0100
    ldw r0, r7
    jsr r7

after_prog>
    halt

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

end. 


## Структура проекта

- `cdm16.circ` — схема процессора CdM-16
- `proj.circ` — рабочая схема проекта в Logisim

## Идея проекта

Цель проекта — собрать очень простую ОС-подобную среду для CdM-16:

- monitor / launcher
- запуск нескольких программ
- дальнейшее добавление выбора программы, вывода и ввода

## Следующие шаги

- вынести программы в отдельные asm-файлы
- сделать таблицу программ
- добавить memory-mapped output
- добавить memory-mapped input
- сделать примитивные команды вроде `run` и `ls`

