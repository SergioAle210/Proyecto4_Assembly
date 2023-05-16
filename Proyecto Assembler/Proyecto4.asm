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

.data

	
.code

	;Se agregan las librerias
	includelib libucrt.lib
	includelib legacy_stdio_definitions.lib
	includelib libcmt.lib
	includelib libvcruntime.lib

	extrn printf:near
	extrn exit:near

;main
main PROC 
	
	mov edx, 0
	

main ENDP
END