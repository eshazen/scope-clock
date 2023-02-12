
	org	0c000h

	jp	start

get_hr:	db	0
get_min: db	0
get_sec: db 	0

start:		
	call	0b2cfh		;rtc_get

	ld	a,h
	ld	(get_hr),a
	ld	a,l
	ld	(get_min),a
	ld	a,e
	ld	(get_sec),a

	jp	8100h

	.end
	
