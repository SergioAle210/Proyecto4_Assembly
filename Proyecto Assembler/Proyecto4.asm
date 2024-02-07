; UNIVERSIDAD DEL VALLE DE GUATEMALA 
; Organizacion de computadoras y Assembler
; Ciclo 1 - 2023
;
;Profesora: Kimberly Barrera
;Auxiliares: Fabian Juarez y Sara Perez
;
;INTEGRANTES: 
;Nombres: 
;Sergio Alejandro Orellana Colindres, 221122
;Joaquin Andre Puente Grajeda, 22296
;Rodrigo Alfonso Mansilla, 221087
;Fecha: 14/05/2023
;Nombre de la tarea: Proyecto 4
;Sección: 30 */

.386
.model flat, stdcall, c
.stack 4096
;ExitProcess proto,dwExitCode:dword

; ----------------------------------------------- 
; SECCION DE DECLARACIÓN DE VARIABLES
; ----------------------------------------------- 
.data
	ArrayRanas BYTE 'a', 'a', 'a', ' ', 'b', 'b', 'b', 0
	PosicionesCorrectas DWORD 0
	Bienvenida BYTE "					****Welcome to Jump Frog****", 0Ah, 0
	Descripcion BYTE "Descripcion del juego:", 0Ah, "Este juego consiste en 7 posiciones, y 6 ranas, 3 ranas de la especie (b) estan localizadas en la parte derecha ",0Ah, "y 3 ranas de la especie (a) estan ubicadas en la parte izquierda de las posiciones, dejando asi un unico espacio vacio. ", 0Ah, 0Ah, 0
	OpcionUsuario BYTE "%d", 0
	Instrucciones BYTE "Instrucciones del juego:",0Ah, "1. Las ranas no pueden retroceder", 0Ah, "2. Solo pueen moverse un espacio a la vez", 0Ah, "3. Las ranas de distinta especie pueden saltarse otra rana si existe un espacio vacio adelante", 0Ah, "4. Las ranas de la misma especie no pueden saltarse entre ellas", 0Ah,"5. DEBES EMPEZAR CON LAS RANAS DEL LADO IZQUIERDO", 0Ah, 0
	Inicio BYTE "Ingrese la opcion que desea: ", 0Ah, "1. Ingresar al Juego", 0Ah, "2. Instrucciones", 0Ah, "3. Salir del juego", 0Ah, 0
    Finalizado BYTE "Ha finalizado el juego, gracias por jugarlo", 0Ah, 0
    EstadoActualRanas BYTE "Estado actual de las ranas: ", 0Ah, 0
    fmtRanas BYTE "%s",0
    Posiciones BYTE "1234567",0Ah ,0
	SaltodeLinea BYTE " ",0Ah, 0
    Contador DWORD 0
    msgNoValido BYTE "El valor ingresado no es valido. Por favor, ingrese un numero entre 1 y 7. Intenta nuevamente.", 0Ah, 0
    msgNoValidoInicio BYTE "El valor ingresado no es valido. Por favor, ingrese un numero entre 1 y 3. Intenta nuevamente.", 0Ah, 0
    Ocupado BYTE "La posicion seleccionada esta ocupada. Intenta nuevamente.", 0Ah, 0 
    msgVacio BYTE "Esta Vacio", 0Ah, 0
    msgGanaste BYTE "Felicidades! Has ganado el juego.", 0Ah, 0
    msgPerdiste BYTE "Te has quedado sin vidas", 0Ah, 0Ah, "Has perdido, inserta moneda para jugar", 0Ah, 0
    msgIngresaPos BYTE "Ingresa el numero de la posicion de la rana que deseas mover (0 para salir): ", 0
    MovimientoRanas DWORD 0
    Intentos DWORD 5
    msgVidas BYTE "Tienes %d Vidas", 0Ah, 0
    ContadorImpresiones DWORD 0

    ;Mensaje Ranas
    msgRanasPart1_B BYTE "   o)__       ", 0
    msgRanasPart2_B BYTE "  (_  _`\     ", 0
    msgRanasPart3_B BYTE "   z/z\__)    ", 0
    msgRanasVacio BYTE "______", 0
    msgRanasPart1_A BYTE "     __(o   ",0
    msgRanasPart2_A BYTE "   /`_  _)  ",0
    msgRanasPart3_A BYTE "  (__/z/z   ",0

