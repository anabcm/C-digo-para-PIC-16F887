;**********TIMER ******************************		
		PROCESSOR 16f887
		INCLUDE P16F887.INC
;*************BITS DE CONFIGURACION*************
		;__CONFIG _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
	   	;__CONFIG _CONFIG2, _WRT_OFF & _BOR21V

count 	equ 		079 ;Counter variable
cont_m	equ 		078 ;Counter variable
RES_W	EQU 	07E
RES_S	EQU	07F
COM	EQU	07A
XORR	EQU 	07B
		org 0 ; inicio de programa
		goto inicio ; configuracion inicial
		org 4
		goto INTERRUP
;********************** configuraion PORTD.********

inicio	bsf 	STATUS,RP0 ; cambio a banco 1
		bcf 	STATUS,RP1 ; cambio a banco 1
		clrf 	TRISD ; cambiamos como salida PORTD
		bcf 	STATUS,RP0 ; Regreso a banco 1
		clrf 	PORTD ; Limpio el puerto D.
		;movlw b'11111111'
		;movwf TRISC
		clrf 	count ; inicializo el contador
		clrf cont_m
;**************** Configuracion timer1**********************************
		clrf T1CON
		bSf 	T1CON,TMR1ON ; Apago timer1
		bsf 	T1CON,T1CKPS1 ;seleccionado el preescalador 
		bsf 	T1CON,T1CKPS0 ; a 8
;_________a ver si funciona cambiando al oscilador externo
		bcf 	T1CON,T1OSCEN ; Desablitando el ocilador externo
;______________________________________
		bcf 	T1CON,TMR1CS ; usar Fosc/4 
		clrf 	TMR1L ; limpio los registos de timer
		clrf 	TMR1H ;
		BANKSEL PIE1 ;cambio a banco 1
  		bsf        PIE1, TMR1IE ;enciendo el PIE
		BANKSEL PIR1 ; Cambio a banco 1
		;clrf	 PIR1 ; limpio PIR1
		bsf    	INTCON,PEIE
		bsf 		T1CON,TMR1ON ; Inicio el timer
		BcF		INTCON,TMR1IF; bajo la bandera de interrupcion
		BSF		INTCON,GIE; subo la bandera general de interrupciones
;*****************ciclo sin hacer nada**************************
CICLO
			NOP
			NOP
			GOTO CICLO
;************interrupcion************************
INTERRUP
		CALL RESPALDO_1
		bcf 	PIR1,0 ; Limpiar la bandera
;*****************Compara hasta 229 que es un minuto
		incf 	count,F ;incremento el contador
		;MOVLW .229
		MOVLW .114
		MOVWF XORR
		movf count,W
		XORWF XORR
		
		;MOVWF XORR
		CALL SI_
		
;*****************************************
		bcf 	T1CON,0 ; apago el timer
		movlw	 80h ; inicio en 80h
		movwf	 TMR1H
		clrf 	TMR1L
		bsf 	T1CON,TMR1ON ; Reinicio el timer
		bsf    	INTCON,PEIE
		bsf 		T1CON,TMR1ON ; Inicio el timer
		BcF		INTCON,TMR1IF; bajo la bandera de interrupcion
		BSF		INTCON,GIE; subo la bandera general de interrupciones
		CALL RESPALDO_2

		RETFIE

;***********************Respaldo del registro de trabajo y de status
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

;***********************IF-ELSE
SI_			BTFSC		STATUS,Z
			GOTO		SINO
			movf cont_m,W
			movwf 	PORTD ; escribo en PORTD
			RETURN

SINO	

			incf 	cont_m,F ;incremento el contador
			clrf count
			movf cont_m,W
			movwf 	PORTD ; escribo en PORTD
			RETURN
			End