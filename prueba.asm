		PROCESSOR 16F887
status 	equ 0x03 ;hace equivalencia entre el símbolo status indicándolo como 3 en hexadecimal
Cont 	equ 0x20 
F 		equ 1 
 		org 0 ;indica posición de memoria desde donde se ensambla
Inicio  movlw 0x0F ;carga de w con el valor constante 15 (literal)
		movwf Cont ;el contenido de w se pasa al reg. CONT
Loop 
 		decfsz Cont,F ;decremento de Cont y elude siguiente si=0
 		goto Loop ;salto incondicional a Loop
 		goto $ ;Salto incondicional aqui mismo
 		end ;Fin del códig