;;;
;;; test_pattern.asm -- simple test patterns for hardware debug
;;;

umon:	equ	8100h		;re-enter umon

input_port:	equ	80H	;inputport
output_port:	equ	0	;port 0 for LED/keyboard output
	
data_bit:	equ	80H	;input data mask

	org	0a000h		;above UMON

	jp	test_init

;;; delay between checking RTC
delay_speed:	dw 40h
;;; delay between vectors
dval:	dw	1

;;; display list for testing from make_list.c
circle080:
	.include "circle080.asm"
circle100:
	.include "circle100.asm"
circle180:
	.include "circle180.asm"

;;; --------------------------------------------------
	
;;; --------------------------------------------------
;;; write display list from memory at HL
;;; display list format:
;;;     <count>
;;;       <xlow> <xhigh> <ylow> <yhigh>
;;;       <xlow> <xhigh> <ylow> <yhigh>
;;;           ...
;;;     <count>
;;;       <xlow> <xhigh> <ylow> <yhigh>
;;;       <xlow> <xhigh> <ylow> <yhigh>
;;;           ...
;;; count must be a multiple of 4; FF marks end of list
;;; so 4 = 1 point,  8 = 2 points, 0 = 64 points

dpy_list:
	ld	a,data_bit+3
	out	(output_port),a	;set control address to '11'
	ld	c,41h		;data port

dpy1:	ld	b,(hl)		;get count
	inc	hl		;point past count
	inc	b
	ret	z

	dec	b		;restore count

dpy2:
	;; set the Z axis
	outi			;send LSB of X
	;; check for move/draw in LSB of X
	bit	7,(hl)		;first byte bit 7 set for draw
	ld	a,data_bit+3	;default bit 2=0, beam on for draw
	jr	nz,dodraw
	;; move, turn off the Z
	ld	a,data_bit+7
dodraw:	
	out	(output_port),a

	outi
	outi
	outi

	;; delay before asserting LDAC for the Z axis to settle
	push	af
	call	delay
	pop	af

	out	(40h),a		;activate nLDAC
	
	;; turn off the beam
	ld	a,data_bit+7
	out	(output_port),a
	push	af
	call	delay
	pop	af

	jr	nz,dpy2
	
	jr	dpy1


;;; delay
delay:	push	hl
	ld	hl,(dval)
delay1:	dec	hl
	ld	a,h
	or	l
	jr	nz,delay1
	pop	hl
	ret

delay_hl:
	dec	hl		; 6
	ld	a,h		; 4
	or	l		; 4
	jr	nz,delay1	; 12
 	                        ; total 26 (6.5 us)
	ret
	

;;; --------------------------------------------------
;;; main program
;;; --------------------------------------------------

test_init:
	
	;; check bit-bang UART
	in	a,(input_port)
	and	data_bit
	jp	z,umon

;;	ld	hl,circle080
;;	call	dpy_list
;;	ld	hl,circle100
;;	call	dpy_list
	ld	hl,circle180
	call	dpy_list
	

	jr	test_init

	.end
	
