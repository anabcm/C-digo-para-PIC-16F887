		PROCESSOR 16F887
		INCLUDE P16F887.INC
		ORG 0
		BSF STATUS,IRP
		MOVLW 020
		MOVWF FSR
		MOVLW 'A'
CICLO 	MOVWF INDF
		INCF FSR,F
		GOTO CICLO
		END
		