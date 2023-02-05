;;; display_list.asm - send display list to DACs
;;;
;;; HL points to list, 4 bytes X/Y per point
;;;   <x_value>  <y_value>
;;;   <x_value>  <y_value>
;;;     ...
;;;   0000       ----        flags end
;;;
	org	0a000h

dac_x:	equ	9124h
dac_y:	equ	9127h

	jmp	main
	jmp	display_list

list:	
	include	'list.asm'

main:	ld	hl,list
	call	display_list

	jr	main

display_list:
	ld	e,(hl)		;X LSB
	ld	a,e
	inc	hl
	ld	d,(hl)		;X MSB
	or	d		;zero?
	ret	z		;done
	
	inc	hl		;point to Y LSB
	ex	de,hl		;swap pointer to DE
	call	dac_x		;output X

	ex	de,hl		;restore pointer
	ld	e,(hl)		;Y LSB
	inc	hl
	ld	d,(hl)		;Y MSB
	inc	hl
	ex	de,hl		;pointer to DE
	call	dac_y		;output Y

	ex	de,hl		;pointer to HL
	jr	display_list

	
