;;;
;;; simple Z80 monitor
;;;
;;; d <addr> <count>           dump memory
;;; e <addr> <dd> <dd>...      edit up to 16 bytes in memory
;;; o <port> <val>             output <val> to <port>
;;; z <val>		       set port zero value bits 0-6
;;; i <port>                   input from <port> and display
;;; g <addr>                   goto addr
;;; b <addr>                   set breakpoint (currently 3-byte call)
;;; a <val1> <val2>            hex Arithmetic
;;; c                          continue from breakpoint
;;; c <addr>                   continue, set new breakpoint
;;; m <start> <end> <size>     memory region compare
;;; p <start> <end> <size>     memory region copy
;;; r                          display stored regs
;;; r <reg> <val>              edit stored regs
;;; l			       binary load
;;; /			       repeat last command
;;; 
;;; calculator hardware
;;; f <addr>                   dump HP registers from <addr> (A)
;;; k                          scan keyboard
;;; 7 <addr>		       update 7-segment display from <addr>
;;; V <addr>                   update VFD display from <addr>
;;;
;;; scope hardware
;;; s <Xvalue> <Yvalue>	       set scope X, Y dac values
;;; 
;;; 
;;; New version, mostly new comments and modularity
;;; intended to be more portable, and include all features
;;; Fixes:  	GOTO now pushes breakpoint, sets regs
;;; 		register edit/display
;;;		bit-bang serial preserves register 0 bits 0-6

;;; ---------- compile options ----------
calc_hw equ	0		; support for calculator hardware
readline equ	1		; GNU-readline like command recall
debug	equ	0		; some debug support
scope	equ	1		; support for scope expansion board
	
; 	org	08100H
 	org	9100H	

stak:	equ	$		;stack grows down from start

;;; jump table for useful entry points
jump_table:	
	jmp	main		;0  cold start
	jmp	save_state	;1  save state (breakpoint)
	jmp	getc		;2  read serial input to A
	jmp	putc		;3  output serial from A
	jmp	crlf		;4  output CR/LF
	jmp	puts		;5  output string from HL
	jmp	phex2		;6  output hex byte from A
	jmp	phex4		;7  output hex word from HL
	jmp	0000h		;8  marks end of table for error check

;;; ---- data area (must be in RAM)  ----

jumptbl: dw	jump_table	;default jump table for 'f' command

;;; save CPU state coming from extrnal prog
savein:	db	0,0,0		;instruction overwritten by breakpoint
savead:	dw	0		;address of breakpoint
savesp:	dw	0		;caller's stack pointer

;;; saved registers
saviy:	dw	0
savix:	dw	0

savhlp:	dw	0
savdep:	dw	0
savbcp:	dw	0
savafp:	dw	0
	
savhl:	dw	0
savde:	dw	0
savbc:	dw	0
savaf:	dw	0
	
savetop: equ	$

bufsiz:	equ	60		;command buffer size

;;; readline-style recall buffers
if readline
nrecall: equ	3		;number of recall buffers
	
recbuf:	rept	nrecall
	rept	bufsiz
	db	0
	endm
	endm

recptr:	dw	0
	
endif	
	
lastc:	db	0		;last command byte

buff:	rept	bufsiz
	db	0
	endm

bend:	equ	$		;mark the end

maxarg:	equ	18		;maximum number of arguments
argc:	db	0
	
argv:	rept	maxarg*2
	dw	0
	endm
	
iargv:	rept	maxarg*2
	dw	0
	endm

	INCLUDE "s19200.asm"	
	INCLUDE "console.asm"	; gets, puts, space, crlf etc
	INCLUDE "hex.asm"	; hex I/O
	INCLUDE "strings.asm"	; strtok()
;	INCLUDE "c-link.asm"
if calc_hw	
	INCLUDE "vfd.asm"
	INCLUDE "diskey.asm"
endif	
if scope
	INCLUDE "scope.asm"
endif	

banner:	db	"UMON v0.9b ORG ",0
error:	db	"ERROR",0
	
