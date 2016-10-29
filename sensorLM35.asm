;///////// www.openboxer.260mb.com ////////////
;//                               JUNIO-2009 //
;//  PROGRAMA : sensorLM35.asm               //
;//  Funci�n: A trav�s de un Display LCD16x2 //
;//  y el sensor de temperatura LM35,        //
;//  muestrar la temperatura obtenida        //
;//  (0� <= T >= 100� C).                    //
;//                                          //
;//  PORTA                                   //
;//  ENTRADA: CANAL 0  -  Conv. A/D          //
;//   -------------------------------        //
;//  | - | - | - | - | - | - | - | 0 |       //
;//   -------------------------------        //
;//                                          //
;//  PORTB                                   //
;//  SALIDA: Resultado contenido en ADRESH   //
;//   -------------------------------        //
;//  | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |       //
;//   -------------------------------        //
;//  Puertos para utilizar LCD16x2           //
;//  PORTD                                   //
;//  SALIDAS: Ev�o de DATOS E INSTRUCCIONES. //
;//   -------------------------------        //
;//  | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |       //
;//   -------------------------------        //
;//                                          //
;//  PORTC                                   //
;//  SALIDAS                                 //
;//  BIT 0:[RS] MODO DATO=1/INSTRUCCION=0    //
;//  BIT 1:[ENABLE] ACTIVADO=1/DESC.=0       //
;//   -------------------------------        //
;//  | - | - | - | - | - | - | 1 | 0 |       //
;//   -------------------------------        //
;//                                          //
;///////// www.openboxer.260mb.com ////////////

  processor 16f877
  include<p16f877.inc>

  ;Variable para el DELAY del ADC
val equ h'20'

  ;Variables para el DELAY del ENABLE LCD
val2 equ 0x30
val1 equ 0x31

  ;Variables para separar el resultado de ADC
  ; en valor BCD
Unidades equ 0x32     
Decenas equ 0x33  	
Centenas equ 0x34   
Resto equ 0x35

  org 0h
  goto INICIO
  org 05h

INICIO:
      clrf PORTA        ;Limpia el puerto A
      clrf PORTB        ;Limpia el puerto B
      clrf PORTC 	    ;Limpia el puerto C	
	  clrf PORTD 		;Limpia el puerto D
      bsf STATUS,RP0    
      bcf STATUS,RP1    ;Cambio la banco 1
      ;Configuraci�n de puertos C-D para el LCD
      clrf TRISC        ;Configura PORTC como salida
	  clrf TRISD        ;Configura PORTD como salida
      ;Configuraci�n del puerto A para ADC
      movlw 00h         
      movwf ADCON1      ;Configura puerto A y E como anal�gicos
      movlw 3fh         
      movwf TRISA       ;Configura el puerto A como entrada
      movlw h'0'
      ;Configuraci�n del puerto B para mostrar el resultado ADC
      movwf TRISB       ;Configura puerto B como salida
      bcf STATUS,RP0    ;Regresa al banco 0
      ;Inicio del programa
START
      call START_LCD   ;Inicializa LCD
      goto START_ADC   ;Comienza la lectura del Conv. A/D
      ;Inicia LCD
START_LCD:
      bcf PORTC,0      ; RS=0 MODO INSTRUCCION
      movlw 0x01	   ; El comando 0x01 limpia la pantalla en el LCD
	  movwf PORTD
	  call COMANDO     ; Se da de alta el comando
	  movlw 0x0C       ; Selecciona la primera l�nea
	  movwf PORTD
	  call COMANDO     ; Se da de alta el comando
	  movlw 0x3C       ; Se configura el cursor
	  movwf PORTD
	  call COMANDO     ; Se da de alta el comando
	  bsf PORTC, 0     ; Rs=1 MODO DATO
      return
      ;Rutina para enviar un dato
ENVIA:
	  bsf PORTC, 0    ; RS=1 MODO DATO
	  call COMANDO    ; Se da de alta el comando
	  return  
     ;Rutina para enviar comandos
COMANDO:
      bsf PORTC, 1	   ; Pone la se�al ENABLE en 1
      call DELAY2      ; Tiempo de espera
      call DELAY2
      bcf PORTC, 1     ; ENABLE=0	
	  call DELAY2
	  return     
      ;Rutina para limpar pantalla LCD  
