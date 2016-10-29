;*****************************************************************************************
;*Centro de Investigación en Computación												*
;*Maestría en Ciencia de la Computación												*
;*Sistemas de Computo. Proyecto 1. Automatización de un Invernadero con un PIC16F887	*
;*ISC. Ana Bertha Cruz Martínez														*
;*****************************************************************************************

;************************************Inicio***********************************************
			PROCESSOR	16F887
			INCLUDE		P16F887.INC
		;	__CONFIG _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
	   	;	__CONFIG _CONFIG2, _WRT_OFF & _BOR21V
;************************Registros**********************************************************

DATO 		EQU			070
DA_A 		EQU			071
DA_B		EQU			072
;XORR para la comparación en caso de haber acumulador un minuto
cont_m		equ 				078 ;Contador de minutos
count 		equ 				079 ;Contador de interrupciones del timer 1
COM		EQU			07A
X			EQU 			073
RES_W		EQU 			07E
RES_S		EQU			07F

			ORG			0
			GOTO		INICIO
			ORG			4
			GOTO		MENU_INT

;*************************************Inicialización de Perifericos*************************
INICIO
			CLRF 		count ; inicializo el contador
			CLRF 		cont_m ; inicializo el contador

;*************************************Puertos********************************************
			BANKSEL 	TRISD ;CAMBIO A BANCO 1
	       		CLRF 		TRISD ;CONFIGURO TODO PORTD COMO SALIDA
			CLRF 		TRISB ;CONFIGURO TODO PORTB COMO SALIDA
	        	BANKSEL      	PORTD
	        	CLRF		 PORTD ;APAGO POSIBLES LATCHS EN PORTD
			CLRF		 PORTB;APAGO POSIBLES LATCHS EN PORTD
			BCF			PORTB,0
			BCF			PORTB,2
;*************************************A/D***********************************************
            		BANKSEL 	ADCON1 ;
           		MOVLW	 B'10000000' ;JUSTIFICACIÓN A LA IZQUIERDA
            		MOVWF 	ADCON1 ;Vdd Y Vss COMO Vref
            		BANKSEL	 TRISA ;
            		BSF 		TRISA,0 ;PONEMOS A RA0 COMO ENTRADA
            		BANKSEL 	ANSEL ;
           		BSF 		ANSEL,0 ;PONEMOS A RA0 COMO ANALOGICO
           		BANKSEL 	ADCON0 ;
           		MOVLW 	B'11000001' ;ELEGIMOS EL RELOJ Frc DEL ADC
           		MOVWF 	ADCON0 ;Y ENCENDEMOS EL CONVERTIDOR
;*************************************Timer0********************************************
			BANKSEL 	OPTION_REG
			MOVLW	0D2
			MOVWF	OPTION_REG
			BANKSEL 	ADCON1
			MOVLW 	0E				;CONFIGURACION 1 DE CONVERTIDOR A/D
			MOVWF 	ADCON1
			BSF			INTCON,T0IE
			BSF			INTCON,TMR0IE
			BSF			INTCON,GIE
			BANKSEL 	TMR0
			MOVLW	0FA
			MOVWF	TMR0
;*************************************Timer1********************************************
			BANKSEL 	T1CON
			CLRF 		T1CON
			BSF			T1CON,TMR1ON ; Apago timer1
			BSF 		T1CON,T1CKPS1 ;seleccionado el preescalador 
			BSF		 	T1CON,T1CKPS0 ; a 8
			BCF 		T1CON,T1OSCEN ; Desablitando el ocilador externo
			BCF 		T1CON,TMR1CS ; usar Fosc/4 
			CLRF 		TMR1L ; limpio los registos de timer
			CLRF		TMR1H ;
			BANKSEL 	PIE1 ;cambio a banco 1
	  		BSF      		PIE1, TMR1IE ;enciendo el PIE
			BANKSEL 	PIR1 ; Cambio a banco 1
			;clrf	 PIR1 ; limpio PIR1
			BSF   		INTCON,PEIE
			BSF			T1CON,TMR1ON ; Inicio el timer
			BCF		INTCON,TMR1IF; bajo la bandera de interrupcion
			BSF			INTCON,GIE; subo la bandera general de interrupciones

;*************************************Ciclo NOP*****************************************
CICLO
			NOP
			NOP
			GOTO CICLO
