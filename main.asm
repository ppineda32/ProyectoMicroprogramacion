;Lester Andrés García Aquino - 1003115
;Andrea Alejandra Pernillo Samayoa - 1048212
;Oskar Majus de Paz - 1034711
;Pedro Pablo Pineda Izquierdo - 2048917
.MODEL small
.DATA
;variables
tamano_snake  dw 04h    ; comienza con tamano 4
snake_y  db 0FFh dup (0AAh) ; array de coordenadas y
snake_x  db 0FFh dup (0AAh) ; array de coordenadas x


menu     DB  10,13,7,'--------------------------- BIENVENIDO AL JUEGO SNAKE --------------------------',13,10
		 DB  10,13,7,'Instrucciones:',13,10
		 DB  10,13,7,'Antes de Iniciar el juego debera ingresar el ancho y alto (numeros de un digito) que tendra la pantalla del Juego',13,10
		 DB  10,13,7,'Para moverse en el juego debera presionar las teclas de arriba, abajo, izquierda y derecha',13,10
		 DB  10,13,7,'El objetivo es tomar la comida y tratar de no topar en ningun lugar'
		 DB  10,13,7,'Si la serpiente topa un borde o su propio cuerpo, el Juego terminara'
		 DB  10,13,7,'Para Salir del Juego en cualquier momento debe Presionar la Tecla "X"'
		 DB  10,13,7,'Seleccione una opcion:',13,10 
		 DB  10,13,7,'1. Iniciar Juego', 13,10 
		 DB  10,13,7,'X. Salir de Juego$',13,10



cadena1 DB 10,13,'Ingrese las columnas',10,13,'$' ; $ Significa el final de la cadena
cadena2 DB 10,13,'Ingrese las filas',10,13,'$' ; $ Significa el final de la cadena
cadenafin DB 10,13,7,'!!!!!FIN DE JUEGO!!!!!',13,10
		  DB 10,13,7,'Presione "X" para salir del Juego$'

;DH = fila, DL = columna
cabeza_dl_x    db 00h     ;nueva posicion de cabeza x
cabeza_dh_y    db 00h     ;nueva posicion de cabeza y
cola_dl_x    db 00h       ;ultima posicion de cola x
cola_dh_y    db 00h       ;ultima posicion de cola y

espacio_char equ 20h ; caracter a utilizar para snake

X_KEY equ 78h   ; salir con x
U_KEY equ 48h   ; definir tecla arriba
D_KEY equ 50h   ; definir tecla abajo
L_KEY equ 4Bh   ; definir tecla izquierda
R_KEY equ 4Dh   ; definir tecla derecha
KEY_1 equ 49h   ;guarda el codigo para el numero 1

comida_y  db 1   ; posicion y de comida
comida_x  db 1   ; posicion x de comida
comida_char    db "*"      ; caracter de comdia

color_snake   db 5fh ; current color 

tamano_cuadro_x db 10     ; border lenght
tamano_cuadro_y db 20     ; border lenght

esquina00 db 0 , 0  ; fila 1 , col 1
esquina01 db 0 , 1  ; fila 1 , col 2
esquina10 db 1 , 0  ; fila 2 , col 1
esquina11 db 1 , 1  ; fila 2 , col 2

color_cuadro equ 7Fh ;color de cuadro

.STACK
.CODE
programa: ;etiqueta de inicio de programa

    ;inicializar el programa
    MOV AX, @DATA   ;guardando direccion de inicio segmento de datos
    MOV DS, AX      ;tiene tamaño diferente y lo mueve automaticamente
	
	
;-------------------MENU----------------------	
	CALL Mostrar_Menu
	
	;Esperando respuesta de teclado
	MOV AH, 07h			;Lee la entrada del teclado
	INT 21H
	
	cmp al , KEY_1	;compara si el valor ingresado es el del numero 1
    je IniciarJuego		;si el numero ingresado es 1 salta a la etiqueta IniciarJuego
	cmp al , X_KEY	;Compara si el valor ingresado es la letra x
    je 	SALIR	;si el valor es "x" saltara a la etiqueta finalizar 
	

IniciarJuego:
    ;Limpiar Pantalla
	MOV AH, 0
    MOV AL, 3
    INT 10H
