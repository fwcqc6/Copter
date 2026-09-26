Code Segment
org 100h
assume ds:code,cs:code,ss:code
start:jmp init

s1 db '___.___',0,' __.__ ',0,'  _._  ',0,' __.__ ',0
maxdel equ 32
del equ 8
state dw 0
s2 db '\--=`[_]b',0
x db 1
y db 1

old1c dd ?,?
old09 dd ?,?
flag db 0

printp proc ; ds:si - адрес выводимой ASCIIZ-строки, dl - цвет символа
            ; координаты: ch - строка, cl - столбец
  push di cx ax ; сохраним регистры, которые портим
  mov ax,0b800h ; настроим ES на видеобуфер
  mov es,ax
  cld           ; сбросим флаг направления
  mov al,160    ; рассчитаем смещение начала вывода строки в видеобуфере
  dec ch
  dec cl
  mul ch        ; ax:=al*ch
  xor ch,ch
  shl cl,1      ; cx:=cl*2
  add ax,cx     ; получаем смещение первого выводимого символа относительно
  mov di,ax     ; начала видеопамяти
  mov ah,dl     ; цвет выводимых символов
next:lodsb ; Загружаем очередной символ
  or al,al ; строка закончилась?
  jz quit  ; если да, то на выход
  stosw    ; записать символ и цвет
  jmp short next
quit:pop ax cx di
  ret
printp endp

keyhandler proc far
    push ax cx dx ds si es cs
    pop ds
    ;
    in al,60h ; читаем скан-код нажатой клавиши в регистр al
    cmp al,1  ; проверка на esc
    jne k1
    mov flag,1
    jmp short ex
k1: cmp al,72  ; проверка на нажатие стрелок
    jne k2     ; смещение относительно нажатой стрелки и контроль границ
    cmp y,0
    je ex
    dec y
    jmp short ex
k2: cmp al,75
    jne k3
    cmp x,0
    je ex
    dec x
    jmp short ex
k3: cmp al,77
    jne k4
    cmp x+9,80
    je ex
    inc x
    jmp short ex
k4: cmp al,80
    jne ex
    cmp y+1,25
    je ex
    inc y
    ;
ex: and al,01111111b
    mov ah,0
    in al,61h
    mov ah,al
    or al,10000000b
    out 61h,al
    mov al,ah
    out 61h,al
    mov al,20h ; Завершить прерывание
    out 20h,al
    pop es ds si dx cx ax
    iRet
keyhandler endp

Timer proc far
    push ds si ax bx dx cs
    pop ds
    ;
    add state,del ; Изменить состояние винта
    cmp state,maxdel
    jbe t1
    mov state,0
t1: mov dl,5    ; Нарисовтаь винт
    mov ch,y
    mov cl,x
    add cl,3
    mov si,offset s1
    add si,state
    call printp
    ;
    mov dl,5    ; Нарисовать вертолет
    mov ch,y
    inc ch
    mov cl,x
    mov si,offset s2
    call printp
    ;
    pop dx bx ax si ds
    iRet
timer endp

init:  mov ax,351Ch ; Установка обработчиков таймера (1с) и 9-го прерывания
       int 21h
       mov word ptr ds:old1c,bx
       mov word ptr ds:[old1c+2],es
;       push cs
;       pop ds
       mov dx,offset timer
       mov ax,251ch
       int 21h
       mov ax,3509h
       int 21h
       mov word ptr ds:old09,bx
       mov word ptr ds:[old09+2],es
;       push cs
;       pop ds
       mov dx,offset keyhandler
       mov ax,2509h
       int 21h
       ;
mc:    cmp flag,1 ; цикл ожидания заершения программы (по клавише Esc)
       jne mc
       ;
       mov ax,cs ; Восстановление старых обработчиков 1c и 9
       mov ds,ax
       mov ax,251ch
       lds dx,ds:old1c
       int 21h
       mov ax,cs
       mov ds,ax
       mov ax,2509h
       lds dx,ds:old09
       int 21h
       mov ax,4c00h
       int 21h
Code Ends
End Start