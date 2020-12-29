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


header ".", dot ;unsigned
	
.loop: 	call dup
	dpush 10 ;base
	call mod
	
	dpush '0'
	call sum
	call emit

	dpush 10
	call divide

	call dup
	dpop rax
	cmp rax, 0
	jne .loop

	dpop rax
	ret

