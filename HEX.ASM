; ========================================== ;
; Describe:	convert digit to hex
; Entry:	AL - number (0 - 15)
; Exit:		AL - number (0x00 - 0x0F)
; Destroy:	None
; ========================================== ;
digitToHex	proc
	
	add al, '0'	; (0x30)

	cmp al, '9'	; (0x39)
	jbe @@end

	add al, 7	; go to A - F (0x41)

	@@end:
		
	ret

		endp

; =============================================== ;
; Describe:	convert byte to hex number string
; Entry:	AL - byte
; Exit:		DI - buffer of string (2 symbols)
; Destroy:	None
; =============================================== ;
byteToHexStr	proc
	
	push ax		; save ax
	
	mov ah, al
	shr al, 4	; get higher digit
	
	call digitToHex

	mov cs:[di], al	; add digit to string
	inc di
	
	mov al, ah
	and al, 0fh	; get lower digit
	
	call digitToHex

	mov cs:[di], al	; add digit to string
	inc di

	pop ax		; repair ax

	ret
		endp

; =============================================== ;
; Describe:	convert word into hex string
; Entry:	AX - word
; Exit:		DI - buffer of string (4 symbols)
; Destroy:	None
; =============================================== ;
wordToHexStr	proc
	xchg ah, al
	call byteToHexStr
	
	xchg ah, al
	call byteToHexStr

	ret
		endp

; ================================================ ;
; Describe:	save all registers into REG_BUFFER
; Entry:	All registers
; Exit:		None
; Destroy:	None
; ================================================ ;
saveRegisters	proc

	call saveCS_IP
	
	push ax cx di				; save ax, cx, di
	push ss es ds bp sp di si dx cx bx ax	; save all regs to stack

	mov di, offset REG_BUFFER		; save regs to REG_BUFFER
	mov cx, 11d

	@@next:
		pop ax
		add di, 2d
		call wordToHexStr

	loop @@next

	pop di cx ax				; repair ax, cx, di
	
	ret
		endp

; ====================================== ;
; Describe:	save CS and IP registers
; Entry:	CS, IP
; Exit:		None
; Destroy:	None
; ====================================== ;
saveCS_IP	proc

	push di bp ax			; save di, bp, ax regs

	mov bp, sp			; get real CS pos in stack
	add bp, 12d			; pos of CS value in stack

	mov ax, word ptr [bp]		; save cx value in ax

	mov di, offset REG_BUFFER	; set di on start of reg buff
	add di, CS_ADDRESS		

	call wordToHexStr		; save CS in reg buff
	
	add di, 2d			; go to ip pos in buff
	sub bp, 2d			; get real ip pos in stack

	mov ax, word ptr [bp]		; save ip value in ax
	
	call wordToHexStr		; save ip in reg buff

	pop ax bp di

	ret
		endp

; ============================================= ;
; Describe:	print register value into frame
; Entry:	SI - position of 6 symbols
;		BX - position on display
; Exit:		None
; Destroy:	None
; ============================================= ;
writeRegisterValue	proc
	
	push cx ax			; save cx, ax
	
	mov cx, 6d			; out 6 symb from reg buff

	@@next:
		mov al, cs:[si]
		mov es:[bx], al
		inc si
		add bx, 2d
	loop @@next

	pop ax cx			; repair ax, cx
	
	ret
			endp