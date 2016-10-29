		;ANA BERTHA CRUZ MARTINEZ
		PROCESSOR 16F887		;procesador a usar
		INCLUDE P16F887.INC		;libreria

;Espacio de memoria a usar
muld EQU 020
mul EQU 021
prod_1 EQU 022
prod_a EQU 023
muld_a EQU 024

		ORG 0
;Inicia programa principal
Inicio	movlw .5		;movemos un 5 al W
		movwf muld		;movemos del registro de trabajo W al multiplicando
		movlw .10		;movemos un 10 al registro de trabajo W
		movwf mul		; movemos del registro de trabajo al multiplicador
		goto Mul
		goto $
;Inicia el procedimiento
Mul	clrf prod_1		;limpiando los registros
	clrf prod_a		;limpiando los registros
	clrf muld_a		;limpiando los registros
;Desaplazando el multiplicador a la derechaa
desder_loop
	bcf STATUS,C	;ponen el 0 el bit de acarreo
	rrf mul, F
	;SI acareo==1 entonces sumar multiplicando a producto
	btfss STATUS, C  ;si C==1 entonces sumar
	goto des_bit
	movf muld,W; sumar
	addwf prod_1,F
	btfsc STATUS, C; si no hay acarreo entonces
	;procesar bytes altos
	incf prod_a, F; sino sumar el acarreo
	movf muld_a, W ; procesa los bits altos
	addwf prod_a, F
;Desplazando el multiplicador
des_bit
	bcf STATUS, C; pone en cero el byte de acarreo
	rlf muld, F  ;rota a la izquierda y prueba el acarreo
	rlf muld_a,F
;mientras muld sea diferente de CERO
	movf mul, F; verificamos si el multiplicador es cero
	btfss STATUS, Z
	goto desder_loop; sino entonces repite el ciclo
	end