usage:  db      "h                     print this help", 13, 10
        db      "d <addr> <count", 13, 10
        db      "d <addr> <count>      dump memory", 13, 10
        db      "e <addr> <dd> <dd>... edit up to 16 bytes in memory", 13, 10
        db      "o <addr> <val>        output <val> to port <addr>", 13, 10
        db      "z <val>               set port zero value bits 0-6", 13, 10
        db      "i <addr>              input from <addr> and display", 13, 10
        db      "g <addr>              goto addr", 13, 10
        db      "b <addr>              set breakpoint (currently 3-byte call)", 13, 10
        db      "a <val1> <val2>       hex Arithmetic", 13, 10
        db      "g <addr>              dump HP registers from <addr> (A)", 13, 10
	db	"m <ad1> <ad2> <n>     memory compare", 13, 10
	db	"p <ad1> <ad2> <n>     memory copy", 13, 10
	db	"r                     display stored regs", 13, 10
	db      "r <reg> <val>         edit stored regs", 13, 10
        db      "c                     continue from breakpoint", 13, 10
        db      "l                     binary load", 13, 10
	db	"f <func>              call function from jump table", 13, 10
	db      "j [<addr>]            set/display jump table start addr", 13, 10
        db      "^P                    repeat last command", 13, 10
if calc_hw	
        db      "k                     scan keyboard", 13, 10
        db      "7 <addr>              update LED display from <addr>", 13, 10
        db      "V <addr>              update VFD display (0=blank)", 13, 10
endif	
if scope
	db	"s <DACX> <DACY>       set scope DAC values", 13, 10
endif	
	db	0

;;; -------------------- MAIN entry point --------------------
	
	;; set stack, display banner, print code range
main:	ld	sp,stak
	ld	hl,banner
	call	puts
	ld	hl,stak
	call	phex4
	call	space
	ld	hl,umontop
	call	phex4
	call	crlf
	
loop:	ld	a,'>'		;prompt
	call	putc

	;; get command
	ld	hl,buff
	ld	bc,bend-buff	; maximum size
	call	gets

if debug
	;; dump buffer
	ld	hl,buff
	ld	b,bend-buff
	call	hdump
endif	
	;; check for ^P
	ld	a,(buff)
	cp	a,10h
	jr	nz,not_rept
	;; we got a ^P
if readline
	;; recall buffer
	ld	hl,recbuf
	ld	de,buff
	ld	bc,bufsiz
	ldir
	;; pull the recall stack down
	ld	hl,recbuf+bufsiz
	ld	de,recbuf
	ld	bc,bufsiz*(nrecall-1)
	ldir
	;; print the current buffer
	ld	hl,buff
	call	puts
not_rept:	
	;; not a ^P, store in recall stack
	;; first move everything in stack up
	ld	hl,recbuf
	ld	de,recbuf+bufsiz
	ld	bc,bufsiz*(nrecall-1)
	ldir

	;; now copy buffer to stack
	ld	hl,buff
	ld	de,recbuf
	ld	bc,bufsiz
	ldir
else
	;; restore last command byte
	ld	a,(lastc)
	ld	(buff),a
not_rept:
endif	
	;; parse string into tokens at argc / argv
	ld	hl,buff
	ld	de,argv
	ld	b,maxarg
	call	strtok	
	ld	a,c
	ld	(argc),a

	;; convert tokens to integers
	ld	hl,argv
	ld	de,iargv
	ld	b,a
	call	cvint

	ld	hl,buff		;parse command character
	ld	a,(hl)
	ld	(lastc),a	;save for possible repeat

	cp	a,'D'		;dump memory
	jz	dump

	cp	a,'H'
	jz	help

	cp	a,'A'
	jz	arith

	cp	a,'E'
	jz	edit

	cp	a,'B'
	jz	brkpt

	cp	a,'C'
	jz	continu

	cp	a,'G'
	jz	goto

	cp	a,'L'
	jz	binary
	
	cp	a,'O'
	jz	output

	cp	a,'R'
	jz	edit_regs

	cp	a,'I'
	jz	input

	cp	a,'Z'
	jz	zero

	cp	a,'F'
	jz	call_func

	cp	a,'J'
	jz	set_jumptbl

;;; ---------- calculator-specific commands ----------
if calc_hw	
	cp	a,'F'
	jz	hpdump

	cp	a,'K'
	jz	kbtest

	cp	a,'7'
	jz	dptest

	cp	a,'V'
	jz	vfdtest
