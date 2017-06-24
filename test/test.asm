
   SECTION .data ;initializing data

   SECTION .bss

buffer resb 1 ;1000-byte buffer in data section

;uninitialized data

   SECTION .text

global _start

_start:
   xor eax, eax
   ;mov al, 4
   ;mov eax, 4
   ;mov al, 4
   ;mov ah, 5
   mov eax, 4

   ;shr eax, 1 ;shift right, 4 becomes 2
   shl eax, 1 ;shift left, should become 8

;   jmp int_to_char ;int_to_char receives from eax, returns in eax
;resume_start:
   call int_to_char

   mov [buffer], eax

   mov eax, 4
   mov ebx, 1
   mov ecx, buffer
   mov edx, 1
   int 0x80

   mov eax, 1
   mov ebx, 0
   int 0x80

int_to_char:
   ;add al, 48
   ;movzx eax, al
   add eax, 48
   ret




