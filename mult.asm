;Ana Bertha Cruz Mtz
; multiplicación de dos números en un ciclo
;MULT B es el contador y se almacena en result
		PROCESSOR 16F887
		INCLUDE P16F887.INC
MULTA 	EQU 020
MULTB	EQU 021
RESULT 	EQU 022
		ORG 0
		MOVLW .246
		MOVWF MULTB
		MOVLW .0
		MOVWF RESULT
CICLO   MOVLW .3
		ADDWF RESULT
		INCF MULTB,1
		BTFSS STATUS,Z
		GOTO CICLO
		NOP
		END
