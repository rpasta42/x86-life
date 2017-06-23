SECTION .data

   ; messages
   fopen_succ_str db 'Success opening file'
   fopen_succ_str_len equ $ - fopen_succ_str

   fopen_fail_str db 'Success opening file'
   fopen_fail_str_len equ $ - fopen_fail_str

   fread_succ_str db 'Successfully read file'
   fread_succ_str_len equ $ - fread_succ_str

   fread_fail_str db 'Failed to read file'
   fread_fail_str_len equ $ - fread_fail_str

   ;filename to load game of life from
   file_to_open db 'life.txt', 0

SECTION .bss
   life_buffer resb 1


SECTION .text

global _start

_start:
   xor eax, eax
   xor ebx, ebx

   call open_file

   pop ebx ;from open_file, (for read fd)

   push 0 ;offset into file
   call read_file_rec




;_start end




;print_msg example:
;first save registers, then: print_msg 1

print_msg:

   fopen_succ_msg:
      ;jne fopen_fail_msg

      mov ecx, fopen_succ_str
      mov edx, fopen_succ_str_len

      push 0 ;non-fatal msg

      jmp print_call

   fopen_fail_msg: ;no message!!
      ;cmp eax, 2 ;fopen_fail_msg
      ;jne fread_succ_msg

      mov ecx, fopen_fail_str
      mov edx, fopen_fail_str_len

      push 1 ;fatal msg

      jmp print_call
      ;jmp fail_program

   fread_succ_msg:
      ;cmp eax, 3 ;fread_succ_msg
      ;jne fread_fail_msg

      mov ecx, fread_succ_str
      mov edx, fread_succ_str_len

      push 0 ;non-fatal msg

      jmp print_call

   fread_fail_msg: ;4
      mov ecx, fread_fail_str
      mov edx, fread_fail_str_len

      push 1 ;fatal msg
      ;jmp print_call

   print_call:
      mov eax, 4
      mov ebx, 1
      int 0x80

   pop eax
   cmp eax, 1
   je exit_err

   ret


open_file:
   mov eax, 5 ;SYSCALL OPEN
   mov ebx, file_to_open
   mov ecx, 2 ;read and write
   int 0x80

   push eax ;eax gets overwritten by print_msg
   cmp eax, 0
   jle fopen_fail_msg
   call fopen_succ_msg

   ret

read_file_rec:

   pop eax ;current counter

   mov ecx, life_buffer
   add ecx, eax ;add offset

   add eax, 1 ;increment counter
   push eax ;push eax back

   mov eax, 3 ;systcall read
   mov edx, 1
   int 0x80

   cmp eax, 0

   je ret_from_read_file_rec

   jmp read_file_rec

   ;mov eax,
   ;mov ebx, [life_buffer]

   ret_from_read_file_rec:
      ret


exit_err:
mov eax, 1
mov ebx, 1
int 0x80

exit:
mov eax, 1
mov ebx, 0
int 0x80

