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

umon:	equ	8100h		;re-enter umon

dlist:	equ	0a200h

serial_mask:	equ	80H	;input port
led_port:	equ	0	;port 0 for LED/keyboard output
	
data_bit:	equ	80H	;input data mask

	org	0a000h		;above UMON
	
	jp	dpy_list	;0
	jp	echo		;1
	jp	uart_rx		;2
	jp	uart_tx		;3
	jp	uart_st		;4
	jp	write_led	;5
	jp	ldac		;6
	jp	wdac		;7
	jp	uart_rst	;8
	jp	dpy_list	;9
	jp	0000h		;end of table

;;; write display list from memory
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
	call	uart_rst
dpy_loop:	
	call	uart_st		;test UART
	and	10h
	jp	nz,umon

	ld	hl,dlist
	
	ld	a,data_bit+3
	out	(led_port),a	;set control address to '11'
	ld	c,41h		;data port

dpy1:	ld	b,(hl)		;get count
	inc	hl		;point past count
	inc	b
	jr	z,dpy_loop
	dec	b		;restore count

dpy2:	outi
	outi
	outi
	outi

	out	(40h),a		;activate nLDAC
	jr	nz,dpy2

	jr	dpy1

;;; test writing to DAC over and over until UART
test_dac:
	call	uart_rst
dac_loop:	
	call	uart_st		;test UART
	and	10h
	jp	nz,umon

	;; first do reset
	call	ldac
	;; write to DACs (12 bits HL, DE)
	call	wdac
	inc	hl
	inc	de
	jr	dac_loop

	;; slow test for scope debug

	call	delay

	;; write 4 times to DAC with delays
	ld	a,data_bit+3
	out	(led_port),a

	ld	a,55h
	
	out	(41h),a
	call	delay

	out	(41h),a
	call	delay

	out	(41h),a
	call	delay

	out	(41h),a
	call	delay

	ld	a,d
	call	write_led
	inc	d

	jr	dac_loop
	


;;; delay
delay:	push	hl
	ld	hl,800h
dily1:	dec	hl
	ld	a,h
	or	l
	jr	nz,dily1
	pop	hl
	ret

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
	ld	a,data_bit+1	;low bits 11
	out	(led_port),a
	ld	a,e
	out	(41h),a
	ret

;;; reset, LDAC
ldac:	ld	a,data_bit+3
	out	(0),a
	ld	a,h		;test data FIXME
	out	(40h),a		;data unimportant
	ret

;;; write DAC X, Y from HL DE
wdac:	ld	a,data_bit+3
	out	(led_port),a
	ld	c,41h
	out	(c),l
	out	(c),h
	out	(c),e
	out	(c),d
	jr	ldac

	org	dlist

	.include "list.asm"

	.end
	
