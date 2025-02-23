.model tiny
.386
.code
org 100h
locals @@

HOTKEY			equ 29h		; tilda scancode
CS_ADDRESS		equ 6d * 11d + 2d

END_OF_INTERRUPT	macro
			
			in al, 61h	; blink higher bit of kb controller reg
			or al, 80h
			out 61h, al
			and al, not 80h
			out 61h, al
		
			mov al, 20h	; send EOI signal to INT controller
			out 20h, al
			
			pop ax
			iret

			endm		
		
start:	jmp main

; ######### INCLUDE ######### ;
	include data.asm
	include frame.asm
	include page.asm
	include hex.asm
; ########################### ;


main	proc
	
;	// Get Interrupt Vector (09H - keyboard) -> ES:BX
	mov ax, 3509h
	int 21h
	mov cs:old09hOffset,  bx
	mov bx, es
	mov cs:old09hSegment, bx

; 	// Get Interrupt Vector (08H - timer) -> ES:BX

	mov ax, 3508h
	int 21h
	mov cs:old08hOffset,  bx
	mov bx, es
	mov cs:old08hSegment, bx

;	// Put New Address Of 09H To Interrupt Vector
	mov ax, 2509h
	mov dx, offset new09h
	int 21h

;	// Put New Address Of 08H To Interrupt Vector
	mov ax, 2508h
	mov dx, offset new08h
	int 21h

; 	// Terminate & Stay Resident (31h)
	mov ah, 31h
	mov dx, offset EOP
	shr dx, 4
	inc dx			; check dx!!!!!!!!!!!!!!!!!!!
	int 21h

	endp
	
new09h	proc
		
	push ax				; save regs

	in al, 60h			; listen port
	cmp al, HOTKEY			; check if HOTKEY is down
	jne skipFrame

	cmp cs:ACTIVATE_FLAG, 0d	; check if flag is on
	jne skipSaving

	call saveBackground		; save background
	
	skipSaving:

	not cs:ACTIVATE_FLAG
	
	cmp ACTIVATE_FLAG, 0d		; check if flag is on
	jne skipRepairing

	skipRepairing:
	call repairPage

	END_OF_INTERRUPT		; blink higher bit of kb controller
					; register and send EOI signal to 
					; interrupt controller

	skipFrame:
	cmp al, HOTKEY + 127d		; check if HOTKEY is up
	jne skipUpHotkey

	END_OF_INTERRUPT		; blink higher bit of kb controller
					; register and send EOI signal to
					; interrupt contoller

	skipUpHotKey:

	pop ax

	db 0eah				; call default interrupt
	old09hOffset  dw 0
	old09hSegment dw 0
	
	endp
	

new08h	proc
		
	cmp cs:ACTIVATE_FLAG, 0d	; check if flag is on
	je @@skipDraw

	call saveRegisters		; save registers
	
	push es				; save ES
	
	push 0b800h			; videomem
	pop es
	call drawFrame
	
	pop es				; repair es
		
	@@skipDraw:			; call default interrupt
	db 0eah
	old08hOffset  dw 0
	old08hSegment dw 0

	endp

EOP:					; save size of code

end	start