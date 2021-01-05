BITS 64
global _start
global emit

%include "macros.mac"
%include "math.asm"

section .text
header "b", bye
 	mov rax, 60 ;sys_exit
	mov rdi, 0 ;exit code
	syscall

header "e", emit
 	dpop rax
	push rax

	mov rax, 1 ;sys_write
	mov rdi, 1 ;file descriptor
	mov rsi, rsp ;buf
	mov rdx, 1 ;len
	syscall

	pop rax
	ret

header "k", key
	push rax

	mov rax, 0 ;sys_read
	mov rdi, 0 ;file descriptor
	mov rsi, rsp ;buf
	mov rdx, 1 ;len
	syscall

	pop rcx
	and rcx, 0xFF
	dpush rcx
	ret

header "d", dup
	dpop rax
	dpush rax
	dpush rax
	ret

header "s", swap
	dpop rax
	dpop rcx
	dpush rax
	dpush rcx
	ret

header "r", rot
	dpop rax
	dpop rcx
	dpop rsi

	dpush rcx
	dpush rax
	dpush rsi
	ret

header "D", drop
	dpop rax
	ret

header "'", tick
	call key
	dpop rcx

	;check for end of file/transmision
	cmp rax, 0
	je .bye

	mov rax, [dict]

.loop: 	cmp rax, 0
	je .end

	mov byte dil, [rax]
	and dil, 0x7F
	cmp cl, dil
	je .end

	mov rax, [rax+1]
	jmp .loop

.end: 	dpush rax
	ret

.bye: 	call bye

header "x", execute
	dpop rax ;xt
	add rax, 9 ;byte + qword
	jmp rax

header ",", comma
	dpop rax
	mov rbx, [heapptr]
	mov [rbx], rax
	add qword [heapptr], 8
	ret

header "@", @
	dpop rax
	mov rax, [rax]
	dpush rax
	ret

header "!", exclam
	dpop rcx
	dpop rax
	mov [rcx], rax
	ret

header "h", here
	mov rax, [heapptr]
	dpush rax
	ret

header "c", create
	call key
	call comma
	sub qword [heapptr], 7

	mov rax, [dict]
	dpush rax
	call comma

	mov rax, [heapptr]
	sub rax, 9
	mov [dict], rax

	;write machine code to put address on stack at runtime
	add rax, 9
	;write: mov rax, body
	mov word [rax], 0xB848 	
	add rax, 2
	mov rcx, rax
	add rcx, 17 ;calculate body address
	mov qword [rax], rcx
	add rax, 8
	;write: mov [rbp], rax
	mov dword [rax], 0x00458948
	add rax, 4
	;write: add rbp, 8
	mov dword [rax], 0x08C58348
	add rax, 4
	;write: ret
	mov byte [rax], 0xC3

	add qword [heapptr], 19 ;allot
	ret

header "v", variable
	call create
	dpush 0
	call comma
	ret

header immediate "l", literal
	dpop rcx
 	mov rax, [heapptr]

	;write: mov rax, literal
	mov word [rax], 0xB848
	add rax, 2
	mov [rax], rcx
	add rax, 8
        ;write: mov qword [rbp], rax
	mov dword [rax], 0x00458948
	add rax, 4
	;write: add rbp, 8
	mov dword [rax], 0x08C58348
	add rax, 4
	mov [heapptr], rax
	ret

header immediate "[", open_bracket
	mov byte [state], 0x00
	ret

header "]", close_bracket
	mov byte [state], 0xFF
	ret

;used to compile a word or number/literal
header immediate "p", compile
	call tick
	dpop rax
	cmp rax, 0
	jne .wrd

	;check if blankspace
	cmp cl, 0x0A
	je .ign
	cmp cl, ' '
	je .ign

	;check if dec number and convert
	cmp rax, 0
	jne .wrd

 	cmp rcx, '9'
	ja .err
	cmp rcx, '0'
	jb .err
	sub rcx, '0'
 	;compile literal
	dpush rcx
	call literal
	ret

.wrd: 	;check if immediate
	mov cl, [rax]
	test cl, 0x80
	jnz .ex
	;compile word
 	add rax, 9
	mov rcx, [heapptr]
	;write: mov rax, xt+9
	mov word [rcx], 0xB848
	add rcx, 2
	mov [rcx], rax
	add rcx, 8
	;write: call rax
	mov word [rcx], 0xD0FF
	add rcx, 2

	mov [heapptr], rcx
	ret

.ex: 	dpush rax
	call execute
	ret

.ign: 	ret

.err: 	mov rax, 1 ;sys_write
	mov rdi, 1 ;file descriptor
	mov rsi, err ;buf
	mov rdx, [errlen] ;len
	syscall
	ret

header ":", colon
	call key
	call comma
	sub qword [heapptr], 7

	mov rax, [dict]
	dpush rax
	call comma

	mov rax, [heapptr]
	sub rax, 9
	mov [dict], rax

	call close_bracket
	ret