endif
;;; --------------------------------------------------

;;; ---------- Scope commands ----------
	cp	a,'S'
	jz	scope_dacs
;;; ----------------------------------------
	
	cp	a,'M'
	jz	memcmp

	cp	a,'P'
	jz	memcpy
	
errz:	ld	hl,error
	call	puts
	call	crlf
	
	jp	loop

quit:	jp	0

;;; ---------- calculator hardware support ----------
if calc_hw	
kbtest:	call	kbscan
	call	phex4
	call	crlf
	jp	loop

dptest:	ld	hl,(iargv+2)
	call	display
	jp	loop

vfdtest: call	vfd_init	;initialize (and blank) VFD display
 	ld	hl,(iargv+2)	;get address to display from
	ld	a,h		;check for zero (blank)
	or	l
	jp	z,loop		;zero, leave display blanked
	
	call	vfd_display	;else update the display
	jp	loop
endif	
	

;;; set port zero value
zero:	ld	a,(iargv+2)
	call	setport0
	jp	loop

help:	ld	hl,usage
	call	puts
	jp	loop


;;; set jump table address for successive 'F' commands
;;;    no args:  display
set_jumptbl:
	ld	a,(argc)
	cp	1
	jr	nz,setjtb1
	;; display
	ld	hl,(jumptbl)
	call	phex4
	call	crlf
	jp	loop

setjtb1: cp	2
	jp	nz,errz
	ld	hl,(iargv+2)
	ld	(jumptbl),hl
	jp	loop


;;; call function from jump table, first restoring regs
;;; check for end of table as 'JP 0000' for error
call_func:
	ld	a,(argc)	;check for value
	cp	2
	jp	nz,errz

	;; count size of table
	ld	hl,(jumptbl)
	ld	b,0
	
cfttz:	inc	hl		;point past jump
	ld	e,(hl)		;get LSB
	inc	hl		;point to MSB
	ld	d,(hl)		;get MSB
	inc	hl		;point to next entry
	inc	b
	ld	a,d
	or	e		;test for zero
	jr	nz,cfttz
	;; now B has table size including zero
	ld	a,b
;	call	phex2
;	call	crlf

	ld	hl,save_state	;user returns to here
	push	hl
	ld	a,(iargv+2)	;get function code
	cp	b		; func code - max
	jp	nc,errz

	ld	e,a		;to DE
	ld	d,0
	ld	hl,(jumptbl)
	add	hl,de		;multiply by 3
	add	hl,de
	add	hl,de
	jp	gother		;go restore state, call (hl)


;;; simple multiplication HL = B * C
;;; uses AF
mult8x8: inc	b		;check for B=0 without disturbing anything
	dec	b
	ret	z

	push	de
	push	bc
	ld	hl,0
	ld	d,0
	ld	e,c
mult1:	add	hl,de
	djnz	mult1
	pop	bc
	pop	de
	ret

;;; ---------- register edit ----------


;;; edit/display registers in memory (at 'saveiy')
;;; no args = display all regs
;;; first arg is register name:  AF, BC, DE, HL, A', B', D', H', IX, IY
;;; second arg is 16-bit value
edit_regs:
	ld	a,(argc)	;get for two args
	cp	3
	jp	nz,view_regs	;nope, just display regs
	;; search for register name as 2nd argument
	ld	hl,(argv+2)	;pointer to register name from command line
	ld	d,(hl)		;get first char
	inc	hl
	ld	e,(hl)	      ;get 2nd char
	ld	hl,reg_names	;list of names for compare
	ld	b,10		;number of register name bytes
	
	;; lookup 16-bit register name from list
regnam:
	ld	a,d		;get first char
	cp	(hl)		;compare it
	inc	hl		;advance ptr (no flags changed)
	jr	nz,regnm	;didn't match

	ld	a,e		;get 2nd char
	cp	(hl)		;compare
	inc	hl
	jr	z,regfound
	
regnxt:	djnz	regnam
	
	jp	badreg

regnm:	inc	hl		;skip 2nd char
	jr	regnxt		;go loop

	;; reg name not found
	;; display it
