		PROCESSOR 16F887 ;procesador a usar 
		INCLUDE P16F887.INC; libreria

multiplicando EQU 020
multiplicador EQU 021
producto_l EQU 022
producto_h EQU 023
multiplicando_h EQU 024

 ORG 0 
;Programa principal 
inicio 	movlw .0 ; W <-- nro1
		movwf multiplicando ; multiplicando <-- W
		movlw .0 ; W <-- nro2
		movwf multiplicador ; multiplicador <-- W
		goto Mul
		goto $
; Procedimiento 
Mul clrf producto_l ; inicializar lsb de producto
		clrf producto_h ; inicializar msb de producto
		clrf multiplicando_h ; inicializar msb del multiplicando
; Desplazar el multiplicador un bit a la derecha 
sgte_iteracion ; MUL_LOOP
		bcf STATUS, C ; poner en cero el bit de acarreo 
		rrf multiplicador, F
; SI Acarreo == 1 ENTONCES sumar multiplicando a producto 
		btfss STATUS, C ; SI C == 1 ENTONCES sumar
		goto sgte_bit ; SINO no hacer nada
		movf multiplicando, W ; sumar
		addwf producto_l, F ; primero los dos bytes inferiores
		btfsc STATUS, C ; SI no hay acarreo ENTONCES
; procesar los bytes altos
		incf producto_h, F ; SINO sumar acarreo
		movf multiplicando_h, W ; procesar los bytes altos
		addwf producto_h, F
; Desplazar el multiplicando una vez a la izquierda
sgte_bit 
		bcf STATUS, C ; poner en cero el bit de acarreo
		rlf multiplicando, F
		rlf multiplicando_h, F
; MIENTRAS multiplicador diferente de cero 
		movf multiplicador, F ; verificar si multiplicador es cero
		btfss STATUS, Z
		goto sgte_iteracion ; SI no ENTONCES repetir
		;return ; SINO terminado
		end