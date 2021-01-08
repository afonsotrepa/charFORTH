all: a.out

a.out: primitives.o
	ld --omagic $^

primitives.o: primitives.asm math.asm macros.mac
	nasm -felf64 $< -o $@

run: a.out core.fs
	cat core.fs - | ./a.out
