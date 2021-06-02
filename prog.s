	.arch	armv8-a
	.align 2
	.data
mse1:
	.string	"Input x: "
mse2:
	.string	"Input precision: "
mse3:
	.string	"cos(%lf) = %g\n"
mse4:
	.string	"mycos(%lf) = %.9lf\n"
mse5:
	.string	"%lf"
mse6:
	.string	"%d) %lg\n"
usage:
	.string	"Usage: %s file\n"
mode:
	.string	"w"
MYPI:
	.double	3.14159265
	.equ	x,	16
	.equ	y,	24
	.global mycos, main, MYPI
	.type	mycos,	%function
	.type	main,	%function
	.align 2
	.text
main:
	stp	x29,	x30,	[sp,	#-32]!
	mov	x29,	sp

	cmp	w0,	#2
	beq	0f
	ldr	x2,	[x1]
	adr	x0,	stderr
	ldr	x0, [x0]
	adr	x1, usage
	bl	fprintf
9:
	mov	w0,	#1
	ldp	x29,	x30,	[sp],	#32
	ret
0:
	ldr	x0,	[x1, #8]
	adr	x1,	mode
	bl	fopen
	cbnz	x0,	1f
	ldr	x0,	[x1, #8]
	bl	perror
	b 9b
1:
	mov	x22,	x0
	adr	x0,	mse1
	bl	printf
	
	adr	x0,	mse5
	add	x1,	x29,	x
	bl	scanf
	
	adr	x0,	mse2
	bl	printf

	adr	x0,	mse5
	add	x1,	x29,	y
	bl	scanf
	ldr	d3,	[x29, y]

	ldr	d0,	[x29, x]
	
	bl	cos

	fmov	d1,	d0
	ldr	d0,	[x29, x]
	adr	x0,	mse3
	//fcvt	d0, s0
	//fcvt	d1, s1
	bl	printf

	ldr	d0,	[x29,	x]
	ldr	d1,	[x29,	y]
	mov	x0,	x22
	bl	mycos
	//fcvt	d1,	s0
	fmov d1, d0
	ldr	d0,	[x29,	x]
	adr	x0,	mse4
	bl	printf
	b	main_end

main_end:
	mov	x0,	x22
	bl	fclose

	ldp	x29,	x30,	[sp],	#32
	mov	x0,	xzr
	ret
	.size	main, .-main

mycos:
	// x0 - file descr
	// s0 - x
	// s1 - precision
	stp	x29,	x30,	[sp,	#-16]!
	stp	x22,	x23,	[sp,	#-16]!
	str	x20,	[sp,	#-8]!
	mov	x22, x0
	adr	x0,	MYPI
	ldr	d3,	[x0]		// d3 = pi
	mov	x20,	#2
	scvtf	d8,	x20		// d8 = 2
	fmul	d3,	d3,	d8	// d3 = 2pi
	fdiv	d4,	d0,	d3	// d4 = x/2pi
	frintz	d4,	d4
	fmul	d4,	d4,	d3	// d4 = N*2pi
	fsub	d0,	d0,	d4	// d0 = x - N*2pi
	fmul	d10,	d0,	d0	// d10 = x*x
	mov	x20,	#1

	scvtf	d8,	x20		// d8 = 1
	fmov	d12,	d8	// d12 = 1
	fmov	d11,	d8	// d11 = 1
	scvtf	d8,	xzr
0:
	fadd	d8,	d8,	d11	
	fdiv	d12,	d12,	d8
	fadd	d8,	d8,	d11
	fdiv	d12,	d12,	d8
	fnmul	d12,	d12,	d10
	
	str	d12,	[sp,	#-8]!

	//fadd	s13,	s13,	s12
	
	mov	x0,	x22
	adr	x1,	mse6
	mov	x2,	x20
	fmov	d0,	d12
	bl	fprintf
	fabs	d13,	d12
	fcmp	d13,	d1
	blt	mycos_preend
	
	add	x20,	x20,	#1
	b	0b
mycos_preend:
	fmov	d2,	d11
1:
	cbz	x20,	mycos_end
	sub	x20,	x20,	#1
	ldr	d1,	[sp],	#8
	fadd	d2,	d2,	d1
	b	1b
mycos_end:

	fmov	d0,	d2
	ldr	x20,	[sp],	#8
	ldp	x22,	x23,	[sp],	#16
	ldp	x29,	x30,	[sp],	#16
	ret
	.size	mycos, .-mycos
