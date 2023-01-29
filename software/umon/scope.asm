;;; scope.asm - support for scope expansion board
;;;
;;; uart_rst    - initialize UART
;;; uart_rx	- read from UART to A (blocking)
;;; uart_tx	- transmit to UART from A (blocking)
;;; uart_st	- read UART status register
;;; 		  bit 0 - TX ready  bit 4 - RX available
;;; write_led	- write LED latch from bit 0-5
;;; dac_x	- set DAC X from HL
;;; dac_y	- set DAC Y from HL

;;; bits in keyboard latch (port 00)
KBQ_WR:		equ	1	;select write mode
KBQ_SEL:	equ	2	;device select
KBQ_Z:		equ	4	;CRT Z enable
KBQ_UART_RST:	equ	8	;UART reset
KBQ_RTC_CE:	equ	10h	;RTC chip enable
KBQ_SER_DAT:	equ	80h	;bit-bang serial out

uart_rst:
	ld	a,KBQ_UART_RST
	out	(0),a		;assert reset
	xor	a
	out	(0),a		;clear reset
	ret

;;; select device and perform I/O operations

;;; receive UART character
uart_rx:
	call	uart_st
	and	10h
	ret	z
	in	a,(40h)
	ret

;;; write to UART data register from A
;;;   uses: E
uart_tx:
	ld	e,a
	call	uart_st
	and	1
	jr	nz,uart_tx
	ld	a,1		;low bits 01
	call	setport0
	ld	a,e
	out	(40h),a		;write data
	ret

;;; read UART status to A
uart_st:
	xor	a
	call	setport0
	in	a,(41h)
	ret

;;; write LEDs from A
;;;   uses: E
write_led:
	ld	e,a
	ld	a,3		;low bits 11
	call	setport0
	ld	a,e
	out	(41h),a
	ret

;;; write DAC X from HL
dac_x:	ld	a,0
	call	write_led
	ld	a,1		;low bits 01
	call	setport0
	ld	a,l
	out	(41h),a
	ld	a,8
	call	write_led
	ld	a,1		;low bits 01
	call	setport0
	ld	a,h
	out	(41h),a
	ret

	
;;; write DAC Y from HL
dac_y:	ld	a,0		;DAC addr = 0
	call	write_led
	ld	a,3		;low bits 11
	call	setport0
	ld	a,l
	out	(40h),a
	ld	a,8
	call	write_led
	ld	a,3		;low bits 11
	call	setport0
	ld	a,h
	out	(40h),a
	ret

