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

   ;call open_file
   jmp open_file
   open_file_ret:

   jmp read_file
   read_file_ret:

   push ecx ;pointer in life_buffer where data ends

   call fread_succ_msg ;TODO: we don't actually check this and fail never called

   ;print initial board file content

   pop edx ;stores end of file data address
   push edx ;push it for setup_gol

;   ;start debug
;      mov eax, edx
;
;      ;lea ebx, [life_buffer]
;      ;sub eax, ebx
;      ;OR
;      sub eax, life_buffer
;
;      call int_to_char
;
;      mov [misc_buffer], eax
;      mov eax, 4
;      mov ebx, 1
;      mov ecx, misc_buffer
;      mov edx, 1
;      int 0x80
;      call print_nl
;      call print_nl
;
;      pop edx
;      push edx
;
;      ;call exit_with_msg
;   ;end debug



   ;prints the current file
   call start_buff_msg

   sub edx, life_buffer

   mov eax, 4
   mov ebx, 1
   mov ecx, life_buffer
   int 0x80

   call end_buff_msg


   jmp setup_gol

   jmp exit


setup_gol:

   ;START getting grid width

      ;mov eax, 0 ;counter
      xor eax, eax
      ;mov eax, 0

      mov ebx, life_buffer
      ;sub ebx, 4

      pop ecx ;pointer to end of life_buffer; pushed in start
      push ecx ;ecx stores end address

      jmp gol_grid_width_rec
      gol_grid_width_rec_ret: ;eax has grid width

      ;call exit_with_msg
      inc eax

      push eax ;store grid width on stack


      ;debug start
      %if 0
         ;call exit_with_msg

         call print_nl
         pop eax
         push eax

         call int_to_char

         mov [misc_buffer], eax
         mov eax, 4
         mov ebx, 1
         mov ecx, misc_buffer
         mov edx, 1
         int 0x80
         call print_nl
         ;call exit_with_msg
         pop eax
      %endif
      ;debug end

   ;END getting grid width


   ;START getting grid height
      xor eax, eax ;ebx stores number of lines
      mov ebx, life_buffer ;current char
      mov edx, ecx ;edx stores end address i.e. when to stop counting

      jmp gol_grid_height_rec
      gol_grid_height_rec_ret:
      inc eax

      ;eax stores number of lines
      push eax
   ;END getting grid height

   ;current stack: length of file, grid width grid height
   ;jmp exit_with_msg

   jmp step_gol
   step_gol_ret:




step_gol_rec:
   ;0x60 empty (`)
   ;0x79 alive (x)

   ;al - grid width
   ;ah - grid height
   ;bl - x coord
   ;bh - y coord
   ;ecx - file length

   cmp al, bl
   jne skip_reset_width
   mov bl, 0
   inc bh
   skip_reset_width:

   cmp ah, bh
   je step_gol_rec_ret
   ;jne skip_reset_height
   ;add bh, 1
   ;mov bl, 0
   ;skip_reset_height:

   ;next comes the check that we're on last square
   call step_gol_get_index


   cmp edx, ecx ;compare current index with file length
   jge step_gol_rec_ret

   ;add edx, life_buffer
   ;mov [edx], 0x60
   add edx, life_buffer ;life_buffer_2
   mov byte [edx], 0x41

   inc bl
   jmp step_gol_rec


step_gol_get_index:
   ;returns gridWidth * currY + currX in edx
   ;we need to compare current index into matrix with end of life_buffer
   ;if they're equal, we return

   ;args
      ;al - grid width
      ;ah - grid height
      ;bl - x coord
      ;bh - y coord

   push eax
   push ebx

   xor edx, edx
   mov dl, al ;edx = gridWidth (al)
   shr ebx, 8 ;ebx = ebx >> 8 (ebx = current y coord)
   imul dx, bx ;edx *= currY

   pop ebx ;reset eax and ebx
   pop eax
   push eax ;push them back on stack
   push ebx

   shl ebx, 24 ;ebx = ebx << 24
   shr ebx, 24 ;ebx = ebx >> 24 (ebx = current x coord)
   add edx, ebx ;edx += currX

   pop ebx ;reset eax and ebx
   pop eax

   ret



step_gol:

   call start_buff_msg
   ;current stack (from top): eof life_buffer address, grid width, grid height

   pop eax ;eax - grid height
   pop ebx ;ebx - grid width
   pop ecx ;life_buffer end address

   ;sub ecx, life_buffer ;ecx now stores file length, not file end

   push ecx
   push ebx
   push eax



   ;START debug
      call int_to_char

      mov [misc_buffer], eax
      mov eax, 4
      mov ebx, 1
      mov ecx, misc_buffer
      mov edx, 1
      int 0x80
      call print_nl
      call print_nl

      ;popad
      ;pushad
      pop eax
      pop ebx
      pop ecx
      push ecx
      push ebx
      push eax

      ;;;;
      mov eax, ecx
      call int_to_char
      mov [misc_buffer], eax

      mov eax, 4
      mov ebx, 1
      mov ecx, misc_buffer
      mov edx, 1
      int 0x80
      call print_nl
      call print_nl

      pop eax
      pop ebx
      pop ecx
      push ecx
      push ebx
      push eax

   ;END debug

   shl eax, 8 ;grid height is in ah
   or eax, ebx ;grid width in al

   ;mov ebx, 0
   ;movzx ebx, 0
   xor ebx, ebx

   sub ecx, life_buffer
   jmp step_gol_rec
   step_gol_rec_ret:

   pop eax ;grid height
   pop ebx ;grid width
   pop ecx ;file length
   push ecx
   push ebx
   push eax


   mov edx, ecx
   sub edx, life_buffer

   mov eax, 4
   mov ebx, 1
   mov ecx, life_buffer
   int 0x80

   call print_nl

   call sleep
   ;jmp step_gol

   call exit_with_msg
   ;jmp step_gol_ret


gol_grid_height_rec:
   push ebx

   ;mov ebx, [ebx]
   ;cmp ebx, 0xA ;newline
   mov bl, [ebx]
   cmp bl, 0xA ;newline

   jne skip_increment_newlines
   inc eax
   skip_increment_newlines:

   pop ebx
   inc ebx

   cmp ebx, edx
   jge gol_grid_height_rec_ret

   ;START DEBUG
   ;push eax
   ;push ebx
   ;push ecx
   ;push edx
   ;
   ;mov eax, 4
   ;mov ebx, 1
   ;mov ecx, file_to_open
   ;mov edx, 2
   ;int 0x80
   ;
   ;pop edx
   ;pop ecx
   ;pop ebx
   ;pop eax
   ;END DEBUG

   jmp gol_grid_height_rec

gol_grid_width_rec:

   push ebx
   ;mov ecx, ebx
   ;xor ebx, ebx
   ;mov bl, [ecx]
   ;mov ebx, [ebx]
   mov ebx, [ebx]
   shr ebx, 16

   ;mov ebx, [ecx]

   cmp bl, 0xa ;0xa ;'\n' ;'u' ;0xa ;newline
   je gol_grid_width_rec_ret
   inc eax

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

   ;cmp eax, 14
   ;je gol_grid_width_rec_ret

   ;cmp ebx, ecx ;if no newline and end of file
   ;jge grid_size_fail_msg

   jmp gol_grid_width_rec




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

   ;check for EOF (-1) (broken)
   ;mov eax, [ecx]
   ;cmp eax, -1
   ;je read_file_ret

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


