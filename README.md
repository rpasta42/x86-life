
# Game of Life written in x86 assembly.

The project uses Linux system calls directly, without standard C library.


### Setup on Ubuntu

`sudo apt install nasm`

`sudo apt-get install gcc-multilib`

You might also need to run this:

`sudo apt install libc6:i386`


### Setup on Ubuntu

first, choose which example you want to run (or make your own)

`cp examples/life.txt.explosion life.txt`

and then simply run make:

`make`

