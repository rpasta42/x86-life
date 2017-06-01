

# -nostdlib --entry _start
default: nasm
	gcc -m32 -nostdlib -nostdinc -o test.ex test.o

nasm:
	nasm -f elf test1.asm #-g -F stabs -f elf32

#Supported emulations: elf_x86_64 elf32_x86_64 elf_i386 elf_iamcu i386linux elf_l1om elf_k1om i386pep i386pe

link: nasm
	ld -melf_i386 -o test.ex test.o -e _start #ld -mi386linux -o test.ex test.o #ld -melf_i386 -e _start -o test1.ex test.o


clean:
	rm test.o test.ex; rm -rf *.o *.ex


