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
   life_buffer resb 1000
   life_buffer2 resb 1000
   misc_buffer resb 100


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
   call cp_1_to_2

   pop edx ;life_buffer end address
   push edx

   call print_life_buffer

   ;current stack: life_buffer end address

   jmp gol_setup
   gol_setup_ret:

   ;current stack: life_buffer end addr; grid width; grid height
   jmp step_gol

   call exit_with_msg
   ;jmp gol_step


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

   ;shr ebx, 8 ;ebx = ebx >> 8 (ebx = current y coord)
   shl ebx, 16
   shr ebx, 24

   ;imul bx, dx ;edx *= currY ;gas or nas?
   imul dx, bx ;edx *= currY ;gas or nas? ;original

   ;imul dl, bh ;edx *= currY (al) (bad)


   ;mov al, bl
   ;mov al, bh
   ;mul dl ;edx *= currY


   pop ebx ;reset eax and ebx
   pop eax
   push eax ;push them back on stack
   push ebx

   ;pop ebx
   ;pop eax
   ;ret

   ;shl ebx, 24 ;ebx = ebx << 24
   ;shr ebx, 24 ;ebx = ebx >> 24 (ebx = current x coord)
   ;add edx, ebx ;edx += currX
   add dl, bl

   pop ebx ;reset eax and ebx
   pop eax

   ;jmp step_gol_get_index_ret
   ret

inc_misc:
   push eax
   mov eax, [misc_buffer]
   inc eax
   mov [misc_buffer], eax
   pop eax
   ret


get_neighbor_count:
   ;0x60 empty (`)
   ;0x78 alive (x)

   ;args
      ;al - grid width (width + 1 for newline)
      ;ah - grid height (real height)
      ;bl - x coord
      ;bh - y coord
      ;ecx - file length
      ;edx - current index

   pushad

   mov BYTE [misc_buffer], 0

   check_top_left:
      cmp bh, 0
      je check_top_right

      cmp bl, 0
      je check_top_right

      dec bh
      dec bl

      call step_gol_get_index
      add edx, life_buffer
      cmp BYTE [edx], 0x78
      jne check_top_right

      call inc_misc

   check_top_right:
      popad
      pushad

      cmp bh, 0
      je check_bottom_left

      cmp bl, al
      je check_bottom_left

      dec bh
      inc bl

      call step_gol_get_index
      add edx, life_buffer
      cmp BYTE [edx], 0x78
      jne check_bottom_left

      call inc_misc

   check_bottom_left:
      popad
      pushad

      cmp bl, 0
      je check_bottom_right

      cmp bh, ah
      je check_bottom_right

      inc bh
      dec bl

      call step_gol_get_index
      add edx, life_buffer
      cmp BYTE [edx], 0x78
      jne check_bottom_right

      call inc_misc

   check_bottom_right:
      popad
      pushad

      cmp bh, ah
      je check_top

      cmp bl, al
      je check_top

      inc bh
      inc bl

      call step_gol_get_index
      add edx, life_buffer
      cmp BYTE [edx], 0x78
      jne check_top

      call inc_misc

   check_top:
      popad
      pushad

      cmp bh, 0
      je check_bottom

      dec bh
      call step_gol_get_index
      add edx, life_buffer
      cmp BYTE [edx], 0x78
      jne check_bottom

      call inc_misc

   check_bottom:
      popad
      pushad

      cmp bh, ah
      je check_left

      inc bh
      call step_gol_get_index
      add edx, life_buffer
      cmp BYTE [edx], 0x78
      jne check_left

      call inc_misc

   check_left:
      popad
      pushad

      cmp bl, 0
      je check_right

      dec bl
      call step_gol_get_index
      add edx, life_buffer
      cmp BYTE [edx], 0x78
      jne check_right

      call inc_misc

   check_right:
      popad
      pushad

      cmp bl, al
      je get_neighbor_pre_ret

      inc bl
      call step_gol_get_index
      add edx, life_buffer
      cmp BYTE [edx], 0x78
      jne get_neighbor_pre_ret

      call inc_misc


   ;mov BYTE [misc_buffer], 3

   get_neighbor_pre_ret:


   popad
   jmp get_neighbor_count_ret


step_gol_rec:
   ;0x60 empty (`)
   ;0x78 alive (x)

   ;args
      ;al - grid width
      ;ah - grid height
      ;bl - x coord
      ;bh - y coord
      ;ecx - file length
      ;edx - current index

   ;reset width and increment line number
   cmp bl, al
   jl skip_reset_width
   mov bl, 1
   inc bh
   jmp step_gol_rec

   skip_reset_width:


   ;next comes the check that we're on last square

   ;get index into array (width*currY + currX)
   call step_gol_get_index
   ;jmp step_gol_get_index
   ;step_gol_get_index_ret:


   push eax ;so debug code doesn't mess with misc_buffer
   xor eax, eax
   mov [misc_buffer], eax
   pop eax

   %if 0 ;DEBUG
   pushfd
   pushad
   call print_nl

      ;print grid width
         popad
         pushad
         shl eax, 24
         shr eax, 24
         call int_to_char
         mov [misc_buffer], eax

         mov eax, 4
         mov ebx, 1
         mov ecx, misc_buffer
         mov edx, 1
         int 0x80
         call print_nl
      ;print grid height
         popad
         pushad
         shl eax, 16
         shr eax, 24
         call int_to_char
         mov [misc_buffer], eax

         mov eax, 4
         mov ebx, 1
         mov ecx, misc_buffer
         mov edx, 1
         int 0x80
         call print_nl
      ;print current x
         popad
         pushad
         ;shl ebx, 24
         ;shr ebx, 24
         ;mov eax, ebx
         mov al, bl
         call int_to_char
         mov [misc_buffer], eax

         mov eax, 4
         mov ebx, 1
         mov ecx, misc_buffer
         mov edx, 1
         int 0x80
         call print_nl
      ;print current y
         popad
         pushad
         ;shl ebx, 16
         ;shr ebx, 24
         ;mov eax, ebx
         mov al, bh
         call int_to_char
         mov [misc_buffer], eax

         mov eax, 4
         mov ebx, 1
         mov ecx, misc_buffer
         mov edx, 1
         int 0x80
         call print_nl
      ;print current index
         popad
         pushad
         mov al, dl
         call int_to_char
         mov [misc_buffer], eax

         mov eax, 4
         mov ebx, 1
         mov ecx, misc_buffer
         mov edx, 1
         int 0x80
         call print_nl
      ;print file len
         popad
         pushad
         mov al, cl
         call int_to_char
         mov [misc_buffer], eax

         mov eax, 4
         mov ebx, 1
         mov ecx, misc_buffer
         mov edx, 1
         int 0x80
         call print_nl

   ;push eax
   xor eax, eax
   mov [misc_buffer], eax
   ;pop eax

   popad
   popfd
   %endif ;END DEBUG


   ;cmp edx, ecx ;compare current index with file length
   cmp dl, cl
   jge step_gol_rec_ret


   ;-------LOGIC
   add edx, life_buffer ;returned from step_gol_get_index
   ;mov byte [edx], 0x41

   jmp get_neighbor_count ;returns neighbor count in misc_buffer
   get_neighbor_count_ret:

   cmp BYTE [edx], 0x78 ;0x78 = x
   jne is_dead_cell

   is_live_cell:
      pushad
      mov eax, [misc_buffer]

      cmp eax, 2
      jl should_die

      cmp eax, 3
      jg should_die

      jmp should_live

   is_dead_cell:
      pushad
      mov eax, [misc_buffer]

      cmp eax, 3
      je should_live

      jmp should_die

   ;;;;;
   should_live:
      popad

      sub edx, life_buffer
      add edx, life_buffer2

      mov byte [edx], 0x78
      jmp skip_should_die

   should_die:
      popad

      sub edx, life_buffer
      add edx, life_buffer2

      mov byte [edx], 0x60

   skip_should_die:

   ;-------END LOGIC

   %if 0 ;DEBUG
      pushfd
      pushad

      mov ecx, edx
      mov eax, 4
      mov ebx, 1
      mov edx, 1
      int 0x80
      call print_nl
      call print_nl

      popad
      popfd
   %endif

   inc bl
   jmp step_gol_rec


