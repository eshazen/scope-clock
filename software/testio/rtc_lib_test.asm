
umon:	equ	9100h		;re-enter umon
phex2:	equ	9112h		;
crlf:	equ	910ch		;
putc:	equ	9109h		;

input_port:	equ	80h		;input port
data_bit:	equ	80h	;bit-bang serial data bit (keep high)

	org	0a000h

	jp	test
	jp	int_to_bcd
	jp	bcd_to_int
	
	.include "rtc_lib.asm"

test:
	;; set time to 7:37:30
	ld	h,7
	ld	l,37
	ld	e,30
	call	ptime
	call 	rtc_set
	call	rtc_get
	call	ptime
	call	pline
	

loop:	call	rtc_get


	
	;; delay a while, checking UART
	ld	hl,0c000h
dly:
	;; check bit-bang UART
	in	a,(input_port)
	and	data_bit
	jp	z,umon

	dec	hl
	ld	a,h
	or	l
	jr	nz,dly

	jr	loop


ptime:	ld	a,h
	call	phex2
	ld	a,':'
	call	putc
	ld	a,l
	call	phex2
	ld	a,':'
	call	putc
	ld	a,e
	call	phex2
	call	crlf
	ret

pline:	ld	a,'-'
	call	putc
	call	putc
	call	putc
	call	crlf
	ret
	
	.end
	