; ----------------------------------------------- 
; SECCION DE DEFINICIÓN DE CÓDIGO
; ----------------------------------------------- 
; ------------ Librerías utilizadas -------------
.code
	includelib libucrt.lib
	includelib legacy_stdio_definitions.lib
	includelib libcmt.lib
	includelib libvcruntime.lib

	extrn printf:near
	extrn exit:near
	extrn scanf:near
; ------------ Rutina Principal -------------
public main
main PROC 
	mov edx, 0

	push offset Bienvenida								; Se le da la bienvenida al usuario 
	call printf

	push offset Descripcion								; Se le da la descripcion del juego
	call printf

     StartLoop:                                         ; loop inicial
        push offset Inicio                              ; Mensaje de inicio, interaccion con el usuario
        call printf                                  

        sub esp, 8                                      ;Reserva el pila 2 espacios de 4B: 1p/cada dato a ing. x teclado            

        lea eax, [ebp - 8]                              ; Direccion donde se guardara el primer operando desde teclado
        push eax                                        ; 1. Damos direccion donde se guardara el dato con scanf
        push offset OpcionUsuario                       ; 2. Que tipo de dato se ingresara = formato
        call scanf

        mov eax, [ebp - 8]                              ; Se guarda la opcion del usuario en eax
            
        cmp eax, 1
        jl InvalidInput                                 ; Salta a InvalidInput si eax < 1
        cmp eax, 3
        jg InvalidInput                                 ; Salta a InvalidInput si eax > 3

        jmp ValidInput                                  ; Salta a ValidInput si el valor está entre 1 y 3

        InvalidInput:
            push offset SaltodeLinea                    ; Salto de linea
            call printf
            push offset msgNoValidoInicio               ; Se muestra un mensaje que 
            call printf
            jmp StartLoop                               ; Vuelve a pedir al usuario que ingrese un valor

        ValidInput:
            cmp eax, 1
            je LabelJuego                               ; Se mueve al label del juego
            cmp eax, 2
            je Instrucs                                 ; Se mueve al label de las isntrucciones
            cmp eax, 3
            je Salir                                    ; Se mueve al label de salir

        LabelJuego:

            mov esi, offset ArrayRanas                      ; Se obtiene una nueva direccion del Array
            mov edi, offset ArrayRanas                      ; Se obtiene una nueva direccion del Array
            mov ContadorImpresiones, 0                      ; Se reinicia el Contador que lleva el conteo de las impresiones de las ranas
            
            push offset SaltodeLinea
            call printf

            push DWORD ptr Intentos                         ; Se ingresa el valor de Intentos en el mensaje que muestra el total de vidas
            push offset msgVidas                            ; Se imprime el mensaje de vidas
            call printf

            push offset SaltodeLinea
            call printf

            cmp Intentos, 0                                 ; Compara si las vidas que tiene el usuario son 0
            je Perdido

            
            ImpresionRanas:                                 ; De no ser así, imprime las ranitas
                
                cmp ContadorImpresiones, 7                  ; Compara que sean 7 impresiones totales, ya que son 7 posiciones
                je ImpresionRanasPart2
                cmp byte ptr [edi], 'a'                     ; Compara si en la posicion que esta es "a"
                je ImpresionRanasA
                cmp byte ptr [edi], ' '                     ; Compara si en la posicion que esta es " "
                je ImpresionRanasEspacio
                cmp byte ptr [edi], 'b'                     ; Compara si en la posicion que esta es "b"
                je ImpresionRanasB

                ImpresionRanasA:
                    push offset msgRanasPart1_A             ; Sirve para imprimir la parte de arriba de las ranitas de la raza "a"
                    call printf
                    add edi, 1                              ; Se mueve una posicion en el array hacia la derecha
                    add ContadorImpresiones, 1              ; Se aumenta el conteo de impresiones, ya que tiene que hacer 7 impresiones ya que son 7 posiciones
                    jmp ImpresionRanas                      
                
                ImpresionRanasEspacio:
                    push offset msgRanasVacio               ; Sirve para imprimir el espacio vacio
                    call printf
                    add edi, 1                              ; Se mueve una posicion en el array hacia la derecha
                    add ContadorImpresiones, 1              ; Se aumenta el conteo de impresiones
                    jmp ImpresionRanas

                ImpresionRanasB:
                    push offset msgRanasPart1_B             ; Sirve para imprimir la parte de arriba de las ranitas de la raza "b"
                    call printf
                    add edi, 1                              ; Se mueve una posicion en el array hacia la derecha
                    add ContadorImpresiones, 1              ; Se aumenta el conteo de impresiones
                    jmp ImpresionRanas                      

                ImpresionRanasPart2:
                    mov edi, offset ArrayRanas                          ; Se obtiene nuevamente la posicion inicial del Array
                    mov ContadorImpresiones, 0                          ; Se reinicia el contador
                    push offset SaltodeLinea                
                    call printf

                    ImpresionRanasPart2_:
                        cmp ContadorImpresiones, 7                      ; Compara que sean 7 impresiones totales, ya que son 7 posiciones
                        je ImpresionRanasPart3
                        cmp byte ptr [edi], 'a'                         ; Compara si en la posicion que esta es "a"
                        je ImpresionRanasA_Part2
                        cmp byte ptr [edi], ' '                         ; Compara si en la posicion que esta es " "
                        je ImpresionRanasEspacio_Part2
                        cmp byte ptr [edi], 'b'                         ; Compara si en la posicion que esta es "b"
                        je ImpresionRanasB_Part2

                        ImpresionRanasA_Part2:
                            push offset msgRanasPart2_A                 ; Sirve para imprimir la parte de en medio de las ranitas de la raza "a"      
                            call printf
                            add edi, 1                                  ; Se mueve una posicion en el array hacia la derecha
                            add ContadorImpresiones, 1                  ; Se aumenta el conteo de impresiones
                            jmp ImpresionRanasPart2_
                
                        ImpresionRanasEspacio_Part2:
                            push offset msgRanasVacio                   ; Sirve para imprimir una representacion de un espacio vacio 
                            call printf
                            add edi, 1                                  ; Se mueve una posicion en el array hacia la derecha
                            add ContadorImpresiones, 1                  ; Se aumenta el conteo de impresiones
                            jmp ImpresionRanasPart2_

                        ImpresionRanasB_Part2:
                            push offset msgRanasPart2_B                 ; Sirve para imprimir la parte de en medio de las ranitas de la raza "b"
                            call printf
                            add edi, 1                                  ; Se mueve una posicion en el array hacia la derecha
                            add ContadorImpresiones, 1                  ; Se aumenta el conteo de impresiones
                            jmp ImpresionRanasPart2_
                    
                    ImpresionRanasPart3:
                        mov edi, offset ArrayRanas                          ; Se obtiene nuevamente la posicion inicial del Array
                        mov ContadorImpresiones, 0                          ; Se reinicia el contador
                        push offset SaltodeLinea
                        call printf

                        ImpresionRanasPart3_:
                            cmp ContadorImpresiones, 7                      ; Compara que sean 7 impresiones totales, ya que son 7 posiciones
                            je SeguirPrograma
                            cmp byte ptr [edi], 'a'                         ; Compara si en la posicion que esta es "a"
                            je ImpresionRanasA_Part3
                            cmp byte ptr [edi], ' '                         ; Compara si en la posicion que esta es " "
                            je ImpresionRanasEspacio_Part3
                            cmp byte ptr [edi], 'b'                         ; Compara si en la posicion que esta es "b"
                            je ImpresionRanasB_Part3
                            ImpresionRanasA_Part3:
                                push offset msgRanasPart3_A                 ; Sirve para imprimir la parte de abajo de las ranitas de la raza "a"  
                                call printf
                                add edi, 1                                  ; Se mueve una posicion en el array hacia la derecha
                                add ContadorImpresiones, 1                  ; Se aumenta el conteo de impresiones
                                jmp ImpresionRanasPart3_
                
                            ImpresionRanasEspacio_Part3:
                                push offset msgRanasVacio                   ; Sirve para imprimir una representacion de un espacio vacio
                                call printf
                                add edi, 1                                  ; Se mueve una posicion en el array hacia la derecha
                                add ContadorImpresiones, 1                  ; Se aumenta el conteo de impresiones
                                jmp ImpresionRanasPart3_

                            ImpresionRanasB_Part3:
                                push offset msgRanasPart3_B                 ; Sirve para imprimir la parte de abajo de las ranitas de la raza "b"
                                call printf
                                add edi, 1                                  ; Se mueve una posicion en el array hacia la derecha
                                add ContadorImpresiones, 1                  ; Se aumenta el conteo de impresiones
                                jmp ImpresionRanasPart3_


            SeguirPrograma:

                push offset SaltodeLinea
                call printf

                push offset SaltodeLinea
                call printf

                push offset EstadoActualRanas                           ; Se imprime un mensaje con el Estado actual de las ranas
                call printf

                push esi                                                ; Se pushea el Array ranas a la pila
                push offset fmtRanas                                    ; Se imprimen todas las ranas como una cadena
                call printf

                push offset SaltodeLinea
                call printf

                push offset Posiciones                                  ; Se imprimen los numeros de las posiciones que el usuario puede utilizar
                call printf

                push offset SaltodeLinea
                call printf

                push offset msgIngresaPos                               ; Se le muestran las opciones que puede seleccionar  
                call printf
               
                lea eax, [ebp - 4]                                      ; Direccion donde se guardara el primer operando desde teclado
                push eax                                                ; 1. Damos direccion donde se guardara el dato con scanf
                push offset OpcionUsuario                               ; 2. Que tipo de dato se ingresara = formato
                call scanf

                mov eax, [ebp - 4]                                      ;Se guarda el valor que el usuario ingreso
                
                cmp eax, 0
                je Salir                                                ; Salta al label Salir si el usuario presiona 0
                cmp eax, 1
                jge CheckValid                                          ; Salta a CheckValid si eax >= 1
                jmp Invalid                                             ; Salta a Invalid si eax < 1

                CheckValid:
                    cmp eax, 7
                    jle Valid                                           ; Salta a Valid si eax <= 7
                    jmp Invalid                                         ; Salta a Invalid si eax > 7

                Valid:
                
                    mov ebx, eax                                        ;Aqui estoy obteniendo el input que el usuario ingreso
                    cmp MovimientoRanas, 0
                    je Label0                                           ;Primer Movimiento
                    cmp MovimientoRanas, 1
                    je Label1                                           ;Segundo Movimiento
                    cmp MovimientoRanas, 2
                    je Label2                                           ;Tercer Movimiento
                    cmp MovimientoRanas, 3
                    je Label3                                           ;Cuarto Movimiento
                    cmp MovimientoRanas, 4
                    je Label3                                           ;Quinto Movimiento
                    cmp MovimientoRanas, 5
                    je Label4                                           ;Sexto Movimiento
                    cmp MovimientoRanas, 6
                    je Label5                                           ;Septimo Movimiento
                    cmp MovimientoRanas, 7
                    je Label5                                           ;Octavo Movimiento
                    cmp MovimientoRanas, 8
                    je Label5                                           ;Noveno Movimiento
                    cmp MovimientoRanas, 9
                    je Label0                                           ;Decimo Movimiento
                    cmp MovimientoRanas, 10
                    je Label3                                           ;Onceavo Movimiento
                    cmp MovimientoRanas, 11
                    je Label3                                           ;Doceavo Movimiento
                    cmp MovimientoRanas, 12
                    je Label2                                           ;Treceavo Movimiento
                    cmp MovimientoRanas, 13
                    je Label5                                           ;Catorceavo Movimiento
                    cmp MovimientoRanas, 14
                    je Label0                                           ;Quinceavo Movimiento
                

                    Label0:
                        ; Cabe resaltar que lo que aparece a continuacion es un ejemplo de lo que pudiera suceder
                        mov al, byte ptr [esi + ebx]                            ; Obtengo la posicion que el usuario selecciono, en este caso es 3
                        cmp al, " "                                             ; Compara si el espacio es vacio
                        je EstaVacio0                                       
                        jne EstaOcupado
                        EstaVacio0:
                            mov byte ptr [esi + ebx], 'a'                       ; Reemplaza la posición actual por la letra "a"
                            sub ebx, 1                                          ; Se le resta un desplazamiento, para regresar en la posicion que la ranita estaba inicialmente
                            mov byte ptr [esi + ebx], ' '                       ; Reemplaza esa posicion por un espacio vacio
                            add MovimientoRanas, 1                              ; Se le agrega uno a la cantidad de movimientos que tienen que hacer las ranitas para que esten todas las "a" a la derecha y todas las "b" a la izquierda
                            cmp MovimientoRanas, 15                             ; Se compara si el total de movimientos de 15
                            je Ganador                                          ; Salta al Label ganador si es que gano el juego
                            jmp LabelJuego                                      ; Regresa al label del juego
             
                    Label1:
                        ; Cabe resaltar que lo que aparece a continuacion es un ejemplo de lo que pudiera suceder
                        sub ebx, 3                                              ; Aqui es porque el usuario presiono 5 y la posicion que esta vacia es 2, siempre tomando en cuenta que el Array en nuestro caso va de 0 a 6                 
                        mov al, byte ptr [esi + ebx]                            ; Obtengo la posicion en blanco
                        cmp al, " "                                             ; Se compara si esa posicion esta vacia
                        je EstaVacio1
                        jne EstaOcupado
                        EstaVacio1:
                            mov byte ptr [esi + ebx], 'b'                       ; Reemplaza la posición actual por la letra "b"
                            add ebx, 2                                          ; Se le agrega dos desplazamientos, para regresar en la posicion que la ranita estaba inicialmente
                            mov byte ptr [esi + ebx], ' '                       ; Se le reemplaza esa posicion por un espacio vacio
                            add MovimientoRanas, 1                              ; Se le agrega uno a la cantidad de movimientos que tienen que hacer las ranitas para que esten todas las "a" a la derecha y todas las "b" a la izquierda     

                            jmp LabelJuego                                      ; Regresa al label del juego

                    Label2:
                        ; Cabe resaltar que lo que aparece a continuacion es un ejemplo de lo que pudiera suceder
                        sub ebx, 2                                              ; Aqui es porque el usuario presiono 6 y la posicion que esta vacia es 4, siempre tomando en cuenta que el Array en nuestro caso va de 0 a 6            
                        mov al, byte ptr [esi + ebx]                            ; Obtengo la posicion en blanco
                        cmp al, " "                                             ; Se compara si esa posicion esta vacia
                        je EstaVacio2
                        jne EstaOcupado
                        EstaVacio2:
                            mov byte ptr [esi + ebx], 'b'                       ; Reemplaza la posición actual por la letra "b"
                            add ebx, 1                                          ; Se le agrega un desplazamiento, para regresar en la posicion que la ranita estaba inicialmente
                            mov byte ptr [esi + ebx], ' '                       ; Se le reemplaza esa posicion por un espacio vacio
                            add MovimientoRanas, 1                              ; Se le agrega uno a la cantidad de movimientos que tienen que hacer las ranitas para que esten todas las "a" a la derecha y todas las "b" a la izquierda

                            jmp LabelJuego                                      ; Regresa al label del juego
        
                    Label3:
                        ; Cabe resaltar que lo que aparece a continuacion es un ejemplo de lo que pudiera suceder
                        add ebx, 1                                              ; Aqui es porque el usuario presiono 4 y la posicion que esta vacia es 5, siempre tomando en cuenta que el Array en nuestro caso va de 0 a 6       
                        mov al, byte ptr [esi + ebx]                            ; Obtengo la posicion en blanco
                        cmp al, " "                                             ; Se compara si esa posicion esta vacia
                        je EstaVacio3
                        jne EstaOcupado
                        EstaVacio3:
                            mov byte ptr [esi + ebx], 'a'                       ; Reemplaza la posición actual por la letra "a"
                            sub ebx, 2                                          ; Se le restan dos desplazamientos, para regresar en la posicion que la ranita estaba inicialmente
                            mov byte ptr [esi + ebx], ' '                       ; Se le reemplaza esa posicion por un espacio vacio
                            add MovimientoRanas, 1                              ; Se le agrega uno a la cantidad de movimientos que tienen que hacer las ranitas para que esten todas las "a" a la derecha y todas las "b" a la izquierda

                            jmp LabelJuego                                      ; Regresa al label del juego
               
                    Label4:
                        ; Cabe resaltar que lo que aparece a continuacion es un ejemplo de lo que pudiera suceder
                        mov al, byte ptr [esi + ebx]                            ; Obtengo la posicion que esta vacia en este caso es 1, siempre tomando en cuenta que el Array en nuestro caso va de 0 a 6
                        cmp al, " "                                             ; Se compara si esa posicion esta vacia
                        je EstaVacio5
                        jne EstaOcupado
                        EstaVacio5:
                            mov byte ptr [esi + ebx], 'a'                       ; Reemplaza la posición actual por la letra "a"
                            sub ebx, 1                                          ; Se le resta un desplazamiento, para regresar en la posicion que la ranita estaba inicialmente
                            mov byte ptr [esi + ebx], ' '                       ; Se le reemplaza esa posicion por un espacio vacio
                            add MovimientoRanas, 1                              ; Se le agrega uno a la cantidad de movimientos que tienen que hacer las ranitas para que esten todas las "a" a la derecha y todas las "b" a la izquierda

                            jmp LabelJuego                                      ; Regresa al label del juego

                    Label5:
                        ; Cabe resaltar que lo que aparece a continuacion es un ejemplo de lo que pudiera suceder
                        sub ebx, 3                                              ; Aqui es porque el usuario presiono 3 y la posicion que esta vacia es 0, siempre tomando en cuenta que el Array en nuestro caso va de 0 a 6            
                        mov al, byte ptr [esi + ebx]                            ; Obtengo la posicion en blanco
                        cmp al, " "                                             ; Se compara si esa posicion esta vacia
                        je EstaVacio6
                        jne EstaOcupado
                        EstaVacio6:
                            mov byte ptr [esi + ebx], 'b'                       ; Reemplaza la posición actual por la letra "b"
                            add ebx, 2                                          ; Se le agregan dos desplazamientos, para regresar en la posicion que la ranita estaba inicialmente
                            mov byte ptr [esi + ebx], ' '                       ; Se le reemplaza esa posicion por un espacio vacio
                            add MovimientoRanas, 1                              ; Se le agrega uno a la cantidad de movimientos que tienen que hacer las ranitas para que esten todas las "a" a la derecha y todas las "b" a la izquierda

                            jmp LabelJuego                                      ; Regresa al label del juego
                
                    EstaOcupado: 
                        push offset SaltodeLinea
                        call printf
                        push offset Ocupado                                     ; Esta ocupada la posicion que el usuario selecciono
                        call printf
                        sub Intentos, 1                                         ; Se le quita una vida
                        jmp LabelJuego

                    Ganador:
                        call RanitasImpresion                                   ; Se llama a la subrutina RanitasImpresion que hace la impresion de todo cuando el usuario gana
                        call RutinaGanaste                                      ; Llama a la subrutina Ganaste y le muestra el mensaje de que gano
                        jmp Salir

                    Perdido:                                        
                        call RutinaPerdido                                      ; llama a la subrutina Perdiste donde le muestra el mensaje que ha perdido

                        jmp Salir                                               ; Salta al Label Salir y lo saca del juego

            Invalid:                                                ; Entra cuando el input no esta en el rango
                push offset SaltodeLinea
                call printf
                push offset msgNoValido                             ; Imprime un mensaje de que los valores ingresados no están en el rango de 1 a 7
                call printf

                jmp LabelJuego                                      ; Salta nuevamente al label donde se juega

        Instrucs:                                                   ;Impresion de las Instrucciones
            push offset SaltodeLinea
            call printf
            push offset Instrucciones
            call printf
            push offset SaltodeLinea
            call printf
            jmp StartLoop                                           ; Salta al menu principal

        Salir:
            push offset SaltodeLinea
            call printf
            push offset Finalizado                                  ; Le muestra un mensaje de que se ha finalizado el juego
            call printf
            push 0
            call exit

    push 0
    call exit

