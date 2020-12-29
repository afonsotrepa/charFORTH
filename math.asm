%include "macros.mac"

extern emit

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


digits: db "0123456789ABCDEF"

header ".", dot ;unsigned
	push rbx
	push r12
	mov r12, 0

	dpop rax
	mov rcx, 60

.loop: 	mov rbx, rax
	shr rbx, cl
	and rbx, 1111b
	;check if leading zero
	cmp rcx, 0 ;do emit if it's the last 0
	je .emit
	or r12, rbx
	cmp r12, 0
	je .again

.emit: 	mov bl, [rbx+digits]
 	push rcx
	push rax
	dpush rbx
	call emit
	pop rax
	pop rcx

	cmp rcx, 0
	je .end

.again: sub rcx, 4
	jmp .loop

.end: 	pop r12
	pop rbx
	ret