badreg:	ld	hl,badreg_msg
	call	puts
	ld	hl,(argv+2)
	ld	a,''''
	call	putc
	ld	a,(hl)
	call	putc
	inc	hl
	ld	a,(hl)
	call	putc
	ld	a,''''
	call	putc
	call	crlf
	jp	loop

badreg_msg:	db 'BAD REG',13,10,0

view_regs:
	call	display_regs
	jp	loop

;;; register name at HL-2 matches
regfound:	
	dec	hl
	dec	hl
	or	a		;clear CY
	ld	de,reg_names
	sbc	hl,de		;now we have offset into registers stored at saviy
	ld	de,saviy	;offset by two since HL points past match
	add	hl,de		;point to stored reg value
	ld	de,(iargv+4)	;get new value

	ld	(hl),e		;change the stored value
	inc	hl
	ld	(hl),d
	
	jp	loop

reg_names:
	db	'IY', 'IX', 'H''', 'D''', 'B''', 'A''', 'HL', 'DE', 'BC', 'AF'

	
;;; -----------------------------------




;;; output to port
output:	ld	a,(iargv+2)
	ld	c,a
	ld	a,(iargv+4)
	out	(c),a
	jp	loop

;;; input from port
input:	ld	a,(iargv+2)
	ld	c,a
	in	a,(c)
	call	phex2
	call	crlf
	jp	loop

	;; continue after breakpoint
	;; check if there is one first
	;; clears breakpoint as part of the process
continu: ld	hl,(savead)
	ld	a,l
	or	h
	jp	z,nobrk		;go if not set
	ld	de,0
	ld	(savead),de	;mark as cleared

	ex	de,hl		;address to HL
	
	;; first restore the instruction saved
	ld	hl,savein
	ldi
	ldi
	ldi

	;; optionally, set a new breakpoint
	ld	a,(argc)
	cp	2
	jr	nz,restore_state

	;; set new breakpoint
	ld	hl,(iargv+2)
	call	brkat
	
	call	phex4
	ld	hl,msgset
	call	puts

	;; restore the machine state
restore_state:	
	ld	sp,saviy

	pop	iy
	pop	ix

	pop	hl
	pop	de
	pop	bc
	pop	af
	exx
	ex	af,af'
	
	pop	hl
	pop	de
	pop	bc
	pop	af

	ld	sp,(savesp)	;get back caller's stack
	ret			;should to back to BP locn

	
;;; set breakpoint
brkpt:	ld	a,(argc)
	cp	2		;single numeric argument?
	jr	z,brkset

	;; clear breakpoint if set
brkclr:	ld	hl,(savead)
	ld	a,l
	or	h
	jr	z,nobrk		;go if not set

	call	phex4
	ld	hl,msgclr
	call	puts

	ld	hl,(savead)
	ex	de,hl
	ld	hl,savein
	ldi
	ldi
	ldi

	ld	hl,0
	ld	(savead),hl	;erase saved address

	jp	loop

	;; check for breakpoint already set
brkset:	ld	hl,(savead)
	ld	a,h
	or	l
	jr	nz,brkovr	;attempt to overwrite breakpoint

	ld	hl,(iargv+2)	;breakpoint goes here
	call	brkat
	call	phex4
	ld	hl,msgset
	call	puts

	jp	loop

brkat:	
	push	hl		;save locn
	ld	(savead),hl	;set brkpt locn
	ld	de,savein	;save area for 3-byte instruction
	ldi
	ldi
	ldi			;copy 3 bytes
	pop	hl		;get locn back
	push	hl
	ld	(hl),0cdh	;CALL
	inc	hl
	ld	de,save_state	;target for call
	ld	(hl),e
	inc	hl
	ld	(hl),d
	pop	hl
	ret

brkovr:	ld	hl,msgovr
	call	puts
	jp	loop

nobrk:	ld	hl,msgno
	call	puts
	jp	loop

msgset:	db	' SET', 13, 10, 0
msgno:	db	'NO BKPT', 13, 10, 0
msgclr:	db	' CLEARED', 13, 10, 0
msgovr:	db	'BKPT ALREADY SET CLEAR FIRST', 13, 10, 0


;;; start binary loader
;;; expect binary words (LSB first):
;;;    0x5791, <addr>, <count>
;;; then <count> data bytes
;;; does not jump after, just returns to prompt
;;; if header not seen after a few bytes, bail out
;;;
;;; echo back all received
;;; 
binary:	ld	b,5		;max bad bytes
	;; read chars until 5 received or 0x91 seen
