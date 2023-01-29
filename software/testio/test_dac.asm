;;;
;;; test_dac.asm - ramp the DACs
;;;
;;; also prototype library for expansion board

;;; bits in keyboard latch (port 00)
KBQ_WR:		equ	1	;select write mode
KBQ_SEL:	equ	2	;device select
KBQ_Z:		equ	4	;CRT Z enable
KBQ_UART_RST:	equ	8	;UART reset
KBQ_RTC_CE:	equ	10h	;RTC chip enable
KBQ_SER_DAT:	equ	80h	;bit-bang serial out

umon:	equ	9100h		;re-enter umon

serial_mask:	equ	80H	;input port
led_port:	equ	0	;port 0 for LED/keyboard output
	
data_bit:	equ	80H	;input data mask

	org	0a000h		;above UMON
	
	jp	start		;0
	jp	echo		;1
	jp	uart_rx		;2
	jp	uart_tx		;3
	jp	uart_st		;4
	jp	write_led	;5
	jp	dac_x		;6
	jp	dac_y		;7
	jp	uart_rst	;8
	jp	test_dac	;9
	jp	0000h		;end of table

;;; test writing to DAC over and over until UART
test_dac:
	call	uart_rst
dac_loop:	
	call	uart_st		;test UART
	and	10h
	jp	nz,umon

	inc	hl
	ld	a,h
	and	0fh
	ld	h,a
	
	call	dac_x
	call	dac_y

	jr	dac_loop

;;; echo the UART
echo:	call	uart_rst

echo1:	call	uart_st
	and	10h
	jr	z,echo1
	
	call	uart_rx
	cp	a,'$'
	jp	z,umon
	call	uart_tx
	jr	echo1
	
uart_rst:
	ld	a,KBQ_UART_RST
	out	(0),a		;assert reset
	xor	a
	out	(0),a		;clear reset
	ret

;;; reset the UART
start:	call	uart_rst
	ld	bc,0		;DAC value

check:
	;; check for serial input low (character in progress)
	in	a,(serial_mask)
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
	in	a,(serial_mask)
	and	data_bit
	jp	z,umon

	dec	de
	ld	a,d
	or	e
	jr	nz,dilly

	jr	check		;


;;; select device and perform I/O operations

;;; read from UART data register to A
uart_rx:
	ld	a,data_bit	;low bits 00
	out	(led_port),a
	in	a,(40h)
	ret

;;; write to UART data register from A
;;;   uses: E
uart_tx:
	ld	e,a
	ld	a,data_bit+1	;low bits 01
	out	(led_port),a
	ld	a,e
	out	(40h),a		;write data
	ret

;;; read UART status to A
uart_st:
	ld	a,data_bit	;low bits 00
	out	(led_port),a
	in	a,(41h)
	ret

;;; write LEDs from A
;;;   uses: E
write_led:
	ld	e,a
	ld	a,data_bit+3	;low bits 11
	out	(led_port),a
	ld	a,e
	out	(41h),a
	ret

;;; write DAC X from HL
dac_x:	ld	a,0
	call	write_led
	ld	a,data_bit+1	;low bits 01
	out	(led_port),a
	ld	a,l
	out	(41h),a
	ld	a,8
	call	write_led
	ld	a,data_bit+1
	out	(led_port),a
	ld	a,h
	out	(41h),a
	ret

	
;;; write DAC Y from HL
dac_y:	ld	a,0
	call	write_led
	ld	a,data_bit+3	;low bits 11
	out	(led_port),a
	ld	a,l
	out	(40h),a
	ld	a,8
	call	write_led
	ld	a,data_bit+3	;low bits 11
	out	(led_port),a
	ld	a,h
	out	(40h),a
	ret

	.end
	
