	PROCESSOR	16f887
			INCLUDE		P16F887.INC
VAR			EQU			020
			ORG			0

MAIN		MOVLW		.5	;X=
			MOVWF		VAR
			MOVLW		D'1'
			CALL		TABLA
			GOTO		FINAL
;-----------TABLE-------------
TABLA		ADDWF		PCL,F
			;RETLW		D'2'
			;RETLW		D'4'
			GOTO	SUMA
			GOTO	RESTA

SUMA		INCF	VAR,F
			GOTO	FINAL
RESTA		DECF	VAR,F
			GOTO	FINAL
FINAL		nop
			END