;--------------------------INICIO JUEGO------------------------------------------------------
	
    ;Imprimir cadena
    MOV DX, OFFSET cadena1   ;asignando a DX la variable cadena
    MOV AH, 09h     ;decimos que se imprimira una cadena
    INT 21h         ;ejecuta la interrupcion, imprimira

    ;Leer num
    XOR AX, AX      ;limpiamos AX
    MOV AH, 01h     ;leer 1 caracter
    INT 21h
    SUB AL, 30h     ;quitar 30h AL caracter
    MOV CL, AL      ;temporal de posicion
    MOV snake_x[03h], CL ; posicion de snake en x
    DEC CL
    MOV snake_x[02h], CL ; posicion de snake en x
    DEC CL
    MOV snake_x[01h], CL ; posicion de snake en x
    DEC CL
    MOV snake_x[00h], CL ; posicion de snake en x
    MOV BL, 02h     
    MUL BL          ;multiplicar por 2
    ADD esquina01[01h], AL       ;sumar a la esquina superior derecha
    ADD esquina11[01h], AL       ;sumar a la esquina inferior derecha
    MOV tamano_cuadro_x, AL     ;guardar el tamano del cuadro en x

    ;Imprimir cadena
    MOV DX, OFFSET cadena2   ;asignando a DX la variable cadena
    MOV AH, 09h     ;decimos que se imprimira una cadena
    INT 21h         ;ejecuta la interrupcion, imprimira

    ;Leer num
    XOR AX, AX      ;limpiamos AX
    MOV AH, 01h     ;leer 1 caracter
    INT 21h
    SUB AL, 30h     ;quitar 30h AL caracter
    MOV snake_y[00h], AL ; posicion de snake en y
    MOV snake_y[01h], AL ; posicion de snake en y
    MOV snake_y[02h], AL ; posicion de snake en y
    MOV snake_y[03h], AL ; posicion de snake en y
    MOV BL, 02h
    MUL BL                      ;multiplicar por 2
    ADD esquina10[00h],AL       ;sumar a la esquina superior izquierda
    ADD esquina11[00h],AL       ;sumar a la esquina inferior derecha
    MOV tamano_cuadro_y, AL     ;guardar el tamano del cuadro en y

    ;Dibujar inicio
    CALL LimpiarPantalla
    CALL DibujarMarco
    CALL DibujarEsquina
    CALL RandomComida
    CALL DibujarComida
    JMP ImprimirSnake
	
SALIR:		;Se agrego esta etiqueta para que al momento de llamar a finalizar no muestre error de tamaño de salto
	JMP Finalizar
       
UP:
    ;es un movimiento invalido?
    MOV SI, tamano_snake    ;tamano actual de snake
    SUB SI, 1               ;array comienza en 0
    MOV BH, snake_y[SI]     ;posicion de cabeza en y
    SUB SI, 1
    CMP BH, snake_y[SI]     ;comparar posicion de bloque anterior a cabeza en y
    JG main                 ;indicar movimiento invalido
    ;si no es movimiento invalido
    DEC DH                  ;decrementar cabeza y
    ;comparar si topa
    CMP DH, 0               
    JE Exit1                ;terminar si llego a la pared
    JMP actualizar_cabeza         ;actualizar la nueva posicion
DOWN:
    ;es un movimiento invalido?
    MOV SI, tamano_snake    ;tamano actual de snake
    SUB SI, 1               ;array comienza en 0
    MOV BH, snake_y[SI]     ;posicion de cabeza en y
    SUB SI, 1
    CMP BH, snake_y[SI]     ;comparar posicion de bloque anterior a cabeza en y
    JL main                 ;indicar movimiento invalido
    ;comparar si topa
    MOV AL, tamano_cuadro_y
    CMP AL, DH              ;posicion y de cabeza
    JE Exit1
    ;si no es movimiento invalido
    INC DH                  ;decrementar cabeza y
    JMP actualizar_cabeza         ;actualizar la nueva posicion
Exit1:
    JMP Exit                ;salto largo
UP1:
    JMP UP                  ;salto largo
LEFT:
    ;es un movimiento invalido?
    MOV SI, tamano_snake    ;tamano actual de snake
    SUB SI, 1               ;array comienza en 0
    MOV BH, snake_x[SI]     ;posicion de cabeza en x
    SUB SI, 1
    CMP BH, snake_x[SI]     ;comparar posicion de bloque anterior a cabeza en x
    JG main                 ;indicar movimiento invalido
    ;si no es movimiento invalido
    DEC DL                  ;decrementar x
    ;comparar si topa
    CMP DL, 0               ;posicion x en cabeza
    JE Exit1
    JMP actualizar_cabeza
