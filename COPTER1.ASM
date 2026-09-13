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

printp proc
  push di cx ax
  mov ax,0b800h
  mov es,ax
  cld
  mov al,160
  dec ch
  dec cl
  mul ch
  xor ch,ch
  shl cl,1
  add ax,cx
  mov di,ax
  mov ah,dl
next:lodsb
  or al,al
  jz quit
  stosw
  jmp short next
quit:pop ax cx di
  ret
printp endp

keyhandler proc far
    push ax cx dx ds si es cs
    pop ds
    ;
    mov dl,0
    mov ch,y
    mov cl,x
    add cl,3
    mov si,offset s1
    call printp
    mov ch,y
    inc ch
    mov cl,x
    mov si,offset s2
    call printp
    ;
    in al,60h
    cmp al,1
    jne k1
    mov flag,1
    jmp short ex
k1: cmp al,72
    jne k2
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
    mov al,20h
    out 20h,al
    pop es ds si dx cx ax
    iRet
keyhandler endp

Timer proc far
    push ds si ax bx dx cs
    pop ds
    ;
    add state,del
    cmp state,maxdel
    jbe t1
    mov state,0
t1: mov dl,5
    mov ch,y
    mov cl,x
    add cl,3
    mov si,offset s1
    add si,state
    call printp
    ;
    mov dl,5
    mov ch,y
    inc ch
    mov cl,x
    mov si,offset s2
    call printp
    ;
    pop dx bx ax si ds
    iRet
timer endp

init:  mov ax,351Ch
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
mc:    cmp flag,1
       jne mc
       ;
       mov ax,cs
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