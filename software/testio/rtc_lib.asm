;;;
;;; rtc.asm - support for DS1306 RTC
;;;
;;; rtc_set - set time from H=hours L=minutes E=seconds
;;; rtc_get - get time to   H=hours L=minutes E=seconds

output_port: 	equ	0		;control port
input_port:	equ	80h		;input port
led1_port:	equ	40h		;LED1 strobe (DACs, LEDs on expansion board)
exp_port:	equ	41h		;expansion port 
rtc_port:	equ	0c0h		;LED2 strobe for RTC I/O (pulse RTC SCLK)

;;; port 00 (output_port) bits
rw_bit:		equ	1	;direction bit 0=RD 1=WR
kq1_bit:	equ	2	;register select bit
crt_z_bit:	equ	4	;CTR Z drive bit (keep set for beam off)
rtc_ce_bit:	equ	10h	;RTC chip enable (active high)
data_bit:	equ	80h	;bit-bang serial data bit (keep high)

opb:	equ	(data_bit+crt_z_bit) ;bias on output port

;;; port 41 (LED latch) bits
led1_bit:	equ	1
led2_bit:	equ	2
led3_bit:	equ	4
rtc_sdi_bit:	equ	8

;;; port 80 (input port) bits
rtc_sdo_bit:	equ	20h	; RTC chip serial out data

;;;
;;; get time    H = hours 1-12  L = minutes 0-59  E = seconds 0-59
;;;
rtc_get:
	ld	a,opb
	out	(output_port),a	;set output port to idle

	ld	c,2		;hours register
	call	rtc_read	;get BCD hours
	and	1fh		;keep 10's and 1's
	call	bcd_to_int
	ld	h,a

	ld	c,1		;minutes register
	call	rtc_read
	call	bcd_to_int
	ld	l,a

	ld	c,0		;seconds register
	call	rtc_read
	call	bcd_to_int
	ld	e,a

	ret

;;;
;;; convert two-digit BCD value in A to integer
;;;
bcd_to_int:
	push	bc
	cp	10		;check for less than 10
	jr	c,bcd1		;yes, we're done
	ld	b,a
	and	0fh		;only 1's in A

	srl	b
	srl	b
	srl	b
	srl	b		;now b has 10's

bcd2:	add	a,10
	djnz	bcd2

bcd1:	pop	bc
	ret

;;;
;;; set time:  H = hours 1-12  L = minutes 0-59  E = seconds 0-59
;;; messes with output port
;;; 
rtc_set:	
	ld	a,opb
	out	(output_port),a	;set output port to idle

	;; set control register to 00
	ld	c,8fh
	ld	a,0
	call	rtc_write

	;; set the time
	ld	c,82h		;hours register
	ld	a,h
	call	int_to_bcd
	add	a,20h		;set 12 hour mode
	call	rtc_write

	ld	a,l
	call	int_to_bcd
	ld	c,81h		;minutes register
	call	rtc_write

	ld	a,e
	call 	int_to_bcd
	ld	c,80h		;seconds register
	call	rtc_write

	ret
	
;;;
;;; convert integer 0-59 in A to BCD
;;; just use successive subtraction to divide by 10
;;; 
int_to_bcd:
	push	bc
	ld	b,0		; initialize quotient
conv61:	cp	10		; less than 10?
	jr	c,conv62	; yes, done
	inc	b
	sub	10
	jr	conv61
	;; now a is 0-9, b has 10's
conv62:	sla	b		; shift 10s left 4
	sla	b
	sla	b
	sla	b
	add	b		; and merge with 1's
	pop	bc
	ret
	

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
	ld	a,opb	;deassert CE
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
	ld	a,opb	;deassert CE
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
	ld	a,opb+rw_bit+rtc_ce_bit ;write mode, CE=H
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
	ld	a,opb+rtc_ce_bit ;read mode, CE=H
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
