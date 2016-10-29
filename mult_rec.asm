	PROCESSOR 16F887
		INCLUDE P16F887.INC ; archivo que tiene los registros y sus equivalencias
CONT	EQU	020
	ORG	0
	MOVLW .10
	MOVWF CONT
CICLO NOP
	DECFSZ CONT, F
	GOTO CICLO

	END