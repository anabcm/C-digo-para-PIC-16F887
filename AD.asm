		PROCESSOR 16F887
		INCLUDE P16F887.INC
RESULTHI 	EQU 	 020
RESULTLO 	EQU	021

		ORG 0
		GOTO MAIN

		;Configuracion del Analogico digital
		;Configurando el Analogico del PORTA
MAIN
		BANKSEL ADCON1 ;
		MOVLW B'10000000' ;right justify
		MOVWF ADCON1 ;Vdd and Vss as Vref
		BANKSEL TRISA ;
		BSF TRISA,0 ;Set RA0 to input
		
		;Configurando el modulo Analogico digital
		BANKSEL ANSEL ;
		BSF ANSEL,0 ;Set RA0 to analog
		BANKSEL ADCON0 ;
		
		;Configurando el reloj
		MOVLW B'11000001'      ;ADC Frc clock,
		MOVWF ADCON0 ;AN0, On
		CALL Interrup_Analog ;Acquisiton delay
	
Interrup_Analog
	;Inicia la conversiòn Analogica
		BSF ADCON0,GO ;Start conversion
		BTFSC ADCON0,GO ;Is conversion done?
		GOTO $-1 ;No, test again
		BANKSEL ADRESH ;
		MOVF ADRESH,W ;Read upper 2 bits
		MOVWF RESULTHI ;store in GPR space
		BANKSEL ADRESL ;
		MOVF ADRESL,W ;Read lower 8 bits
		MOVWF RESULTLO ;Store in GPR space
	
END