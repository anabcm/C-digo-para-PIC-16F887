PROCESSOR	16F887
			INCLUDE		P16F887.INC
BAN			EQU			07E
			ORG			0
;-----------CONF IN----------------
INICIO		CLRF		BAN
;-----------TMR0-------------------
			BSF			STATUS,RP0
			MOVLW		0D2
			MOVWF		OPTION_REG
			BCF			STATUS,RP0
;-----------PORTB------------------
			BSF			STATUS,RP0
			BSF			STATUS,RP1
			;MOVF		ANSELH,W
			MOVLW		B'00000000'
			MOVWF		ANSELH
			BCF			STATUS,RP1
			BCF			TRISB,0
			BCF			STATUS,RP0
;----------------------------------
MAIN		NOP
			NOP
CICLO		MOVLW		06
			MOVWF		TMR0
			CALL		SI
;-----------VERIFICAR SI YA----------
YA			;BSF			PORTB,0
			;NOP
			;NOP
			;BCF			PORTB,0
			BTFSS		INTCON,T0IF
			GOTO		YA
			BCF			INTCON,T0IF
			GOTO		CICLO
;-----------INI	FUN-----------------------
;FUNCION IF PARA VERIFICAR LA BANDERA BAN
SI			BTFSC		BAN,0
			GOTO		SINO
			BSF			BAN,0
			BSF			PORTB,0		
			RETURN
SINO		BCF			BAN,0
			BCF			PORTB,0
			RETURN
;-----------FIN FUN----------------------
			END