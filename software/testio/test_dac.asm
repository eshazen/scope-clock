;;;
;;; test_dac.asm - ramp the DACs
;;; 

;;; bits in keyboard latch (port 00)
KBQ_WR:		equ	1	;select write mode
KBQ_SEL:	equ	2	;device select
KBQ_Z:		equ	4	;CRT Z enable
KBQ_UART_RST:	equ	8	;UART reset
KBQ_RTC_CE:	equ	10h	;RTC chip enable
KBQ_SER_DAT:	equ	80h	;bit-bang serial out

umon:	equ	8100h		;re-enter umon

serial_port:	equ	80H	;input port
led_port:	equ	0	;port 0 for LED/keyboard output
	
data_bit:	equ	80H	;input data mask

	org	9000h		;above UMON

;;; reset the UART
	ld	a,KBQ_UART_RST
	out	(0),a		;assert reset
	xor	a
	out	(0),a		;clear reset

	ld	bc,0		;DAC value

check:
	;; check for serial input low (character in progress)
	in	a,(serial_port)
	and	data_bit
	jp	z,umon

	;; write to DAC X
	ld	a,KBQ_WR	;write mode, sel=0
	out	(0),a
	ld	a,c		;DAC value lo
	out	(41h),a
	;; <FIXME> not finished

	;; delay a while
	ld	de,200h

dilly:
	;; first check UART
	in	a,(serial_port)
	and	data_bit
	jp	z,umon

	dec	de
	ld	a,d
	or	e
	jr	nz,dilly

	jr	check		;

	.end
	