bin1:	call	getc
	call	putc
	cp	0x91		;first magic byte?
	jr	z,bin1a
	djnz	bin1
	jp	errz
	
	;; read chars, skipping repeat 0x91, wait for 0x57
bin1a:	call	getc
	call	putc
	cp	0x91
	jr	z,bin1a
	cp	0x57
	jp	nz,errz
	
	;; get address to hl
	call	getc
	call	putc
	ld	l,a
	call	getc
	call	putc
	ld	h,a
	ld	(iargv),hl
	;; get count to bc
	call	getc
	call	putc
	ld	c,a
	call	getc
	call	putc
	ld	b,a
	ld	(iargv+2),bc
	;; read and store data
bin2:	call	getc
	call	putc
	ld	(hl),a
	inc	hl
	dec	bc
	ld	a,b
	or	c
	jr	nz,bin2

	;; leave addr, count in iargv+2, iargv+4
	;; display them too
	ld	hl,(iargv)
	call	phex4
	call	crlf
	ld	bc,(iargv+2)
	add	hl,bc
	call	phex4
	call	crlf
	jp	loop

;;; jump to 1st arg
;;; set up stack to return to UMON
;;; restore registers from stored values
goto:	ld	a,(argc)
	cp	2
	jp	c,errz
	ld	hl,(iargv+2)
	ld	de,showstate
	;; set up the stack:  first, a return address in case user executes a RET
	push	de
	;; now the user specified address from the command line
gother:	push	hl
	ld	(savesp),sp	;save caller's stack pointer
	jp	restore_state
	

;;; edit values into memory
edit:	ld	a,(argc)
	cp	a,3		;need at least 3 args
	jp	c,errz

	sub	a,2
	ld	b,a		;count of bytes to store

	ld	hl,(iargv+2)	;get address
	ld	ix,iargv+4	;pointer to first data item

eloop:	ld	a,(ix)
	ld	(hl),a
	inc	hl
	inc	ix
	inc	ix
	djnz	eloop
	jp	loop

;;; dump some memory
dump:	ld	hl,(iargv+2)	;first arg
	ld	a,(iargv+4)	;second arg
	
	ld	b,a		;count
	call	hdump
	jp	loop

;;; hex dump B bytes from HL
	;; see if we need to print the address
	;; either on 16-byte boundary, or first address
hdump:	call	haddr		;always print first address
	jr	bite		;skip the 16-byte test

hdump2:	ld	a,l
	and	0xf
	call	z,haddr

bite:	ld	a,(hl)
	inc	hl
	call	phex2
	call	space

noadr:	djnz	hdump2
	call	crlf
	ret

;;; print address in HL
haddr:	push	hl
	call	crlf
	call	phex4
	ld	a,':'
	call	putc
	call	space
	pop	hl
	ret

;;; do hex arithmetic
arith:	ld	hl,(iargv+2)	;first arg
	ld	de,(iargv+4)	;second arg
	
	add	hl,de
	call	phex4
	call	space
	ld	hl,(iargv+2)	;first arg
	ld	de,(iargv+4)	;second arg
	or	a		;clear CY
	sbc	hl,de
	call	phex4
	call	crlf
	jp	loop

;;; ---------- HP register display ----------
if calc_hw	
;;; HP calculator word size
wsize:	equ	14
;;; register names
hpregs:	db	"ABXYZT12", 0

;;; dump HP registers
;;; all 14 nibbles:  A, B, X, Y, Z, T, M1, M2
hpdump:	ld	hl,(iargv+2)	;first arg
	ld	de,wsize
	ld	ix,hpregs
	
hpd1:	ld	a,(ix)		;get register name
	inc	ix
	or	a		;Z=done
	jp	z,loop

	call	putc		;display reg name
	call	space		;space
	call	hpreg		;display reg
	jr	hpd1

;;; display HP register from (HL)
;;; de must be WSIZE (14)
;;; save bc, advance HL past reg
hpreg:	push	hl
	push	bc
	ld	b,wsize
	add	hl,de		;point to next reg