main ENDP
; ------------ SUBRUTINAS -------------
;___________________________________________
;RanitasImpresion
;input: var global ArrayRanas BYTE
;output: Imprime las ranitas
;___________________________________________
;Autor: Sergio Orellana
RanitasImpresion PROC
mov ContadorImpresiones, 0
mov edi, offset ArrayRanas

ImpresionRanas:                                         ; Aqui hace lo mismo que esta en la parte superior, es lo mismo solamente que este lo utilizamos especificamente cuando el usuario gana el juego
    cmp ContadorImpresiones, 7
    je ImpresionRanasPart2
    mov al, byte ptr [edi]
    cmp byte ptr [edi], 'a'
    je ImpresionRanasA
    cmp byte ptr [edi], ' '
    je ImpresionRanasEspacio
    cmp byte ptr [edi], 'b'
    je ImpresionRanasB

    ImpresionRanasA:
        push offset msgRanasPart1_A
        call printf
        add edi, 1
        add ContadorImpresiones, 1
        jmp ImpresionRanas
                
    ImpresionRanasEspacio:
        push offset msgRanasVacio
        call printf
        add edi, 1
        add ContadorImpresiones, 1
        jmp ImpresionRanas

    ImpresionRanasB:
        push offset msgRanasPart1_B
        call printf
        add edi, 1
        add ContadorImpresiones, 1
        jmp ImpresionRanas

    ImpresionRanasPart2:
        mov edi, offset ArrayRanas
        mov ContadorImpresiones, 0                          ; Se reinicia el contador
        push offset SaltodeLinea
        call printf

        ImpresionRanasPart2_:
            cmp ContadorImpresiones, 7
            je ImpresionRanasPart3
            mov al, byte ptr [edi]
            cmp byte ptr [edi], 'a'
            je ImpresionRanasA_Part2
            cmp byte ptr [edi], ' '
            je ImpresionRanasEspacio_Part2
            cmp byte ptr [edi], 'b'
            je ImpresionRanasB_Part2

            ImpresionRanasA_Part2:
                push offset msgRanasPart2_A
                call printf
                add edi, 1
                add ContadorImpresiones, 1
                jmp ImpresionRanasPart2_
                
            ImpresionRanasEspacio_Part2:
                push offset msgRanasVacio
                call printf
                add edi, 1
                add ContadorImpresiones, 1
                jmp ImpresionRanasPart2_

            ImpresionRanasB_Part2:
                push offset msgRanasPart2_B
                call printf
                add edi, 1
                add ContadorImpresiones, 1
                jmp ImpresionRanasPart2_
                    
        ImpresionRanasPart3:
            mov edi, offset ArrayRanas
            mov ContadorImpresiones, 0                          ; Se reinicia el contador
            push offset SaltodeLinea
            call printf

            ImpresionRanasPart3_:
                cmp ContadorImpresiones, 7
                je SeguirPrograma2
                mov al, byte ptr [edi]
                cmp byte ptr [edi], 'a'
                je ImpresionRanasA_Part3
                cmp byte ptr [edi], ' '
                je ImpresionRanasEspacio_Part3
                cmp byte ptr [edi], 'b'
                je ImpresionRanasB_Part3
                ImpresionRanasA_Part3:
                    push offset msgRanasPart3_A
                    call printf
                    add edi, 1
                    add ContadorImpresiones, 1
                    jmp ImpresionRanasPart3_
                
                ImpresionRanasEspacio_Part3:
                    push offset msgRanasVacio
                    call printf
                    add edi, 1
                    add ContadorImpresiones, 1
                    jmp ImpresionRanasPart3_

                ImpresionRanasB_Part3:
                    push offset msgRanasPart3_B
                    call printf
                    add edi, 1
                    add ContadorImpresiones, 1
                    jmp ImpresionRanasPart3_

