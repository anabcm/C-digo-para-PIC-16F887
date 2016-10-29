;*****************************************************************************************
;*Centro de Investigación en Computación												*
;*Maestría en Ciencia de la Computación													*
;*Sistemas de Computo. Proyecto 1. Automatización de un Invernadero con un PIC16F887	*
;*ISC. Ana Bertha Cruz Martínez															*
;************************************Inicio***********************************************
			PROCESSOR	16F887
			INCLUDE		P16F887.INC
;************************Registros**********************************************************
DATO 		EQU			070 ; Conversion Analogica Digital
DA_A 		EQU			071; Comparación de ADC
DA_B		EQU			072
cont_asp	EQU			077; Contador de minutos para prender el aspersor
cont_asp_on	EQU			076
cont_m		EQU			078 ;Contador de minutos
count 		EQU 		079 ;Contador de interrupciones del timer 1
COM			EQU			07A
X			EQU 		073;minutos
Y			EQU 		074;aspersor
RES_W		EQU 		07E; respalfo de WREG
RES_S		EQU			07F; Respaldo de Status

			ORG			0
			GOTO		INICIO
			ORG			4
			GOTO		MENU_INT

;*************************************Inicialización de Perifericos*************************
INICIO
			CLRF 		count ; inicializo el contador
			CLRF 		cont_m
			CLRF		cont_asp
			CLRF		cont_asp_on
;*************************************Puertos********************************************
		BCF STATUS,RP0
		BCF STATUS,RP1
		CLRF		PORTD ;Limpio pueto D
		CLRF		PORTB;Limpio pueto B
		CLRF		PORTC;
	    BSF STATUS,RP0
	    CLRF 		TRISD ;Configuro PortD como salida
		CLRF 		TRISB 
		CLRF 		TRISC ;Configuro PortC como salida
		BANKSEL ANSELH
		CLRF ANSEL ;Configuro PortB como salida
		CLRF ANSELH
			BCF			PORTB,0
			BCF			PORTB,2
;*************************************A/D***********************************************
            BANKSEL 	ADCON1 ;
           	MOVLW		B'10000000' ;Alineo a la Izquiera la lectura del ADC
            MOVWF 		ADCON1 ;Pongo como referencia la tierra y la corriente
            BANKSEL	 	TRISA ;
          	MOVLW H'FF' ;todos los pins del PORTA entradas
 	 		MOVWF TRISA
            BANKSEL 	ANSEL ;
			CLRF ANSEL
           	BSF 		ANSEL,0 ;Se configura RA0 como entrada
           	BANKSEL 	ADCON0 ;
           	MOVLW 		B'11000001' ;La frecuencia de muestreo de 2-6 microsegundos ADCS1=1  ADCS0=1 
           	MOVWF 		ADCON0 ;Encendemos el analogico|
;*************************************Timer0********************************************
			BANKSEL 	OPTION_REG
			MOVLW		0D2; 11011100 T0SE=1 incrementa en flanco de subida, PSA=1 preescalador, PSA2=1 1:64 de muestra
			MOVWF		OPTION_REG
			BANKSEL 	ADCON1
			MOVLW 		0E				;CONFIGURACION 1 DE CONVERTIDOR A/D
			MOVWF 		ADCON1
			BSF			INTCON,T0IE ; Levanta la bandera de interrupción
			BSF			INTCON,TMR0IE ; levanta la bandera del tmr0
			BSF			INTCON,GIE   ; levanta la bandera general de interrupciones
			BANKSEL 	TMR0
			MOVLW		0FA; inicializa el tmr0 en 250
			MOVWF		TMR0
;*************************************Timer1********************************************
			BANKSEL 	T1CON
			CLRF 		T1CON		;limipio T1CON que configura el TMR1
			BSF			T1CON,TMR1ON ; Apago timer1
			BSF 		T1CON,T1CKPS1 ;seleccionado el preescalador 
			BSF		 	T1CON,T1CKPS0 ; a 8
			BCF 		T1CON,T1OSCEN ; Desablitando el ocilador externo
			BCF 		T1CON,TMR1CS ; usar Fosc/4 
			CLRF 		TMR1L ; limpio los registos de timer
			CLRF		TMR1H ;
			BANKSEL 	PIE1 ;cambio a banco 1
	  		BSF      	PIE1, TMR1IE ;enciendo el PIE
			BANKSEL 	PIR1 ; Cambio a banco 1
			BSF   		INTCON,PEIE
			BSF			T1CON,TMR1ON ; Inicio el timer
			BCF			INTCON,TMR1IF; bajo la bandera de interrupcion
			BSF			INTCON,GIE; subo la bandera general de interrupciones

;*************************************Ciclo NOP*****************************************
CICLO
			NOP; Ciclo de ejecición del nucleo
			NOP
			GOTO CICLO
;*************************************Menu de Interrupciones****************************
MENU_INT
			BTFSC INTCON, TMR0IF ; Si no fue el tmr0 salta la linea siguiente, entonces fue el tmr1
			GOTO 		INTE_TMR0; si fue el tmr0

			GOTO		INTE_TMR1; interrupción del tmr1

;*************************************Interrupcion Timer 0*******************************
INTE_TMR0
			CALL 		RESPALDO_1 ; respalda Wreg y status
			CALL		CONVIERTE; Llama a la conercion Analogica digital
			BANKSEL 	TMR0
			MOVLW		0AA; inicializa nuevamente el TME0 con 170
			MOVWF		TMR0
			BCF 		PIR1,ADIF	; Levanta la bandera del AD
			BCF			INTCON,T0IF
			BSF			INTCON,TMR0IE; levanta la bandera del TMR0
			BSF   		INTCON,PEIE; Levanta la bandera de interrupcion multiperiferico
			BSF			PIE1,ADIE
			BSF			INTCON,GIE; subo la bandera general de interrupciones
			CALL RESPALDO_2; regresa WREG y STATUS a su estado original
			RETFIE
