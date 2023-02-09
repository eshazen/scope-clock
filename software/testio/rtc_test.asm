;;;
;;; rtc.asm - support for DS1306 RTC
;;;

	org	0a000h
	jp	test
	jp	start
	jp	rtc_write	;write data in A to RTC address C
	jp	rtc_read	;read data from RTC address C to A
	
umon:	equ	8100h		;re-enter umon
phex2:	equ	8112h		;
crlf:	equ	810ch		;
putc:	equ	8109h		;

output_port: 	equ	0		;control port
input_port:	equ	80h		;input port
led1_port:	equ	40h		;LED1 strobe (DACs, LEDs on expansion board)
exp_port:	equ	41h		;expansion port 
rtc_port:	equ	0c0h		;LED2 strobe for RTC I/O (pulse RTC SCLK)

;;; port 00 (output_port) bits
rw_bit:		equ	1	;direction bit 0=RD 1=WR
kq1_bit:	equ	2	;register select bit
rtc_ce_bit:	equ	10h	;RTC chip enable (active high)
data_bit:	equ	80h	;bit-bang serial data bit (keep high)

;;; port 41 (LED latch) bits
led1_bit:	equ	1
led2_bit:	equ	2
led3_bit:	equ	4
rtc_sdi_bit:	equ	8

;;; port 80 (input port) bits
rtc_sdo_bit:	equ	20h	; RTC chip serial out data

test:	
	;; check bit-bang UART
	in	a,(input_port)
	and	data_bit
	jp	z,umon

	;; shift out alternating ones and zeros
	ld	a,55h
	call	rtc_shift_out

	jr	test
	
;;; ------------------------------------------------------------

start:
	ld	a,data_bit
	out	(output_port),a	;set output port to idle

	;; set control register to 00
	ld	c,8fh
	ld	a,0
	call	rtc_write

	;; set the time
	ld	c,82h		;hours register
	ld	a,20h+4		;4pm
	call	rtc_write

	ld	c,81h		;minutes register
	ld	a,15h
	call	rtc_write

	ld	c,80h
	ld	a,0
	call	rtc_write


loop:	
	;; read  registers and display
	ld	c,0		;address to start
	ld	b,3		;count
rrl0:
	push	bc		;save address, count
	ld	a,c
	call	phex2
	ld	a,' '
	call	putc
	call	rtc_read
	call	phex2
	call	crlf
	pop	bc
	inc	c
	djnz	rrl0
	
	call	crlf

	;; delay a while, checking UART
	ld	hl,04000h
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


;;;
;;; write data in A to RTC address in C
;;; uses: B, C
;;; 
rtc_write:
	push	af		;save data
	ld	a,c
	call	rtc_shift_out	;write address
	pop	af
	call	rtc_shift_out	;write data
rtc_done:
	ld	a,data_bit	;deassert CE
	out	(output_port),a
	ret

;;;
;;; read data from RTC address C to A
;;; uses: B, C
;;;
rtc_read:
	ld	a,c
	call	rtc_shift_out	;write address
	call	rtc_shift_in	;read data
	ld	a,data_bit	;deassert CE
	out	(output_port),a
	ld	a,c
	ret
	
;;;
;;; output 8 bits from A to RTC
;;;   uses: B, C
;;; asserts CE
;;; 
rtc_shift_out:	
	ld	c,a		;data to C
	ld	a,data_bit+rw_bit+rtc_ce_bit ;write mode, CE=H
	out	(output_port),a
	ld	b,8		;bit count
	
rtcsh0:	
	ld	a,0
	rl	c		;data to carry
	jr	nc,rtcz
	ld	a,rtc_sdi_bit
rtcz:
	out	(exp_port),a	;set SDO in LED latch
	out	(rtc_port),a	;strobe RTC clk
	djnz	rtcsh0
	ret

	
;;;
;;; input 8 bits from RTC to A, C
;;;   uses: B, C
;;; asserts CE
;;; 
rtc_shift_in:
	ld	a,data_bit+rtc_ce_bit ;read mode, CE=H
	out	(output_port),a
	ld	b,8		;bit count
shin:	in	a,(rtc_port)	;pulse SCLK
	in	a,(input_port)
	and	rtc_sdo_bit	;test input data, CY=0
	jr	z,shin0		;go if zero
	scf			;shift in a 1
shin0:	rl	c
	djnz	shin

	ld	a,c		;data to C
	ret
	
	.end
