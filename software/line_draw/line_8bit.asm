;;;
;;; line_8bit - first try at Bresenham's algorithm
;;;   For now use signed 8-bit values
;;;
;;; X0, Y0 in H, L
;;; X1, Y1 in D, E
;;;
;;; call plot with x,y in H,L to set a pixel
;;;	(must preserve all regs)
;;; A
;;; H, L	= x0, y0
;;; D, E	= x1, y1
;;; C		= sx
;;; B		= dx
;;; IXL		= sy
;;; IXH         = dy
;;; IYL		= error
;;; IYH		= e2
;;;
;;; NOTES:
;;; 1.  Here is the pseudo-code from Wikipedia
;;;    wrote a C version of this (using int16s to be sure) and it works
;;;
;;; 2.  error and e2 can overflow 8 bits.
;;;
;;; PSEUDO-CODE:
;;; plotLine(x0, y0, x1, y1)
;;;     dx = abs(x1 - x0)
;;;     sx = x0 < x1 ? 1 : -1
;;;     dy = -abs(y1 - y0)
;;;     sy = y0 < y1 ? 1 : -1
;;;     error = dx + dy
;;;     
;;;     while true
;;;         plot(x0, y0)
;;;         if x0 == x1 && y0 == y1 break
;;;         e2 = 2 * error
;;;         if e2 >= dy
;;;             if x0 == x1 break
;;;             error = error + dy
;;;             x0 = x0 + sx
;;;         end if
;;;         if e2 <= dx
;;;             if y0 == y1 break
;;;             error = error + dx
;;;             y0 = y0 + sy
;;;         end if
;;;     end while

	
;;; plotLine(x0, y0, x1, y1)
plotline:
;;;     dx = abs(x1 - x0)
;;;     sx = x0 < x1 ? 1 : -1
	ld	a,d		;get x1
	ld	c,1		;initialize sx in C to 1
	sub	e		;x1 - x0
	jp	p,plot1		;positive?
	neg			;nope, negate it
	ld	c,-1		;set sx in C to -1
plot1:				;now dx is in a, move to B
	ld	b,a		;now B=dx, C=sx
;;;     dy = -abs(y1 - y0)
;;;     sy = y0 < y1 ? 1 : -1
	ld	a,e	     ;get y1
	ld	ixl,-1	     ;initialize sy to -1
	sub	l	     ;y1-y0
	jp	m,plot2	     ;go if negative, leave it
	ld	ixl,1	     ;else set sy to 1
	neg		     ;else make it negative
plot2:			     ; -abs(y1-y0) in a
	ld	ixh,a	     ;IXH=dy, IXL=sy
;;;     error = dx + dy
	ld	a,b
	add	ixh
	ld	iyl,a
;;;     
;;;     while true
plot_loop:
;;;         plot(x0, y0)
	call	plot
;;;         if x0 == x1 && y0 == y1 break
	ld	a,h
	cp	d
	jr	nz,pnb
	ld	a,l
	cp	e
	jr	z,pbreak
pnb:	
;;;         e2 = 2 * error
	ld	a,iyl		;get error
	add	a		;2*error
	ld	iyh,a		;IYH=e2
;;;         if e2 >= dy
	sub	ixh		;e2-dy
	jp	c,endif1
;;;             if x0 == x1 break
	ld	a,h
	cp	d
	jr	z,endif1
;;;             error = error + dy
	ld	a,iyl
	add	ixh
	ld	iyl,a
;;;             x0 = x0 + sx
	ld	a,h
	add	c
	ld	h,a
;;;         end if
endif1:	
;;; 
;;;         if e2 <= dx
	ld	a,b
	sub	iyh		;dx-iyh
	jr	c,endif2
;;;             if y0 == y1 break
	ld	a,l
	cp	e
	jr	z,endif2
;;;             error = error + dx
	ld	a,iyl
	add	b
	ld	iyl,a
;;;             y0 = y0 + sy
;;;         end if
endif2:	
;;;     end while
	jr	plot_loop
pbreak:
	ret



plot:	ret

	
