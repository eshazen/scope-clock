;;; ------------------------------------------------------------
;;; console.asm: Console I/O
;;;
;;; assumes putc, getc
;;;
;;; toupper - convert A to uppercase
;;; space   - print a space
;;; crlf    - send CR/LF
;;; puts    - output C style string from HL
;;; gets    - read console string to HL like C gets()
;;; ------------------------------------------------------------

;;; convert A to uppercase
toupper: cp	'a'
	ret	c
	cp	'z'+1
	ret	nc
	and	5FH
	ret
	
;;; output space
space:	ld	a,' '
	jr	putc

;;; output CR/LF
crlf:	ld	a,13
	call 	putc
	ld	a,10
	jr	putc

;;; output null-terminated string from HL
;;; return with HL pointing past null
puts:	ld	a,(hl)
	inc	hl
	or	a
	ret	z
	call	putc
	jr	puts

;;; read string from console to HL
;;; stop on CR/LF/ESC
;;; null-terminate the string without the terminating control char
;;; return the control character in A
;;; only accept up to BC bytes
;;; used:  A + 3 stack levels
;;;
;;; starting some support for readline-like editing
;;; ^P and ^N are special- clear the buffer and store only the ctrl char
;;;   at the start of the buffer, then NUL and return

gets:	push	de
	push	hl
	push	bc
	
	ld	d,h		;buffer pointer to DE for reference
	ld	e,l
	
	add	hl,bc		;hl now points to buffer limit

	ld	b,h
	ld	c,l		;limit to BC
	
	dec	bc		;adjust limit to leave room for null terminator
	ld	h,d
	ld	l,e		;now: HL=buff BC=limit DE=buff

gets0:	
	call	getc
	call	toupper		;force all input to uppercase for now
	cp	0dh		;check for CR
	jr	z,gets1
	cp	0ah		;check for LF
	jr	z,gets1
	cp	1bh		;check for ESC
	jr	z,gets1
	cp	08h		;check for BS
	jr	z,gets3
	cp	0eh		;check for ^N
	jr	z,gets4
	cp	10h		;check for ^P
	jr	z,gets4
	cp	20h		;check for printable
	jr	nc,gets2	;store only printable
	jr	gets0
	;; handle backspace
gets3:
	or	a		;clear CY
	push	HL
	sbc	HL,DE		;are we at the beginning?
	pop	HL
	jr	z,gets0		;yes, no backspace
	;; perform the backspace
	ld	a,8
	call	putc		;echo the backspace
	ld	(hl),0		;null-terminate here
	dec	hl
	jr	gets0

	;; try to store a printable char
gets2:	
	;; check if at end of buffer
	push	hl
	or	a
	sbc	hl,bc
	pop	hl
	jr	z,gets0

	call	putc		;echo the char
	ld	(hl),a		;store it
	inc	hl		;increment
	;; should really check for buffer overflow here
	jr	gets0
	
gets1:	ld	(hl),0
	push	af
	call	crlf
	pop	af

getsb:	pop	hl
	pop	de
	pop	bc
	
	ret
	
;;; store A at start of buffer, then NUL and return
gets4:	ld	(hl),a		;store control char
	inc	hl
	jr	gets1