SeguirPrograma2:
    push offset SaltodeLinea
    call printf
    push offset SaltodeLinea
    call printf

    push offset EstadoActualRanas               ; Se imprime el mensaje del estado actual de las ranas
    call printf

    push esi                                    ; Se pushea la cadena de "a", "a", "a", " ", "b", "b", "b" 
    push offset fmtRanas                        ; Se imprimen todas las ranas
    call printf
    push offset SaltodeLinea
    call printf
    push offset SaltodeLinea
    call printf

RanitasImpresion ENDP
;___________________________________________
;RutinaGanaste
;input: Nada
;output: Imprime el mensaje de que ha ganado y sale del programa
;___________________________________________
;Autor: Sergio Orellana
RutinaGanaste PROC

push offset msgGanaste                      ; Se le muestra un mensaje de que ha ganado el juego
call printf

push offset SaltodeLinea
call printf
push offset Finalizado                      ; Se le muestra un mensaje de que ha finalizado el juego
call printf
push 0                                      ; Sale del programa
call exit
RutinaGanaste ENDP
;___________________________________________
;RutinaPerdido
;input: Nada
;output: Imprime el mensaje de que ha perdido y sale del programa
;___________________________________________
;Autor: Sergio Orellana
RutinaPerdido PROC

push offset SaltodeLinea
call printf
push offset msgPerdiste                     ;Le muestra este mensaje si es que el usuario se queda sin vidas
call printf 
push offset SaltodeLinea
call printf
push offset Finalizado                                  ; Le muestra un mensaje de que se ha finalizado el juego
call printf

RutinaPerdido ENDP
END