;*************************************Menu de Interrupciones****************************
MENU_INT
			CALL 		RESPALDO_1
			BTFSC INTCON, TMR0IF
			CALL INTE_TMR0

			BTFSC INTCON, TMR1IF
			CALL INTE_TMR1
			CALL 		RESPALDO_2
			RETFIE
;*************************************Interrupcion Timer 0*******************************
INTE_TMR0
			
			CALL		OPERA
			BANKSEL 	TMR0
			MOVLW	0AA
			MOVWF	TMR0
			BCF PIR1,ADIF	
			BCF		INTCON,T0IF
			BSF			INTCON,TMR0IE
			BSF			INTCON,GIE; subo la bandera general de interrupciones
		   	
			RETURN
;*************************************Interrupcion Timer 1*******************************
INTE_TMR1

			BCF 		PIR1,0 ; Limpiar la bandera
;Compara hasta 229 que es un minuto en caso de tener osc de 4MHZ, o hasta 114 en caso de tener Oscilador de 2Mhz
			INCF		count,F ;incremento el contador
			;MOVLW .229
			MOVLW	.114
			MOVWF 	X
			MOVF 		count,W
			XORWF 	X
			CALL 		SI_	
			BCF		T1CON,0 ; apago el timer
			MOVLW	80h ; inicio en 80h
			MOVWF	 TMR1H
			CLRF 		TMR1L
			BSF 		T1CON,TMR1ON ; Reinicio el timer
			BSF   		INTCON,PEIE
			BSF 		T1CON,TMR1ON ; Inicio el timer
			BCF		INTCON,TMR1IF; bajo la bandera de interrupcion
			BSF			INTCON,GIE; subo la bandera general de interrupciones
			;CALL 		RESPALDO_2
			RETURN
;*************************************Proceso A/D***************************************
OPERA: 		BSF			ADCON0,GO ;INICIA LA CONVERSION
           		BTFSC 		ADCON0,GO ;YA SE TERMINO LA CONVERSION?
            		GOTO $-1 	;NO? PREGUNTA DE NUEVO
            		BANKSEL 	ADRESL ;CAMBIO A BANCO1
            		MOVF 		ADRESL,W ;LEE LA PARTE MENOS SIGNIFICATIVA
			MOVWF 	DATO ;GUARDALO EN DATO
			CALL 		COMPARA_TEMP
			
	     		RETURN;	REGRESO AL INICIO DEL PROGRAMA PRINCIPAL

;*************************************Rutinas de ayuda***********************************

RESPALDO_1
			 MOVWF	RES_W
			 SWAPF 	STATUS, W
			 MOVWF 	RES_S
			 RETURN
RESPALDO_2
			SWAPF 		RES_S,W ;Swap STATUS_TEMP register into W
			MOVWF 	STATUS ;Move W into STATUS register
			SWAPF		RES_W,F ;Swap W_TEMP
			SWAPF 		RES_W,W ;Swap W_TEMP into W
			RETURN

;***********************IF-ELSE DEL TIMER1 PARA VERIFICAR SI SE TIENE UN MINUTO***********************
SI_			BTFSC		STATUS,Z
			GOTO		SINO
			MOVF		cont_m,W
			BANKSEL 	PORTD
			MOVWF	PORTD ; escribo en PORTD
			RETURN

SINO	

			INCF		cont_m,F ;incremento el contador
			CLRF		count
			MOVF 		cont_m,W
			BANKSEL 	PORTD
			MOVWF 	PORTD ; escribo en PORTD
			RETURN
COMPARA_TEMP
					
			MOVLW .75; son 30 grados, tomando en cuenta que 250 serian 100 grados
			MOVWF DA_B
			MOVF DA_B,W
			SUBWF DATO,W
			BTFSC	STATUS,Z
			GOTO A_IGUAL_B
			BTFSC STATUS,C
			GOTO A_MAYOR_B
;BANKSEL PORTD
A_MENOR_B
			BANKSEL PORTB
			BCF			PORTB,0	
			RETURN
A_MAYOR_B
			BANKSEL PORTB
			BSF			PORTB,0
			RETURN
A_IGUAL_B
			BANKSEL PORTB
			BCF			PORTB,0
			RETURN	
			END