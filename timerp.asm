		PROCESSOR 16F887
		INCLUDE P16F887.INC
;RESP_W EQU 07E; RESPALDO DE W REGISTOR DE TRABAJO
;RESP_S EQU 07F; RESPALDO DEL STATUS
		ORG 0
		GOTO MAIN
;MANEJADOR DE INTERRUPCION
		ORG 4
		MOVWF RESP_W
		SWAPF RESP_W, F
		MOVF STATUS,W
		MOVWF RESP_S
		MOVLW 07; EL 6 ES PARA HACE EL AJUSTE DE TIEMPO DESFAZADO
		MOVWF TMR0; SE LO GUARDAMOS AL TIMER
		BCF INTCON, T0IF; incicia interrupcion TOIF timer
		;GOTO CICLOP
		BCF PORTB, 01
		RETFIE ; REGRESA DEL BLOQUE DE INTERRUPCION
;CONFIGURANDO EL PIC COMO DIGITAL
MAIN    
		BSF 	STATUS, RP0
		BSF		STATUS, RP1
		CLRF	ANSELH
		BSF STATUS,RP0 ; BANCO 1
		BCF	TRISB, 01; CONFIGURACION DE PUERTO B COMO SALIDA
		MOVLW 0D2    ; CONFIGURA EL TIMER
		MOVWF OPTION_REG
		BCF		STATUS, RP0; REGRESA AL BANCO 0
		BSF INTCON, T0IF   ; TIMER INTERRUPTION
		BSF INTCON, GIE    ; GENERAL INTERRUPTION	
		
CICLO  NOP
		
		BSF PORTB, 01
		NOP
		NOP
		NOP 
		NOP
	    BCF PORTB, 01

	   GOTO CICLO
CICLOP 
		BCF PORTB, 01
		GOTO CICLOP
		END



		




