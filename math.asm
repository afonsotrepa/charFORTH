%include "macros.mac"

extern emit

header "=", equals
	dpop rax
	dpop rcx
	cmp rax, rcx
	je .eq
	dpush 0
	ret
.eq: 	dpush -1
	ret

header "+", sum
	dpop rax
	dpop rcx
	add rax, rcx
	dpush rax
	ret

header "-", subtract
	dpop rax
	dpop rcx
	sub rcx, rax
	dpush rcx
	ret

header "*", multiply
	dpop rax
	dpop rcx
	push rdx
	mul rcx
	pop rdx
	dpush rax
	ret

header "/", divide
	dpop rcx
	dpop rax
	push rdx
	mov rdx, 0
	div rcx
	pop rdx
	dpush rax
	ret

header "%", mod
	dpop rcx
	dpop rax
	push rdx
	mov rdx, 0
	div rcx
	dpush rdx
	pop rdx
	ret

header "<", lesser
	dpop rax
	dpop rcx
	cmp rcx, rax
	jl .t
	dpush 0
	ret
.t: 	dpush -1
	ret

header ">", greater
	dpop rax
	dpop rcx
	cmp rax, rcx
	jl .t
	dpush 0
	ret
.t: 	dpush -1
	ret

header "n", invert
	dpop rax
	not rax
	dpush rax
	ret

header "&", bit_and
	dpop rax
	dpop rcx
	and rax, rcx
	dpush rax
	ret

header "|", bit_or
	dpop rax
	dpop rcx
	or rax, rcx
	dpush rax
	ret

header "^", bit_xor
	dpop rax
	dpop rcx
	xor rax, rcx
	dpush rax
	ret

header "~", logical_not
	dpop rax
	cmp rax, 0
	je .t
	mov rax, 0
	dpush rax
	ret
.t: 	mov rax, -1
	dpush rax
	ret


header ".", dot ;unsigned
	push r12
	mov r12, 1
	mov ax, 0x2000
	push ax
	add rsp, 1

.loop: 	call dup
	dpush 10 ;base
	call mod
	
	dpop rax
	add ax, '0'
	;save byte on the stack to be printed latter
	sal ax, 8
	push ax 
	add rsp, 1

	dpush 10
	call divide
	add r12, 1

	call dup
	dpop rax
	cmp rax, 0
	jne .loop
	dpop rax


	;write digits saved on the stack
	mov rax, 1 ;sys_write
	mov rdi, 1 ;file descriptor
	mov rsi, rsp ;buf
	mov rdx, r12 ;len
	syscall

	add rsp, r12
	pop r12
	ret
