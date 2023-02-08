; draw a box

ctr:	equ	800H		; center value
drw:	equ	8000H		; draw flag

box	macro	off
	DW ctr-off, ctr-off
	DW drw+ctr+off, ctr-off
	DW drw+ctr+off, ctr+off
	DW drw+ctr-off, ctr+off
	DW drw+ctr-off, ctr-off
	endm

	db 60
	box 80H
	box 0c0H
	box 100H
	db 0ffh
	