RIGHT:
    ;es un movimiento invalido?
    MOV SI, tamano_snake    ;tamano actual de snake
    SUB SI, 1               ;array comienza en 0
    MOV BH, snake_x[SI]     ;posicion de cabeza en x
    SUB SI, 1
    CMP BH, snake_x[SI]     ;comparar posicion de bloque anterior a cabeza en x
    JL main                 ;indicar movimiento invalido
    ;comparar si topa
    MOV AL, tamano_cuadro_x
    CMP AL, DL              ;posicion x en cabeza
    JE Exit
    ;si no es movimeinto invalido
    INC DL                  ;decrementar cabeza x
    JMP actualizar_cabeza
    

    ; main loop leer teclas, sale con tecla X
main:
    MOV AH , 07h    ; leer tecla
    INT 21h

    ;si la tecla es una flecha
    CMP AL , U_KEY
    JE UP1
    CMP AL , D_KEY
    JE DOWN
    CMP AL , L_KEY
    JE LEFT
    CMP AL , R_KEY
    JE RIGHT
    
    ;si la tecla es x, salir
    CMP AL , X_KEY
    JNE main
    JMP Exit

actualizar_cabeza: 
    ; guardar nueva posicion
    MOV cabeza_dl_x , DL
    MOV cabeza_dh_y , DH
    ;comprobar si snake comio
    CMP DH, comida_y
    JNE saltar
    CMP DL, comida_x
    JNE saltar
    INC tamano_snake
    CALL ActualizarSnake
    CALL RandomComida
    CALL DibujarSnake
    ;actualizar array
saltar:
    CALL ActualizarSnake
    ; comprobar si snake topo con cola
    MOV DH, cabeza_dh_y
    MOV DL, cabeza_dl_x
    CMP DH, cola_dh_y
    JNE ImprimirSnake
    CMP DL, cola_dl_x
    JNE ImprimirSnake
    JMP Exit

ImprimirSnake:    
    CALL DibujarSnake
    CALL DibujarComida
    CALL DibujarSnake
    JMP main

    
Exit:
    ;Limpiar Pantalla
	MOV AH, 0
    MOV AL, 3
    INT 10H
	
;Salto de Linea
    MOV DX, 10       
    MOV AH, 02H
    INT 21H
    
    MOV DX, OFFSET cadenafin
    MOV AH, 09h
    INT 21H
    
    ;Esperando respuesta de teclado
    MOV AH, 07h			;Lee la entrada del teclado
    INT 21H
    
    CMP al , X_KEY		;Compara si el valor ingresado es la letra x
    JE Finalizar		;si el valor es "x" saltara a la etiqueta finalizar 
	
	
    ;FINALIZAR PROGRAMA
Finalizar:
	CALL LimpiarPantalla
    MOV AH, 4Ch     ;finalizar el proceso
    INT 21h         ;ejecuta la interrupcion
    
;----------------------------------------------------------PROCEDIMIENTOS----------------------------------------------------------------------------------

;Procedimiento que permite que la serpite crezca    
ActualizarSnake PROC
    XOR CX , CX     ;contador en cero
    MOV CX , 01h    ;mover 1 AL contador
    XOR SI , SI     ;SI en cero
    
    ; guardamos la posicion actual de la cola en variables
    MOV DH , snake_y[SI]
    MOV DL , snake_x[SI] 
    MOV cola_dh_y , DH
    MOV cola_dl_x , DL  
    
SeguirActualizando: ;movemos las posiciones en el array
    MOV SI , CX             ;comenzar contador de posiciones
    MOV DH , snake_y[SI]    ;tomar valor en SI
    MOV DL , snake_x[SI]    ;tomar valor en SI
    
    DEC SI                  ;decrementar posicion
    CMP SI , tamano_snake   ;comparar si es tamano de snake
    JE TerminarActualizacion ;si ya movimos todas las posiciones
    MOV snake_y[SI] , DH    ;mover valor tomado a SI-1
    MOV snake_x[SI] , DL    ;mover valor tomado a SI-1

    INC CX                  ;incrementar contador
    CMP CX , tamano_snake   ;comparar si es tamano de snake
    JNE SeguirActualizando  ;iteracion
    
TerminarActualizacion:
    ; actualizar cabeza
    MOV DH , cabeza_dh_y
    MOV DL , cabeza_dl_x

    MOV SI, tamano_snake
    SUB SI, 1
    MOV snake_y[SI] , DH
    MOV snake_x[SI] , DL
    RET
