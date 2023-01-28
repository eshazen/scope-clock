
	org 9100h

start:	call	8106h		; call UMON getc
	call	9006h		; send to UART


	call	8109h		; call UMON putc
