global _start

SECTION .data ;initializing data

SECTION .bss
;uninitialized data

SECTION .text


_start:
   #enter 0,0
   #pusha
   xor eax,eax
   xor ebx,ebx
   xor ecx,ecx
   xor edx,edx
   jmp short string
   code:
   pop ecx
   mov bl,1
   mov dl,13
   mov al,4

   ;mov edx, len
   ;mov ecx, msg
   ;mov ebx,1
   ;mov eax,4
   ;int 0x80


   #popa
   #mov eax, 0
   #leave
   #ret

code   db 'Hello, world',0xa
len equ $ - msg

