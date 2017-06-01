
   SECTION .data ;initializing data

   SECTION .bss

buffer resb 1 ;1000-byte buffer in data section

;uninitialized data

   SECTION .text

global _start

_start:
   jmp reader_loop

loop_end:
   mov eax, 1
   mov ebx, 0
   int 0x80 ; sysexit

reader_loop:
   mov eax, 3 ;sycall read
   mov ebx, 0 ;STDIN
   mov ecx, buffer ;buffer to read
   mov edx, 1 ;length
   int 0x80

   cmp eax, 0
   jle loop_end

   push eax ;push number read

   mov eax, 4 ;syswrite
   mov ebx, 1
   mov ecx, buffer
   pop edx ; length
   int 0x80

   jmp reader_loop


