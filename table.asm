			PROCESSOR	16f887
			INCLUDE		P16F887.INC
			ORG			0
MAIN		NOP
			NOP
CICLO		NOP
			MOVLW		D'1'
			CALL		TABLA
			GOTO		CICLO
;-----------TABLE-------------
TABLA		ADDWF		PCL,F
			RETLW		D'2'
			RETLW		D'4'
	
			END