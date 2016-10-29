			PROCESSOR	16F887
			INCLUDE		P16F887.INC

			__CONFIG _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
	   		__CONFIG _CONFIG2, _WRT_OFF & _BOR21V

CONT		EQU			020
RES_W		EQU 			07E
RES_S		EQU			07F
SU		EQU			07D
			ORG			0
			GOTO		INICIO
			ORG			4
			GOTO		INTERRUPTION_TMR
;---------------------------------------
INICIO
;-----------PORTB----------------------
			CLRF		CONT
			BSF			STATUS,RP0
			BSF			STATUS,RP1
			MOVLW		B'00000000'
			MOVWF		ANSELH
			BCF			STATUS,RP1
			BCF			TRISB,0
;-----------TMR0--------------------
			MOVLW		0D2
			MOVWF		OPTION_REG
			BCF			STATUS,RP0
			BSF			INTCON,T0IE
			BSF			INTCON,GIE
			MOVLW		0FA
			MOVWF		TMR0
CICLO
			NOP
			NOP
			NOP
			NOP	
			GOTO		CICLO
;--------------------------------

RESPALDO_1
		 MOVWF	RES_W
		 SWAPF STATUS, W
		 MOVWF RES_S
		 RETURN
RESPALDO_2
		SWAPF RES_S,W ;Swap STATUS_TEMP register into W
		MOVWF STATUS ;Move W into STATUS register
		SWAPF RES_W,F ;Swap W_TEMP
		SWAPF RES_W,W ;Swap W_TEMP into W
		RETURN

INTERRUPTION_TMR
			CALL RESPALDO_1
			CALL SI
			MOVLW		0FA
			MOVWF		TMR0
			INCF		CONT,F
			BCF			INTCON,T0IF
		   	CALL RESPALDO_2
			RETFIE
			
SI			BTFSC		SU,0
			GOTO		SINO
			BSF			SU,0
			BSF			PORTB,0		
			RETURN
SINO		BCF			SU,0
			BCF			PORTB,0
			RETURN
END	 