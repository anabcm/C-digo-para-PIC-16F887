			PROCESSOR	16F887
			INCLUDE		P16F887.INC

			__CONFIG _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
	   		__CONFIG _CONFIG2, _WRT_OFF & _BOR21V

RES_W		EQU 			07E
RES_S		EQU			07F
DATOA 		EQU			020
DATOB		EQU			021


			ORG			0
			GOTO		INICIO
;---------------------------------------
INICIO
;-----------PORTB----------------------
			
			BSF			STATUS,RP0
			BSF			STATUS,RP1
			MOVLW		B'00000000'
			MOVWF		ANSELH
			BCF			STATUS,RP1
			CLRF		TRISB
			CLRF		TRISD
			
			BANKSEL PORTB
			BSF			PORTB,0	
			BSF			PORTB,2
			;MOVWF PORTB
;_________________________________
			MOVLW .50
			MOVWF DATOA
			MOVLW .32
			MOVWF DATOB
			MOVF DATOB,W
			SUBWF DATOA,W
			BTFSC	STATUS,Z
			GOTO A_IGUAL_B
			BTFSC STATUS,C
			GOTO A_MAYOR_B
;BANKSEL PORTD
A_MENOR_B
			MOVLW		B'00001111'
			MOVWF PORTD
			GOTO CICLO
A_MAYOR_B
			MOVLW 		B'11110000'
			MOVWF PORTD
			GOTO CICLO
A_IGUAL_B
			MOVLW 		B'10101010'
			MOVWF PORTD
			GOTO CICLO

			
;-----------TMR0--------------------

CICLO
			NOP
			NOP
			NOP
			NOP
			
GOTO		CICLO
;--------------------------------


;____________________________________
		end
