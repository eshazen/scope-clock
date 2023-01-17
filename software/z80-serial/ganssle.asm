	org	100h


;;; temporary equates
serial_port:	equ 10h
serial_low:	equ 11h
serial_high:	equ 12h
data_bit:	equ	80h
	
halfbt:	dw	0
bittim:	dw	0

	;;
	;;   BRID - Determine the baud rate of the terminal. This routine
	;;  actually finds the proper divisors BITTIM and HALFBT to run CIN
	;;  and COUT properly.
	;;
	;;    The routine expects a space. It looks at the 6 zeroes in the
	;;  20h stream from the serial port and counts time from the start
	;;  bit to the first 1.
	;;
	;;   serial_port is the port address of the input data. data_bit
	;;  is the bit mask.
	;;
brid:
	in	a,(serial_port)
	and	data_bit
	jp	z,brid		; loop till serial not busy
bri1:		in	a,(serial_port)
	and	data_bit
	jp	nz,bri1 	; loop till start bit comes
	ld	hl,-7		; bit count
bri3:		ld	e,3
bri4:		dec	e	; 42 machine cycle loop
	jp	nz,bri4
	nop			; balance cycle counts
	inc	hl		; inc counter every 98 cycles
	;;  while serial line is low
	in	a,(serial_port)
	and	data_bit
	jp	z,bri3		; loop while serial line low
	push	hl		; save count for halfbt computation
	inc	h
	inc	l		; add 101h w/o doing internal carry
	ld	(bittim),hl	; save bit time
	pop	hl		; restore count
	or	a		; clear carry
	ld	a,h		; compute hl/2
	rra
	ld	h,a
	ld	a,l
	rra
	ld	l,a		; hl=count/2
	ld	(halfbt),hl
	ret

	;;
	;;  Output the character in C
	;;
	;;   Bittime has the delay time per bit, and is computed as:
	;;
	;;   <HL>' = ((freq in Hz/baudrate) - 98 )/14
	;;   BITTIM = <HL>'+101H  (with no internal carry prop between bytes)
	;;
	;;  and OUT to serial_high sets the serial line high; an OUT
	;;  to serial_low sets it low, regardless of the contents set to the
	;;  port.
	;;
cout:
	ld	b,11	; # bits to send
	;;  (start, 8 data, 2 stop)
	xor	a		; clear carry for start bit
co1:
	jp	nc,cc1	; if carry, will set line high
	out	(serial_high),a ; set serial line high
	jp	cc2
cc1:
	out	(serial_low),a ; set serial line low
	jp	cc2		       ; idle; balance # cycles with those
	;;  from setting output high
cc2:
	ld	hl,(bittim) ; time per bit
co2:
	dec	l
	jp	nz,co2		; idle for one bit time
	dec	h
	jp	nz,co2		; idle for one bit time
	scf			; set carry high for next bit
	ld	a,c		; a=character
	rra			; shift it into the carry
	ld	c,a
	dec	b		; --bit count
	jp	nz,co1		; send entire character
	ret


	;;
	;;   CIN - input a character to C.
	;;
	;;   HALFBT is the time for a half bit transition on the serial input
	;;  line. It is calculated as follows:
	;;    (BITTIM-101h)/2 +101h
	;;
cin:		ld	b,9	; bit count (start + 8 data)
ci1:		in	a,(serial_port) ; read serial line
	and	data_bit		; isolate serial bit
	jp	nz,ci1			; wait till serial data comes
	ld	hl,(halfbt)		; get 1/2 bit time
ci2:		dec	l
	jp	nz,ci2		; wait till middle of start bit
	dec	h
	jp	nz,ci2
ci3:		ld	hl,(bittim) ; bit time
ci4:		dec	l
	jp	nz,ci4		; now wait one entire bit time
	dec	h
	jp	nz,ci4
	in	a,(serial_port) ; read serial character
	and	data_bit	; isolate serial data
	jp	z,ci6		; j if data is 0
	inc	a		; now register A=serial data
ci6:
	rra		; rotate it into carry
	dec	b		; dec bit count
	jp	z,ci5		; j if last bit
	ld	a,c		; this is where we assemble char
	rra			; rotate it into the character from carry
	ld	c,a
	nop			; delay so timing matches that in output
	;;  routine
	jp	ci3		; do next bit
ci5:
	ret

	