step_gol:

   pop eax ;eax - grid height
   pop ebx ;ebx - grid width
   pop ecx ;ecx - life_buffer end addr
   pushad

   shl eax, 24
   shr eax, 16 ;grid height in ah

   shl ebx, 24
   shr ebx, 24
   or eax, ebx ;grid width in al

   xor ebx, ebx ;resest for x coord and y coord
   mov bl, 1
   xor edx, edx

   sub ecx, life_buffer
   jmp step_gol_rec
   step_gol_rec_ret:

   ;call exit_with_msg

   popad ;registers same as beginning of step_gol label
   pushad

   mov edx, ecx
   call print_life_buffer2

;   mov edx, ecx
;   sub edx, life_buffer
;
;   mov eax, 4
;   mov ebx, 1
;   mov ecx, life_buffer
;   int 0x80

   call print_nl

   call sleep
   ;jmp step_gol

   popad

   call swap_buffers

   push ecx
   push ebx
   push eax

   ;call exit_with_msg
   jmp step_gol



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
      ;dec ebx

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
   %if 1 ;START DEBUG (print height; width)
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
   %endif ;END DEBUG

   ;ret stack: life_buffer end addr; grid width; grid height
   jmp gol_setup_ret



print_life_buffer: ;edx needs to have buffer end
   pushad

   ;we're going to print life_buffer
   ;sub edx, life_buffer

   call print_nl
   call start_buff_msg

   popad
   pushad
   sub edx, life_buffer
   ;mov edx, 15

   mov eax, 4
   mov ebx, 1
   mov ecx, life_buffer
   int 0x80

   ;call print_nl
   call end_buff_msg
   call print_nl

   popad

   ret


print_life_buffer2: ;edx needs to have buffer end
   pushad

   ;we're going to print life_buffer
   ;sub edx, life_buffer

   call print_nl
   call start_buff_msg

   popad
   pushad
   sub edx, life_buffer
   ;mov edx, 15

   mov eax, 4
   mov ebx, 1
   mov ecx, life_buffer2
   int 0x80

   ;call print_nl
   call end_buff_msg
   call print_nl

   popad

   ret


cp_1_to_2:
   pushad

   mov eax, life_buffer
   mov ebx, life_buffer2
   mov ecx, 1000

   start_cp_loop:
;   push eax
;   push ebx
;
;   mov eax, [eax]
;   mov [ebx], eax
;
;   pop ebx
;   pop eax

   mov edx, [eax]
   mov [ebx], edx

   inc eax
   inc ebx

   loop start_cp_loop

   popad

   ret

swap_buffers:
   pushad

   mov eax, life_buffer
   mov ebx, life_buffer2
   mov ecx, 1000

   start_swap_loop:
   mov edx, [eax]
   xchg edx, [ebx]

   loop start_swap_loop

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

   ;mov dword [tv_sec], 0 ;1 sec
   ;mov dword [tv_usec], 100000000


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


