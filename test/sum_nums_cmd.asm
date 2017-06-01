;ONLY WORKS FOR POSITIVE DIGITS (<10)

   SECTION .data ;initializing data

msg3:        db 0xa
len_msg3:    equ $ - msg3

msg1:        db 'Enter number: '
len_msg1:    equ $ - msg1

msg2:        db 'The sum is: '
len_msg2:    equ $ - msg2

   SECTION .bss

;first byte is accumulator for adding
;buf+3 byte is for reading
buf resb 1 ;1000-byte buffer in data section


;uninitialized data

   SECTION .text

global _start

_start:
   xor eax, eax ;zero 'em out
   xor ebx, ebx

   mov [buf], eax
   mov [buf+1], eax
   mov [buf+2], eax

   jmp loop



loop:
   call print_nl

   ;print message
   mov eax, 4
   mov ebx, 1
   mov ecx, msg1
   mov edx, len_msg1
   int 0x80

   ;read number
   mov eax, 3
   mov ebx, 0
   mov ecx, buf + 3
   mov edx, 2
   int 0x80

   ;mov buffer content into eax
   mov eax, [buf + 3]
   call char_to_int ;convert to integer

   cmp eax, 0
   je its_over

   mov ebx, [buf]
   add ebx, eax
   mov [buf], ebx

   jmp loop

its_over:
   mov eax, 4
   mov ebx, 1
   mov ecx, msg2
   mov edx, len_msg2
   int 0x80

   mov eax, [buf]

   call int_to_char
   mov [buf], eax

   mov eax, 4
   mov ebx, 1
   mov ecx, buf
   mov edx, 1
   int 0x80

   call print_nl

   mov eax, 1
   mov ebx, 0
   int 0x80



int_to_char:
   add al, 48
   movzx eax, al
   ret

char_to_int:
   sub al, 48
   movzx eax, al
   ret

print_nl:
   mov eax, 4
   mov ebx, 1
   mov ecx, msg3
   mov edx, len_msg3
   int 0x80
   ret


