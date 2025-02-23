; ============================================== ; 
; Describe:	save VRAM segment to the buffer
; Entry:	
; Exit:		
; Destroy:	
; ============================================== ;
saveBackground	proc
	
	push cx di si dx es ds		; save regs
	
	push cs			
	pop es				; set ES to the current segment

	push 0b800h
	pop ds				; set DS to VMEM 

	mov di, offset PAGE_BUFFER	; set di to page buff start pos
	mov si, (1 * 80 + 65) * 2	; set si to left top corner 

	mov dl, BORDER_HEIGHT + 2d	; set count of lines

	@@next:
		dec dl
		mov cx, BORDER_WIDTH + 2d
		rep movsw
		call shiftToNextLine_SI

	cmp dl, 0
	jne @@next

	pop ds es dx si di cx		; repair regs
	
	ret
		endp

; ======================================== ;
; Describe: 	shift to next line in DI
; Entry:	DI - offset of buffer
; Exit:		DI - pos of the next line
; Destroy:	None
; ======================================== ;
shiftToNextLine_DI	proc

	push ax				; save ax
	
	mov ax, di
	sub ax, (BORDER_WIDTH + 2) * 2
	add ax, 160d
	mov di, ax

	pop ax				; repair ax
	
	ret
			endp

; ======================================= ;
; Describe:	shift to next line in SI
; Entry:	SI - offset of border pos
; Exit:		SI - pos of the next line
; Destroy:	None
; ======================================= ;
shiftToNextLine_SI	proc

	push ax				; save ax
	
	mov ax, si
	sub ax, (BORDER_WIDTH + 2) * 2
	add ax, 160d
	mov si, ax

	pop ax				; repair ax
	
	ret

			endp

; ========================================= ;
; Describe:	repair segment of regs page
; Entry:	None
; Exit:		None
; Destroy:	None
; ========================================= ;
repairPage	proc

	push cx di si dx es ds		; save regs

	push cs				
	pop ds				; set ds to current segment

	push 0b800h
	pop es				; set es to VMEM

	mov si, offset PAGE_BUFFER	; set si to page buff start pos
	mov di, (1 * 80 + 65) * 2	; go to left top corner

	mov dl, BORDER_HEIGHT + 2d	; set count of lines

	@@next:
		dec dl
		mov cx, BORDER_WIDTH + 2d
		rep movsw
		call shiftToNextLine_DI

	cmp dl, 0
	jne @@next

	pop ds es dx si di cx		; repair regs
	
	ret
		
		endp