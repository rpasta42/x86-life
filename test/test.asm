
segment .data
;initializing data

segment .bss
;uninitialized data

segment .text
   global my_main

asm_main:
   enter 0,0
   pusha


   popa
   mov eax, 0
   leave
   ret