header immediate ";", semi_colon
 	mov rcx, [heapptr]
	;write: ret
	mov byte [rcx], 0xC3
	add qword [heapptr], 1

	mov byte [state], 0
	ret

header "i", interpret
	call tick
	;check if blankspace
	dpop rax
	cmp cl, 0x0A
	je .ign
	cmp cl, ' '
	je .ign
	dpush rax

 	;check if dec number and convert
	cmp rax, 0
	jne .ex

 	cmp rcx, '9'
	ja .err
	cmp rcx, '0'
	jb .err
	sub rcx, '0'
	dpop rax
	dpush rcx
	ret

.ex: 	call execute
	ret

.ign: 	ret

.err: 	dpop rax
	mov rax, 1 ;sys_write
	mov rdi, 1 ;file descriptor
	mov rsi, err ;buf
	mov rdx, [errlen] ;len
	syscall

header immediate "?", when
	mov rax, [heapptr]
        ;write: sub rbp, 8
	mov dword [rax], 0x08ED8348
	add rax, 4
	;write: mov rax, qword [rbp]
	mov dword [rax], 0x00458B48
	add rax, 4
	;write: cmp rax, 0
	mov dword [rax], 0x00F88348
	add rax, 4
	;write: je 0x00 relative jump forward
	mov word [rax], 0x0074
	add rax, 2
	mov [heapptr], rax

	push rax ;save address to write to
	call compile
	pop rax

	mov rcx, [heapptr] ;address to jump to if 0
	sub rcx, rax
	;write the difference for the je instrunction
	sub rax, 1
	mov byte [rax], cl ;difference can not be over 127

	ret

header immediate "W", while
	mov rax, [heapptr]
	dpush rax ;push for "repeat" word
        ;write: sub rbp, 8
	mov dword [rax], 0x08ED8348
	add rax, 4
	;write: mov rax, qword [rbp]
	mov dword [rax], 0x00458B48
	add rax, 4
	;write: cmp rax, 0
	mov dword [rax], 0x00F88348
	add rax, 4
	;write: je 0x00000000 relative jump forward (32 bit version)
	mov word [rax], 0x840F
	add rax, 2
	add rax, 4 ;space for address

	mov [heapptr], rax
	ret

header immediate "R", repeat
	mov rax, [heapptr]
	dpop rcx ;address from while
	push rcx
	;write: jmp adrs
	sub rcx, rax ;calculate relative jump
	sub rcx, 5
	mov byte [rax], 0xE9
	add rax, 1
	mov dword [rax], ecx
	add rax, 4
	mov [heapptr], rax

	pop rcx
	;write jump address at the while
	sub rax, rcx
	sub rax, 18
	add rcx, 14
	mov dword [rcx], eax

	ret

header "X", exit
	pop rax
	ret

header "m", imm ;make last defined word immediate
	mov rax, [dict]
	mov cl, byte [rax]
	or cl, immediate 0
	mov byte [rax], cl
	ret

header immediate "I", if
	mov rax, [heapptr]
        ;write: sub rbp, 8
	mov dword [rax], 0x08ED8348
	add rax, 4
	;write: mov rax, qword [rbp]
	mov dword [rax], 0x00458B48
	add rax, 4
	;write: cmp rax, 0
	mov dword [rax], 0x00F88348
	add rax, 4
	;write: je 0x00000000 relative jump forward (32 bit version)
	mov word [rax], 0x840F
	add rax, 2
	dpush rax ;push for "else" word
	add rax, 4 ;space for address

	mov [heapptr], rax
	ret

header immediate "E", else
	mov rax, [heapptr]
	;write rel32 for the "if" jump
	push rax
	dpop rcx
	mov rsi, rcx
	add rsi, 4
	sub rax, rsi
	add rax, 5
	mov dword [rcx], eax
	pop rax
        ;write: jmp rel32 (for "then" word)
	mov byte [rax], 0xE9
	add rax, 1
	dpush rax ;push for "then" word
	add rax, 4 ;space for address

	mov [heapptr], rax
	ret

header immediate "T", then
	mov rax, [heapptr]
	;write rel32 for the "else" or "if" jump
	dpop rcx
	mov rsi, rcx
	add rsi, 4
	sub rax, rsi
	mov dword [rcx], eax

	ret

header "a", allot
	dpop rax
	add [heapptr], rax
	ret
	
	

_start: mov rbp, dstack ;init stack pointer

.repl: 	cmp byte [state], 0
	je .int

	call compile
	jmp .repl

.int: 	call interpret
	jmp .repl
	
section .bss
heap: 	resb 8192*2
dstack: resq 256
section .data
dict: 	dq link
heapptr:dq heap
err: 	db "ERROR: char not defined or number", 0xA
errlen: dq $-err
state: 	db 0