ERASE_LCD
      bcf PORTC,0      ; RS=0 MODO INSTRUCCION
      movlw 0x01	   ; El comando 0x01 limpia la pantalla en el LCD
	  movwf PORTD
	  call COMANDO     ; Se da de alta el comando
      bsf PORTC, 0     ; Rs=1 MODO DATO
      return
      ;Configuraci�n Convertidor A/D
START_ADC
      movlw b'11000001' ;Configuraci�n ADCON0 
      movwf ADCON0      ;ADCS1=1 ADCS0=1 CHS2=0 CHS1=0 CHS0= GO/DONE=0 - ADON=1

CICLO: bsf ADCON0,2      ;Conversi�n en progreso GO=1
       call DELAY1       ;Espera que termine la conversi�n
ESPERA btfsc ADCON0,2    ;Pregunta por DONE=0? (Termin� conversi�n)
       goto ESPERA       ;No, vuelve a preguntar
       movf ADRESH,0     ;Si
       movwf PORTB       ;Muestra el resultado en PORTB
       ;Rutina que muestra temperatura
PRINT_TEMP
       call ERASE_LCD    ;Limpia LCD
       movlw 'T'
	   movwf PORTD
	   call ENVIA
       movlw '='
	   movwf PORTD
	   call ENVIA

       call READ_TEMP    ;Llamada a rutina que obtine el 
                         ;valor de la temperatura a partir
                         ;del  resultado del Conv a/D

       movf Centenas,W   ;Imprime el d�gito de las centenas
       movwf PORTD
       call ENVIA
       movf Decenas,W    ;Imprime el d�gito de las decenas
       movwf PORTD
       call ENVIA
       movf Unidades,W   ;Imprime el d�gito de las unidades
       movwf PORTD
       call ENVIA
       movlw ' '
	   movwf PORTD
	   call ENVIA
       movlw h'DF'       ;Imprime el simbolo "�"
	   movwf PORTD
	   call ENVIA 
       movlw 'C'
	   movwf PORTD
	   call ENVIA 

       goto CICLO        ;Repite el ciclo de lectura ADC

       ;Rutina que obtine el valor de la temperatura
       ;a partir del  resultado del Conv a/D
READ_TEMP:
       clrf Centenas
       clrf Decenas
       clrf Unidades
      
       movf ADRESH,W   
       addwf ADRESH,W     ;Dupilca el valor de ADRESH para 
       ;obtener un valor de temperatura real aprox
       movwf Resto        ;Guarda el valor de ADRESH en Resto   
       ;Comienza el proceso de otenci�n de valores BCD 
       ;para Centenas, Decenas y unidades atraves de restas
       ;sucesivas.
CENTENAS1
       movlw d'100'      ;W=d'100'
       subwf Resto,W     ;Resto - d'100' (W)
       btfss STATUS,C    ;Resto menor que d'100'?
       goto DECENAS1     ;SI
       movwf Resto       ;NO, Salva el resto
       incf Centenas,1   ;Incrementa el contador de centenas BCD
       goto CENTENAS1    ;Realiza otra resta
DECENAS1
       movlw d'10'       ;W=d'10'
       subwf Resto,W     ;Resto - d'10' (W)
       btfss STATUS,C    ;Resto menor que d'10'?
       goto UNIDADES1    ;Si
       movwf Resto       ;No, Salva el resto
       incf Decenas,1    ;Incrementa el contador de centenas BCD
       goto DECENAS1     ;Realiza otra resta
UNIDADES1
       movf Resto,W      ;El resto son la Unidades BCD
       movwf Unidades
       ;clrf Resto
       ;Rutina que obtiene el equivalente en ASCII
OBTEN_ASCII
       movlw h'30' 
       iorwf Unidades,f      
       iorwf Decenas,f
       iorwf Centenas,f      
       return


;Rutina que genera un Delay de 20 microSeg aprox.
;para el Conv. A/D
DELAY1:             
       movlw h'30'
       movwf val
Loop   decfsz val,1
       goto Loop
       return

;Subrutina de retardo para ENABLE_LCD 
DELAY2:        	
		movlw 0xFF
        movwf val1 
Loop1:
        movlw 0xFF
		movwf val2	
Loop2:
		decfsz val2,1
		goto Loop2
		decfsz val1,1
		goto Loop1
        return
     end
