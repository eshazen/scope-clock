;;;
;;; various hardware tests for V2 DAC board
;;;

umon:	equ	8100h		;re-enter umon

input_port:	equ	80H	;inputport
output_port:	equ	0	;port 0 for LED/keyboard output
	
ctrl_read: 	equ	40H	;port to read from extra HW
ctrl_writ: 	equ	41H	;port to write to extra HW

data_bit:	equ	80H	;bitbang serial data mask for ports 00/80

	org	0a000h		;above UMON

	jp	test_leds	;test LEDs until key hit
	jp	test_shaft	;test shaft encoder
	jp	test_sw		;test buttons
	jp	ramp_dacs	;ramp the DACs
	jp	test_hv_z	;copy sw to Z out, HV enable

;;;
;;; write to expansion latch value from A
;;; uses B
;;; 
write_exp:
	ld	b,a
	ld	a,data_bit+1	;address the LEDs
	out	(output_port),a	;set control address to '01' (expansion latch)
	ld	a,b
	out	(ctrl_writ),a
	ret

;;;
;;; check for UART input and exit to UMON
;;; uses A
;;; 
check_exit:	
	in	a,(input_port)
	and	data_bit
	ret	nz
	;; fall through to umon exit

;;; exit to UMON, turn of beam first
umon_exit:
	ld	a,data_bit+7
	out	(output_port),a	;turn off beam
	jp	umon

;;;------------------------------------------------------------
;;; main tests
;;;------------------------------------------------------------

;;;
;;; copy SW1 to HV enable
;;; copy SW2 to Z enable
;;; 
test_hv_z:
	call	check_exit
	in	a,(input_port)
	ld	e,a
	
	ld	a,0
	bit	3,e		;test SW1
	
	jr	z,hvoff
	ld	a,10h
hvoff:	call	write_exp

	ld	a,data_bit
	bit	4,e
	jr	z,zoff
	ld	a,data_bit+4
zoff:	out	(output_port),a

	jr	test_hv_z
	
;;;
;;; blink LEDs in binary
;;; 
test_leds:
	ld	c,0		;LED value

led_loop:
	inc	c
	ld	a,c
	and	7
	call	write_exp

	ld	hl,1000h
	call	delay_hl

	call	check_exit
	jr	led_loop

;;;
;;; copy shaft encoder outputs to LEDs
;;; 
test_shaft:
	call	check_exit
	in	a,(input_port)
	call	write_exp
	jr	test_shaft

;;;
;;; copy pushbuttons to LEDs
;;; 
test_sw:
	call	check_exit
	in	a,(input_port)
	sra	a
	sra	a
	sra	a
	call	write_exp
	jr	test_sw

;;;
;;; ramp the DACs
;;;
ramp_dacs:
	;; initialize
	ld	a,data_bit+3
	out	(output_port),a	;set control address to '11'
	ld	c,41h		;data port
	ld	de,0

rampy:	out	(c),e		;X (low)
	out	(c),d		;X (high)
	
	out	(c),e		;Y (low)
	out	(c),d		;Y (high)

	out	(40h),a		;activate nLDAC
	inc	de

;	ld	hl,1h
;	call	delay_hl
	jr	rampy


delay_hl:
	call	check_exit
	dec	hl		; 6
	ld	a,h		; 4
	or	l		; 4
	jr	nz,delay_hl	; 12
 	                        ; total 26 (6.5 us)
	ret
	
	.end
	
