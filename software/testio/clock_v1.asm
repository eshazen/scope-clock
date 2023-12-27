;;;
;;; clock_v1.asm - first integrated clock
;;;
;;; working OK 12/27/23 after some timing tweaks to delay_speed, dval
;;; 

umon:	equ	8100h		;re-enter umon

input_port:	equ	80H	;inputport
output_port:	equ	0	;port 0 for LED/keyboard output
	
data_bit:	equ	80H	;input data mask

	org	0a000h		;above UMON

	jp	test_init	;cold start, set clock per time below
	jp	test_start	;warm start, read from RTC

time_hr:	db 1		;time hours 1-12
time_min:	db 0		;time minutes 0-59
time_sec:	db 0		;time seconds 0-59

time_hr_pos:	db 0		;hour hand position 0-59
time_min_pos:	db 0		;minute hand position 0-59
time_sec_pos:	db 0		;second hand position 0-59

;;; delay between checking RTC
delay_speed:	dw 10h		;10H is pretty fast, no lag in display
;;; delay between vectors
dval:	dw	4		;4 is nice, no flicker

;;; --------------------------------------------------
;;; auto-generated table with
;;; clock_tics:  bare face with tics
;;; sec_hand_00...sec_hand_59  and sec_hand_size
;;; min_hand_00...min_hand_59  and min_hand_size
;;; hr_hand_00...hr_hand_59    and hr_hand_size
dlist:		
	.include "face_list.asm"
;;; --------------------------------------------------
	
;;;
;;; DS1306 RTC support
;;; 
	.include "rtc_lib.asm"
	

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
	

;;; multiply HL = DE * B with a loop
;;; enter at mul16x8_bias to add HL
mul16x8:
	ld	hl,0
mul16x8_bias:
	ld	a,b
	or	a
	ret	z
mul01:	add	hl,de
	djnz	mul01
	ret

;;; --------------------------------------------------
;;; main program
;;; --------------------------------------------------

test_init:
	;; set RTC from stored values
	ld	a,(time_hr)
	ld	h,a
	ld	a,(time_min)
	ld	l,a
	ld	a,(time_sec)
	ld	e,a
	call	rtc_set

test_start:
	call	time_to_hand
	ld	hl,(delay_speed)
	ld	b,h
	ld	c,l
	
	;; redraw the face for <delay_speed> loops
test_loop:
	push	bc
	;; check bit-bang UART
	in	a,(input_port)
	and	data_bit
	jp	z,umon
	
	call	clock_face
	pop	bc

	dec	bc
	ld	a,b
	or	c
	jr	nz, test_loop

	;; turn off the beam
	ld	a,data_bit+7
	out	(output_port),a
	
	;; update the time
	call	rtc_get
	ld	a,h
	ld	(time_hr),a
	ld	a,l
	ld	(time_min),a
	ld	a,e
	ld	(time_sec),a
	call	time_to_hand

	jr	test_start



;;; --------------------------------------------------
;;; convert time to hand positions
;;; for all but the hour hand this is trivial
;;; --------------------------------------------------
time_to_hand:

	ld	a,(time_sec)	;seconds 0-59
	ld	(time_sec_pos),a

	ld	a,(time_min)	;minutes 0-59
	ld	(time_min_pos),a

	ld	a,(time_hr)	;get hours 1-12

	;; 12 becomes zero
	cp	a,12
	jr	nz,not12
	ld	a,0

	;; multiply by 5
not12:	ld	b,a
	ld	de,5
	call	mul16x8		;hours * 5 in HL

	;; add (time_min div 12)
	ld	a,(time_min)	;get minutes 0-59
	ld	c,0		;quotient
t2hd:	inc	c
	sub	a,12		;subtract 12
	jr	nc,t2hd		;until underflow
	dec	c
	ld	a,c
	add	a,l

	ld	(time_hr_pos),a
	
	ret


;;; --------------------------------------------------
;;; display clock face with hands
;;;    time in (time_hr_pos, time_min_pos, time_sec_pos)
;;; --------------------------------------------------
clock_face:
	ld	hl,clock_tics
	call	dpy_list

	ld	hl,sec_hand_00
	ld	a,(time_sec_pos)
	ld	b,a
	ld	de,sec_hand_size
	call	mul16x8_bias
	call	dpy_list

	ld	hl,min_hand_00
	ld	a,(time_min_pos)
	ld	b,a
	ld	de,min_hand_size
	call	mul16x8_bias
	call	dpy_list

	ld	hl,hr_hand_00
	ld	a,(time_hr_pos)
	ld	b,a
	ld	de,hr_hand_size
	call	mul16x8_bias
	call	dpy_list

	ret

	.end
	