;*************************************Interrupcion Timer 1*******************************
INTE_TMR1
			CALL 		RESPALDO_1
;Compara hasta 229 que es un minuto en caso de tener osc de 4MHZ, o hasta 114 en caso de tener Oscilador de 2Mhz
			INCF		count,F ;incremento el contador
			INCF		cont_asp_on; incrementa el contador del aspersor de encendido para llegar a medio minuto
			MOVLW		.114; pasa 115 que es apro.524*114 SON 59.7326 segundos
			MOVWF 		X
			MOVF 		count,W
			XORWF 		X; hacemos xOR entre el contador de interrupciones y la cantidad deseada
			CALL 		SI_	; preguntamos si ya es un minuto
			CALL		ASP_ON; preguntamos si son 8 min para prender el aspersor
			BCF			T1CON,0 ; apago el timer
			MOVLW		80h ; inicio en 80h; inicio del registro para hacer el ajuste
			MOVWF	 	TMR1H
			CLRF 		TMR1L
			BSF 		T1CON,TMR1ON ; Reinicio el timer
			BCF 		PIR1,0 ; Limpiar la bandera
			BSF   		INTCON,PEIE
			BCF			INTCON,T0IF
			BSF 		T1CON,TMR1ON ; Inicio el timer
			BCF			INTCON,TMR1IF; bajo la bandera de interrupcion
			BSF			INTCON,GIE; subo la bandera general de interrupciones
			CALL 		RESPALDO_2
			CALL RESPALDO_2
			RETFIE
;*************************************Proceso A/D***************************************
CONVIERTE: 		BSF			ADCON0,GO ;Inicia la conversion por poleo
           	BTFSC 		ADCON0,GO ;pregunta si termino la conversion 
            GOTO $-1 	;Si no, regresa
           	BANKSEL 	ADRESH ;cambiamos al bando 1
            MOVF 		ADRESH,W ;Leemos la parte izquierda del ADC
			MOVWF 	DATO ;Almacenos en DARO
			MOVWF PORTC; Enviamos al puerto C
			BCF STATUS,RP1
			MOVF	DATO,W
			MOVWF PORTC;Enviamos al puerto C
			CALL 		COMPARA_TEMP
			RETURN;	regresa al TMR0

;*************************************Rutinas de ayuda***********************************

RESPALDO_1; Respalda el registro de trabajo y el statis
			 MOVWF	RES_W
			 SWAPF 	STATUS, W
			 MOVWF 	RES_S
			 RETURN
RESPALDO_2
			SWAPF 		RES_S,W ;Swap STATUS_TEMP register into W
			MOVWF 		STATUS ;Move W into STATUS register
			SWAPF		RES_W,F ;Swap W_TEMP
			SWAPF 		RES_W,W ;Swap W_TEMP into W
			RETURN

;***********************IF-ELSE DEL TIMER1 PARA VERIFICAR SI SE TIENE UN MINUTO***********************
SI_			BTFSC		STATUS,Z; pregunta si la bandera Z se prendio
			GOTO		SINO
			MOVF		cont_m,W; mueve el contador de minutos al puerto D
			MOVWF		PORTD ; escribo en PORTD
			RETURN
SINO	
			INCF		cont_m,F ;incremento el contador
			INCF		cont_asp,F; incrementa el contador del aspersor
			CALL 		Asp; llama a la rutina de prender el aspersor
			CLRF		count; limpia el contador
			MOVF 		cont_m,W; incrementa el contador de minutos
			MOVWF 		PORTD ; escribo en PORTD
			RETURN
COMPARA_TEMP	
			
			BCF STATUS,RP0
			MOVLW 		.128; son 30 grados, tomando en cuenta que 256 serian 100 grados, para que sea significativo el cambio
			MOVWF 		DA_B; se mueve a B para poder comparar con la lectua actual
			MOVF 		DA_B,W; 
			SUBWF 		DATO,W; se resta para saber si es mayot o menor
			BTFSC		STATUS,Z; se checa si se prendio Z
			GOTO 		A_IGUAL_B; se ve si son iguales
			BTFSC 		STATUS,C
			GOTO		 A_MAYOR_B; se verifica si fue mato
A_MENOR_B
			BANKSEL 	PORTB
			BCF			PORTB,0	; apaga el LED si la temperatura fue menor a 128
			RETURN
A_MAYOR_B
			BANKSEL 	PORTB
			BSF			PORTB,0; enciende el led si la lectura fue mayor
			RETURN
A_IGUAL_B
			BANKSEL		PORTB
			BCF			PORTB,0; si son iguales la deja apagada
			RETURN	
;****************ASPERSOR************************
Asp			MOVLW .8; CADA 8 hrs enciende el asperos
			MOVWF 	Y
			MOVF 		cont_asp,W
			XORWF 		Y
			BTFSC		STATUS,Z; preguntamos si llegamos a los 8 min
			GOTO NOA
			RETURN			
NOA					
			BSF	 PORTB,2 ;si llegamos, prendemos el aspersor y limpiamos el contador
			CLRF cont_asp
			RETURN
;*****************ASPERSOR_PRENDIDO
ASP_ON		MOVLW		.69; PARA MEDIO MINUTO
			MOVWF		X
			MOVF	cont_asp_on,W
			XORWF		X
			BTFSC	STATUS,Z; pregunta si llevamos medio minuto
			GOTO NOAS
			RETURN
NOAS		
			BCF PORTB,2; si llevamos medio minuto, apagamos el aspersor
			CLRF cont_asp_on; limpiamos el contador
			RETURN	
			
			END