hpr1:	dec	hl
	ld	a,(hl)
	call	phex1
	djnz	hpr1
	pop	bc
	pop	hl
	add	hl,de
	call	crlf
	ret
;;; ----------------------------------------
endif	




;;; ---------------Scope hardware---------------------
scope_dacs:
	ld	hl,(iargv+2)	;get X value
	call	dac_x
	ld	hl,(iargv+4)	;get Y value
	call	dac_y
	jp	loop
	
;;	ld	a,(argc)
;;	cp	a,2		;need minimum 2 args
;;	jp	c,errz
;;	ld	hl,(iargv+2)	;get X value
;;	call	dac_x
;;	ld	a,(argc)
;;	cp	a,3
;;	jr	z,scopey	;go if different Y value
;;scop1:	call	dac_y
;;	
;;	jp	loop
;;
;;scopey:	ld	hl,(iargv+4)
;;	jr	scop1

;;; --------------------------------------------------
	


	
altban:	db	"BREAK ",0	

;;; ---------- breakpoint entry ----------
;;; Save machine state and display it
;;; Restore code at breakpoint
;;; --------------------------------------
save_state:	
	;; get the return address and save it
	ex	(sp),hl		;return address to HL
	dec	hl
	dec	hl
	dec	hl		;back up over breakpoint call
	ex	(sp),hl		;put back on caller's stack
showstate:	
	ld	(savesp),sp	;save caller's SP
	;; reset the stack to the save area
	ld	sp,savetop
	;; save primary regs
	push	af
	push	bc
	push	de
	push	hl
	;; save alternate regs
	exx
	ex	af,af'
	push	af
	push	bc
	push	de
	push	hl
	;; save IX, IY
	push	ix
	push	iy
	
;;; cold start with alternate banner, display struct address
	ld	sp,stak		;restore UMON stack
	ld	hl,altban
	call	puts
	;; display breakpoint location
	ld	hl,(savead)
	call	phex4
	call	crlf
	
	call	display_regs		;display regs from state
	jp	loop
	
;;; display machine state from stored values
display_regs:
	ld	hl,(savaf)
	ld	de,'AF'
	call	pregn

	ld	hl,(savbc)
	ld	de,'BC'
	call	pregn

	ld	hl,(savde)
	ld	de,'DE'
	call	pregn

	ld	hl,(savhl)
	ld	de,'HL'
	call	pregn

	call	crlf

	;; alternate regs
	ld	hl,(savafp)
	ld	de,'A'''
	call	pregn

	ld	hl,(savbcp)
	ld	de,'B'''
	call	pregn

	ld	hl,(savdep)
	ld	de,'D'''
	call	pregn

	ld	hl,(savhlp)
	ld	de,'H'''
	call	pregn
	call	crlf

	ld	hl,(savix)
	ld	de,'IX'
	call	pregn

	ld	hl,(saviy)
	ld	de,'IY'
	call	pregn

	ld	hl,(savesp)
	ld	de,'SP'
	call	pregn
	
	call	crlf

	ex	af,af'		;back to primary regs
	exx

	ret
	
;;; copy memory
memcpy:	call	load3w
	ldir
	jp	loop

;;; compare memory
;;; up to 16 errors then stop
memcmp:	call	load3w
memcp1:	ld	a,(de)
	cp	a,(hl)
	jr	nz,nocmp
memnxt:	inc	hl
	inc	de
	dec	bc
	ld	a,b
	or	c
	jr	nz,memcp1
	jp	loop

	;; display memory mismatch
nocmp:	call	phex4		;display hl
	call	space
	ld	a,(hl)
	call	phex2
	call	space
	ex	de,hl
	call	phex4		;display hl
	call	space
	ld	a,(hl)
	call	phex2
	ex	de,hl
	call	crlf
	jr	memnxt
	
;;; load hl, de, bc from 3 arguments for compare/copy
load3w:	ld	hl,(iargv+2)	;source
	ld	de,(iargv+4)	;dest
	ld	bc,(iargv+6)	;count
	ret

;;; display reg name from de, value from hl
pregn:	
	call	space
	ld	a,e
	call	putc
	ld	a,d
	call	putc
	ld	a,':'
	call	putc
	call	phex4
	call	space
	ret

	
umontop:	equ	$
	
	.end