ActualizarSnake ENDP


;Procedimiento para dibujar la serpiente en pantalla

DibujarSnake PROC
; colocar posicion del cursor
; INT 10h
; AH = 02h  BH = Page Number, DH = Row, DL = Column

; escribir caracter en la posicion
; INT 10h
; AH = 09h  AL = Character, BH = Page Number, BL = Color,
; CX = numero de veces a escribir
    XOR CX , CX             ;limpiar contador
    MOV AL , espacio_char   ; space - char
    MOV BH , 00h            ;pagina
    
LoopDibujar:
    MOV SI , CX             ;posicion en el array
    MOV DH , snake_y[SI]    ; coordenada y
    MOV DL , snake_x[SI]    ; coordenada x
    
    MOV AH , 02h        ; posicionar puntero
    INT 10h
    
    MOV AH , 09h        ; dibujar character
    push CX             ; guardar CX
    MOV CX , 01h        ; cantidad de caracteres
    MOV BL , color_snake  ; color del caracter
    INT 10h
    pop CX          ;devolver valor de CX
    
    INC CX          ; incrementar posicion en array
    CMP CX , tamano_snake  ;tamano actual de la serpiente
    JNE LoopDibujar        ; dibujar si no esta completo
    
    ; eliminar cola
    MOV DH , cola_dh_y    ;posicion de cola
    MOV DL , cola_dl_x    ;posicion de cola
    MOV AH , 02h        ;posicionar cursor
    INT 10h
    MOV AH , 09h        ;dibujar
    MOV CX , 01h        ;un caracter
    MOV BL , 00h        ;color negro
    INT 10h
    
    ;imprimir cabeza
    MOV SI, tamano_snake ;tomar posicion de cabeza
    SUB SI, 1

    MOV DH , snake_y[SI]    ;posicion de cabeza
    MOV DL , snake_x[SI]    ;posicion de cabeza
    MOV AH , 02h            ;posicionar cursor
    MOV BL , color_snake    ;color de snake
    INT 10h
    
    XOR CX , CX
    RET    
DibujarSnake ENDP

RandomComida PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
random_x:
    ; columna random x
    MOV ah , 2ch    ; obtener hora
    INT 21h         ; CH = horas CL = minutos DH=seguntos DL=1/100s microsegundos
    XOR AX , AX     ; limpiar ax
    MOV AL , DL     ; mover a AL sol microsegundos
    CMP AL , tamano_cuadro_x ;validar que este adentro del cuadro
    JGE random_x
    CMP AL , 0 ;validar que este adentro del cuadro
    JE random_x
    MOV comida_x , AL

random_y:
    ; columna random y
    MOV ah , 2ch    ; obtener hora
    INT 21h         ; CH = horas CL = minutos DH=seguntos DL=1/100s microsegundos
    XOR AX , AX     ; limpiar ax
    MOV AL , DL     ; mover a AL sol microsegundos
    CMP AL , tamano_cuadro_y ;validar que este adentro del cuadro
    JGE random_y
    CMP AL , 0 ;validar que este adentro del cuadro
    JE random_y
    MOV comida_y , AL
    POP AX
    POP BX
    POP CX
    POP DX
    RET
RandomComida ENDP

DibujarComida PROC
; colocar posicion del cursor
; INT 10h
; AH = 02h  BH = Page Number, DH = Row, DL = Column

; escribir caracter en la posicion
; INT 10h
; AH = 09h  AL = Character, BH = Page Number, BL = Color,
; CX = numero de veces a escribir
    ;dibujar comida
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV DH , comida_y   ;posicion de y
    MOV DL , comida_x   ;posicion de x
    MOV AH , 02h        ;posicionar cursor
    INT 10h
    
    MOV AH , color_snake ; color
    MOV BL , AH         
    MOV AH , 09h        ;escribir caracter
    MOV AL , comida_char     ;caracter de comida
    MOV CX , 01h
    INT 10h
    POP AX
    POP BX
    POP CX
    POP DX
    RET
DibujarComida ENDP

;Procedimeinto que permite dibujar el recuadro sin esquinas del juego
DibujarMarco PROC
; colocar posicion del cursor
; INT 10h
; AH = 02h  BH = Page Number, DH = Row, DL = Column

