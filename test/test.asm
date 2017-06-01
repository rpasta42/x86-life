
   SECTION .data ;initializing data

msg:   db 'Hello, world',0xa
len:   equ $ - msg


   SECTION .bss

;uninitialized data

   SECTION .text

global _start

_start:
   mov eax, 4 ;write systemcall
   mov ebx, 1 ;write to stdout
   mov ecx, msg
   mov edx, len ;length

   int 0x80

   mov eax, 1 ;exit syscall
   mov ebx, 0 ;return status 0
   int 0x80

   ;leave
   ;ret


