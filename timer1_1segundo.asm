;**********TIMER 1 por poleo******************************		
		PROCESSOR 16f887
		INCLUDE P16F887.INC
;*************BITS DE CONFIGURACION*************
		__CONFIG _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
	   	__CONFIG _CONFIG2, _WRT_OFF & _BOR21V

count 	equ 	0x20 ;Counter variable
		org 0 ; Start program at address 000
		nop ; Required for debugger
;********************** Initialize PORT D to be all outputs.********

Start	bsf 	STATUS,RP0 ; Go to BANK 1 by setting
		bcf 	STATUS,RP1 ; RP1, RP0 = 01.
		clrf 	TRISD ; Set Port D for output.
		bcf 	STATUS,RP0 ; Go back to bank 0!
		clrf 	PORTD ; Write 0s to Port D.
		clrf 	count ; Initialize count to 0.
;**************** Setup timer 1**********************************
		bcf 	T1CON,TMR1ON ; Turn Timer 1 off.
		bsf 	T1CON,T1CKPS1 ; Set prescaler for divide
		bsf 	T1CON,T1CKPS0 ; by 8.
		bcf 	T1CON,T1OSCEN ; Disable the RC oscillator.
		bcf 	T1CON,TMR1CS ; Use the Fosc/4 source.
		clrf 	TMR1L ; Start timer at 0000h
		clrf 	TMR1H ;
		bsf 	T1CON,TMR1ON ; Start the timer
;************* Wait in a loop until the timer finishes*****************
time1 	btfss	 PIR1,0 ; Did timer overflow?
		goto time1 ; Wait if not.
;*********Timer overflowed, increment counter and display
		bcf 	PIR1,0 ; Clear the flag
		incf 	count,F ; Bump the counter
		movf 	count,W ; Get the count
		movwf 	PORTD ; Send to Port D.
		bcf 	T1CON,0 ; Turn the timer off.
		movlw	 80h ; Start timer at 8000h
		movwf	 TMR1H
		clrf 	TMR1L
		bsf 	T1CON,0 ; Turn the timer on.
		goto 	time1
End