; escribir caracter en la posicion
; INT 10h
; AH = 09h  AL = Character, BH = Page Number, BL = Color,
; CX = numero de veces a escribir

    ;caracter borde horizontal
    MOV BH , 0              ; pagina
    MOV AL , 205            ; character de borde
    MOV BL , color_cuadro   ; color 
        
    ; posicionar cursor
    MOV DH , esquina00[0]  ; esquina superior izquierda
    MOV DL , esquina00[1]
    MOV AH , 02h
    INT 10h
    
    XOR CX,CX
    MOV CL , tamano_cuadro_x ; ancho
    ADD CX , 2
borde_superior:
    push CX
    MOV AH , 09h        ;impresion de caracter
    MOV CX , 01h        ;numero de caracteres
    INT 10h
    
    MOV AH , 02h        ;posicioin del cursor
    INC DL              ;siguiente columna
    INT 10h
    
    pop CX
    loop borde_superior
    
    ;posicionar cursor
    MOV DH , esquina10[0]  ;esquina inferior izquierda
    MOV DL , esquina10[1]
    MOV AH , 02h
    INT 10h
    
    XOR CX,CX
    MOV cl , tamano_cuadro_x ; ancho
    ADD CX , 2
borde_inferior:
    push CX
    MOV AH , 09h
    MOV CX , 01h
    INT 10h
    
    MOV AH , 02h
    INC DL                  ;siguiente columna
    INT 10h
    
    pop CX
    loop borde_inferior
  
    ; ;cambiar caracter borde vertical 
    MOV BH , 0          ; page number
    MOV AL , 186        ;caracter borde
    MOV BL , 7fh        ;color 
    
    ;posicionar cursor
    MOV DH , esquina00[0]  ; top left corner
    MOV DL , esquina00[1]
    MOV AH , 02h
    INT 10h
    
    XOR CX,CX
    MOV cl , tamano_cuadro_y ; alto
    ADD CX , 2
borde_izquierdo:
    push CX
    MOV AH , 09h
    MOV CX , 01h
    INT 10h
    
    MOV AH , 02h
    INC DH                  ;siguiente fila
    INT 10h
    
    pop CX
    loop borde_izquierdo    
    
    ;posicionar cursor
    MOV DH , esquina01[0]   ;esquina superior derecha
    MOV DL , esquina01[1]
    MOV AH , 02h
    INT 10h
    
    XOR CX,CX
    MOV cl , tamano_cuadro_y ;alto
    ADD CX , 2
borde_derecho:
    push CX
    MOV AH , 09h
    MOV CX , 01h
    INT 10h
    
    MOV AH , 02h
    INC DH                  ; siguiente fila
    INT 10h
    
    pop CX
    loop borde_derecho    
           
    RET
DibujarMarco ENDP

;Procedimiento que dibuja las esquinas del recuadro del juego

DibujarEsquina PROC
    MOV BH , 0  
    MOV BL , color_cuadro 
        
    ; esquina superior izquierda
    MOV AL , 201            ;caracter esquina
    MOV DH , esquina00[0]  
    MOV DL , esquina00[1]
    MOV AH , 02h
    INT 10h
    
    MOV AH , 09h
    MOV CX , 01h
    INT 10h
        
    ; esquina superior derecha
    MOV AL , 187            ;caracter esquina
    MOV DH , esquina01[0]  
    MOV DL , esquina01[1]
    MOV AH , 02h
    INT 10h
    
    MOV AH , 09h
    MOV CX , 01h
    INT 10h
       
    ; esquina inferior izquierda
    MOV AL , 200            ;caracter esquina
    MOV DH , esquina10[0]  
    MOV DL , esquina10[1]
    MOV AH , 02h
    INT 10h
    
    MOV AH , 09h
    MOV CX , 01h
    INT 10h
       
    ; esquina inferior derecha
    MOV AL , 188            ;caracter esquina
    MOV DH , esquina11[0]  
    MOV DL , esquina11[1]
    MOV AH , 02h
    INT 10h
    
    MOV AH , 09h
    MOV CX , 01h
    INT 10h
   
    RET 
DibujarEsquina ENDP

LimpiarPantalla PROC
    MOV AX, 0600H    ;06 SCROLL pantalla & 00 para toda la pantalla
    MOV BH, 00H      ;color a pintar
    MOV CX, 0000H    ;posicion de inicio
    MOV DX, 184FH    ;posicion final
    INT 10H          
    RET
LimpiarPantalla ENDP

Mostrar_Menu PROC
		MOV DX, Offset menu
		MOV AH, 09h
		INT 21H
		RET
Mostrar_Menu ENDP

End programa
