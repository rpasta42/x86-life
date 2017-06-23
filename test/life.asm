SECTION .data

   ; messages
   fopen_succ_str db 'Successfully opened file', 0xa
   fopen_succ_str_len equ $ - fopen_succ_str

   fopen_fail_str db 'Failed to openg file', 0xa
   fopen_fail_str_len equ $ - fopen_fail_str

   fread_succ_str db 'Successfully read file', 0xa
   fread_succ_str_len equ $ - fread_succ_str

   fread_fail_str db 'Failed to read file', 0xa
   fread_fail_str_len equ $ - fread_fail_str

   grid_size_fail_str db 'Could not determine grid size', 0xa
   grid_size_fail_str_len equ $ - grid_size_fail_str

   exit_str db 'Exiting', 0xa
   exit_str_len equ $ - exit_str

   ;filename to load game of life from
   file_to_open db 'life.txt', 0

SECTION .bss
   life_buffer resb 1


SECTION .text

global _start

_start:
   xor eax, eax
   xor ebx, ebx

   ;call open_file
   jmp open_file
   open_file_ret:

   jmp read_file
   read_file_ret:

   push ecx ;pointer in life_buffer where data ends
   call fread_succ_msg ;TODO: we don't actually check this and fail never called

   ;print initial board file content

   pop edx ;stores length of file
   push edx ;push it for setup_gol
   sub edx, life_buffer

   mov eax, 4
   mov ebx, 1
   mov ecx, life_buffer
   int 0x80

   call setup_gol

   jmp exit


setup_gol:

   ;START getting grid width
      mov eax, 0 ;counter

      pop ecx ;file length; pushed in start
      push ecx
      add ecx, life_buffer ;now ecx stores end address

      jmp gol_grid_width_rec
      gol_grid_width_rec_ret:

      pop ecx ;file length for grid height
      push ecx
      push ebx ;store grid width on stack
   ;END getting grid width


   ;START getting grid height
      mov ebx, life_buffer ;current char

      mov edx, life_buffer ;edx stores when to stop counting lines
      add edx, ecx ;add file length
      mov eax, 0 ;ebx stores number of lines

      jmp gol_grid_height_rec
      gol_grid_height_rec_ret:
   ;END getting grid height

   jmp exit_with_msg

   jmp step_gol
   step_gol_ret:

   ret


gol_grid_height_rec:
   push ebx
   mov ebx, [ebx]

   cmp ebx, 0xA ;newline
   jne skip_increment_newlines
   inc eax
   skip_increment_newlines:

   pop ebx
   inc ebx

   push ebx ;;DEBUG CODE
   add ebx, 5 ;;DEBUG CODE

   ;cmp ebx, edx
   jge gol_grid_height_rec_ret

   pop ebx ;;DEBUG CODE

   jmp gol_grid_height_rec


gol_grid_width_rec:
   mov ebx, life_buffer
   add ebx, eax
   mov ebx, [ebx]
   cmp ebx, 0xA ;newline
   je gol_grid_width_rec_ret
   add eax, 1

   ;cmp ebx, ecx ;if no newline and end of file
   ;jge grid_size_fail_msg

   jmp gol_grid_width_rec


step_gol:
   jmp step_gol_ret



open_file:
   mov eax, 5 ;SYSCALL OPEN
   mov ebx, file_to_open
   mov ecx, 2 ;read and write
   int 0x80

   push eax ;eax gets overwritten by print_msg
   cmp eax, 0
   jle fopen_fail_msg
   call fopen_succ_msg

   jmp open_file_ret


read_file:

   pop ebx ;fd for read (from open_file)
   mov ecx, life_buffer
   mov edx, 1 ;number to read

   jmp read_file_rec

read_file_rec:

   mov eax, 3 ;systcall read
   add ecx, 1 ;add offset
   int 0x80

   ;check if number of characters read is less than 1
   cmp eax, 1
   jne read_file_ret

   ;check for EOF (-1) (broken)
   ;mov eax, [ecx]
   ;cmp eax, -1
   ;je read_file_ret

   jmp read_file_rec


exit_err:
mov eax, 1
mov ebx, 1
int 0x80

exit:
mov eax, 1
mov ebx, 0
int 0x80


int_to_char:
   add al, 48
   movzx eax, al
   ret


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
      jmp print_call

   exit_with_msg:
      mov ecx, exit_str
      mov edx, exit_str_len
      push 2 ;print and exit
      jmp print_call

   grid_size_fail_msg:
      mov ecx, grid_size_fail_str
      mov edx, grid_size_fail_str_len

      push 1 ;fatal
      ;jmp print_call

   print_call:
      mov eax, 4
      mov ebx, 1
      int 0x80

   pop eax

   cmp eax, 1
   je exit_err

   cmp eax, 2
   je exit

   ret


