
SECTION .data
;initializing data

SECTION .bss
;uninitialized data

SECTION .text
   global _main
   global _start

_start:
_main:
   enter 0,0
   pusha


   popa
   mov eax, 0
   leave
   ret
