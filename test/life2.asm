SECTION .data

   ; messages
   fopen_succ_str db 'Successfully opened file', 0xa
   fopen_succ_str_len equ $ - fopen_succ_str

   fopen_fail_str db 'Failed to open file', 0xa
   fopen_fail_str_len equ $ - fopen_fail_str

   fread_succ_str db 'Successfully read file', 0xa
   fread_succ_str_len equ $ - fread_succ_str

   fread_fail_str db 'Failed to read file', 0xa
   fread_fail_str_len equ $ - fread_fail_str

   grid_size_fail_str db 'Could not determine grid size', 0xa
   grid_size_fail_str_len equ $ - grid_size_fail_str

   msg_newline db 0xa
   msg_newline_len equ $ - msg_newline

   exit_str db 'Exiting', 0xa
   exit_str_len equ $ - exit_str

   start_buff_str db 'start buffer', 0xa
   start_buff_str_len equ $ - start_buff_str

   end_buff_str db 'end buffer', 0xa
   end_buff_str_len equ $ - end_buff_str

  timeval:
      tv_sec  dd 0
      tv_usec dd 0

   ;filename to load game of life from
   file_to_open db 'life.txt', 0

SECTION .bss
   life_buffer resb 1
   life_buffer_2 resb 1
   misc_buffer resb 1


SECTION .text

global _start

_start:
   xor eax, eax
   xor ebx, ebx

   jmp open_file
   open_file_ret:

   jmp read_file
   read_file_ret:

   push ecx ;life_buffer end address

   call fread_succ_msg ;TODO: we don't actually check this and fail never called

   pop edx ;life_buffer end address
   push edx

   call print_life_buffer

   ;current stack: life_buffer end address

   jmp gol_setup
   gol_setup_ret:

   call exit_with_msg
   ;jmp gol_step





gol_get_height:
   push ebx

   mov bl, [ebx]
   cmp bl, 0xA ;newline

   jne skip_increment_newlines
   inc eax
   skip_increment_newlines:

   pop ebx
   inc ebx

   cmp ebx, edx
   jge gol_get_height_ret

   %if 0 ;START DEBUG
      pushad
      mov eax, 4
      mov ebx, 1
      mov ecx, file_to_open
      mov edx, 2
      int 0x80
      popad
   %endif ;END DEBUG

   jmp gol_get_height


gol_get_width:

   push ebx
   mov BYTE bl, [ebx]
   ;shr ebx, 16

   cmp bl, 0xa ;0xa ;'\n' ;'u' ;0xa ;newline
   je gol_get_width_ret

   ;debug
      %if 0
      push eax
      push ebx
      ;xor eax, eax
      ;mov [misc_buffer], eax
      ;mov byte [misc_buffer], bl ;ebx

      call int_to_char
      mov [misc_buffer], eax

      mov eax, 4
      mov ebx, 1
      mov ecx, misc_buffer
      mov edx, 1
      int 0x80

      call print_nl
      call print_nl

      pop ebx
      pop eax
      push eax

      mov byte [misc_buffer], bl
      mov eax, 4
      mov ebx, 1
      mov ecx, misc_buffer
      mov edx, 1
      int 0x80

      pop eax
      %endif
   ;end debug

   pop ebx
   inc ebx

   jmp gol_get_width


gol_setup:
   ;current stack: life_buffer end address

   pop edx ; life_buffer end address
   push edx

   ;START getting grid width
      mov ebx, life_buffer
      jmp gol_get_width
      gol_get_width_ret:
      pop ebx
      sub ebx, life_buffer ;ebx now has line width
      dec ebx

      push ebx ;current stack: life_buffe end address; grid width

      %if 0 ;START DEBUG
         call print_nl
         mov eax, ebx
         call int_to_char
         mov [misc_buffer], eax

         mov eax, 4
         mov ebx, 1
         mov ecx, misc_buffer
         mov edx, 1
         int 0x80
         call print_nl
         call print_nl
         call exit_with_msg
      %endif ;END DEBUG

   ;END getting grid width

   ;START getting grid height
      ;current stack: life_buffer end address; grid width

      pop eax ;grid width
      pop edx ;life_buffer end addr
      push edx
      push eax

      xor eax, eax ;eax stores number of lines
      mov ebx, life_buffer ;current char

      jmp gol_get_height
      gol_get_height_ret:

      push eax
   ;END getting grid height

   ;current stack: life_buffer end addr; grid width; grid height
   pop eax ;height
   pop ebx ;width
   push ebx
   push eax

   ;print width and height
   call print_nl

   call int_to_char
   mov [misc_buffer], eax
   mov eax, 4
   mov ebx, 1
   mov ecx, misc_buffer
   mov edx, 1
   int 0x80

   call print_nl

   pop ebx ;height
   pop eax ;width
   push eax
   push ebx

   call int_to_char
   mov [misc_buffer], eax
   mov eax, 4
   mov ebx, 1
   mov ecx, misc_buffer
   mov edx, 1
   int 0x80

   call print_nl
   call print_nl


   jmp gol_setup_ret




print_life_buffer: ;edx needs to have buffer end
   pushad

   ;we're going to print life_buffer
   sub edx, life_buffer

   call print_nl
   call start_buff_msg
   sub ecx, life_buffer
   mov eax, 4
   mov ebx, 1
   mov ecx, life_buffer
   int 0x80
   call end_buff_msg
   call print_nl

   popad

   ret


;return file descriptor on stack
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
   inc ecx ;add offset
   int 0x80

   ;check if number of characters read is less than 1
   cmp eax, 1
   jne read_file_ret

   jmp read_file_rec







;START misc functions

exit_err:
mov eax, 1
mov ebx, 1
int 0x80

exit:
mov eax, 1
mov ebx, 0
int 0x80

int_to_char:
   ;add al, 48
   ;movzx eax, al
   add eax, 48
   ret

char_to_int:
   sub al, 48
   movzx eax, al
   ret

sleep: ;this is taken from https://stackoverflow.com/questions/19580282/nasm-assembly-linux-timer-or-sleep
   mov dword [tv_sec], 1 ;1 sec
   mov dword [tv_usec], 0
   mov eax, 162
   mov ebx, timeval
   mov ecx, 0
   int 0x80
   ret

print_nl:
   pushad

   mov eax, 4
   mov ebx, 1
   mov ecx, msg_newline
   mov edx, msg_newline_len
   int 0x80

   popad
   ret

;END misc functions

print_msg:

   fopen_succ_msg:
      mov ecx, fopen_succ_str
      mov edx, fopen_succ_str_len
      push 0 ;non-fatal msg
      jmp print_call

   fopen_fail_msg: ;no message!!
      mov ecx, fopen_fail_str
      mov edx, fopen_fail_str_len
      push 1 ;fatal msg
      jmp print_call
   fread_succ_msg:
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
      jmp print_call
   start_buff_msg:
      mov ecx, start_buff_str
      mov edx, start_buff_str_len
      push 0 ;non fatal
      jmp print_call
   end_buff_msg:
      mov ecx, end_buff_str
      mov edx, end_buff_str_len
      push 0 ;non fatal
      jmp print_call


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


