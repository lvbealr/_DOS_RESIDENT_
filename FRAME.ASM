; ========================================================== ;
; Desribe: 	print border line
; Entry:  	AH 		- background color attribute
;		DI 		- position on line
;		CX 		- count of internal symbols
;		BX 		- offset of memory
;	(as-ed) ES = 0b800h 	- videomem offset
; Exit:		None
; Destroy:	AL, DI, CX
; ========================================================== ;
printLine	proc

	mov al, byte ptr cs:[di]	; write first sym
	mov es:[bx], ax			
	add bx, 2d			; shift
	inc di				; increment pos in string

	mov al, byte ptr cs:[di]	;
	
	@@next:
		mov es:[bx], ax
		add bx, 2d
		loop @@next
		inc di

	mov al, byte ptr cs:[di]	; write ending sym
	mov es:[bx], ax
	add bx, 2d
	inc di

	ret
		endp


; =========================================================== ;
; Describe:	shift to the next line
; Entry:	BX - memory address
; Exit:		BX - position of the next line
; Destroy:	AX
; =========================================================== ;
shiftToTheNextLine	proc

	sub bx, (BORDER_WIDTH + 2) * 2d	; go to start of line
	add bx, 160d

	ret
			endp

; ========================================================== ;
; Describe:	draw a frame on the display
; Entry:	(assumed) ES = 0b800h - videomem offset
; Exit:		None
; Destroy:	
; ========================================================== ;
drawFrame	proc
	
	push ax bx cx di dx si		; save regs

	mov di, offset BORDER_STYLE	; set default border
	mov ah, PAGE_COLOR
	
	mov bx, (1 * 80 + 65) * 2	; go to left top corner
	mov cx, BORDER_WIDTH		
	call printLine			; draw first line

	mov si, offset REG_BUFFER	; set SI on the start of reg buffer
	mov dx, BORDER_HEIGHT

	@@next:
		dec dx
		
		mov cx, BORDER_WIDTH
		call shiftToTheNextLine
		call printLine

		sub bx, 20d
		call writeRegisterValue	; write register value
		add bx, 8d

		sub di, 3d
		
		cmp dx, 0
		jne @@next

		add di, 3d
		mov cx, BORDER_WIDTH
		call shiftToTheNextLine
		call printLine		; print ending line

		pop si dx di cx bx ax	; repair registers

		ret
		endp
