; Write
; Compile with: nasm -f elf write.asm
; Link with (64 bit systems require elf_i386 option): ld -m elf_i386 write.o -o write
; Run with: ./write
 
;%include    "io.inc"
;%include    '/home/jose/Documents/isa/x86/test/functions.asm'     

section .data
    filename db 'archivoEntrada.txt', 0h    ; the filename to create
    contents db 'WE MOURN THE BROKEN THINGS, CHAIR LEGS WRENCHED FROM THEIR SEATS, CHIPPED PLATES, THE THREADBARE CLOTHES. WE WORK THE MAGIC OF GLUE, DRIVE THE NAILS, MEND THE HOLES. - ', 0h  ; the contents to write
    outputTXT db 'output.txt', 0h    ; the filename to create output
    
section .bss
    fileContents:       resb    1681          ; variable to store file contents
    pixeles:            resb    62500
    columna_i:          resb    1 ;empezar en 1
    fila_j:             resb    1 ;empezar en 0
    contadorLetra:      resb    1 ;empezar en 0
    contadorRenglon:    resb    1 ;empezar en 0
    X0:                 resb    1
    Y0:                 resb    1
    Xf:                 resb    1
    Yf:                 resb    1
    deltaX:             resb    2
    deltaY2:            resb    2
    Pk:                 resb    2
    Pk_1:               resb    1
    direccionActual:    resd    1       ;reserva la direccion actual
    deltaY:             resb    2

section .text
global _start    
    
_start:
    mov ebp, esp; for correct debugging
    mov     ecx, 0777o          ; Create file from lesson 22
    mov     ebx, filename
    mov     eax, 8
    int     80h
 
    mov     edx, 169             ; Write contents to file from lesson 23
    mov     ecx, contents
    mov     ebx, eax
    mov     eax, 4
    int     80h
 
    mov     ecx, 0              ; Open file from lesson 24
    mov     ebx, filename
    mov     eax, 5
    int     80h
 
    mov     edx, 169           ; number of bytes to read - one for each letter of the file contents
    mov     ecx, fileContents   ; move the memory address of our file contents variable into ecx
    mov     ebx, eax            ; move the opened file descriptor into EBX
    mov     eax, 3              ; invoke SYS_READ (kernel opcode 3)
    int     80h                 ; call the kernel
 
    mov     eax, fileContents   ; move the memory address of our file contents variable into eax for printing
    call    sprintLF            ; call our string printing function
    
    mov     dword[direccionActual], pixeles ;asigna la direccion actual a pixeles

    push    ebx
    push    edx

    mov     edx, fileContents
    mov     bl, [edx]
    call    buscarLetra
    
    pop     ebx
    pop     edx
 
    jmp    quit                ; call our quit function
    
comprobarEspacio:

    inc     edx ;incrementa la direccion de memoria
    ;add     ecx, 1 ;aumenta la replica de contadorLetra
    
    cmp     byte[edx], 0x20 ;se fija hasta que haya un espacio
    jne     comprobarFinal
    
    mov     ecx, 0
    mov     cl, [columna_i]
    push    ebx
    mov     ebx, 0
    mov     bl, 138
    cmp     bl, cl
    pop     ebx
    jle     retornarVal   
    
    jmp     cambiarRenglon

comprobarFinal:

    cmp     byte[edx], 0x0 ;se fija si ya no hay texto
    je      funcionFinal
    jmp     comprobarEspacio

cambiarRenglon:
    mov     eax, 0
    mov     eax, 1
    add     [contadorRenglon], al ;se suma 1 al contador para cambiar de renglon
    mov     eax, 6
    add     [fila_j], al ;se suman 6 pixeles para abajo
    
    mov     eax, 0
    ;mov     [contadorLetra], al ;se reinicia el contador de letras por ser un nuevo renglon
    mov     [columna_i], al ;se reinicia el contador de pixeles para columnas
    
    mov     al, [contadorRenglon]
    cmp     al, 41
    jge     retornarVal
    ret     

cambiarLetra:
    push    eax
    mov     eax, 6
    add     [columna_i], eax
    mov     eax, 1
    add     [contadorLetra], eax
    pop     eax
    ret
;------------------------------------------
; int cases(letter value)
; choose which case to draw
buscarLetra:    

    push    ecx
    mov     ecx, 0
    add     cl, [contadorLetra] ;para ver el espacio por el que vamos
    call    comprobarEspacio
    
    cmp     eax, 0 ;para saber si hay espacio en donde escribir, va a ser 0 si no hay espacio y retornaria
    je      retornar ;para devolverse porque ya no hay donde escribir
    pop     ecx
    
    mov     edx, fileContents
    mov     eax, 0
    mov     al, [contadorLetra]
    add     edx, eax
    mov     bl, [edx] ;edx va a ser el puntero a memoria, ebx va a ser donde se guarda el valor que apunta la memoria
    call    cases
    pop     eax ; devuelve el valor original de eax
    call    cambiarLetra
    
    mov     edx, fileContents
    mov     ebx, 0
    mov     bl, [contadorLetra]
    add     edx, ebx
    mov     ebx, 0
    mov     bl, [edx]
    cmp     bl,    0 ;cuando en fileContents encuentre un 0 debe parar porque ya no hay informacion que dibujar
    jne     buscarLetra
    ret 
    
;------------------------------------------
; int dibujarLinea(coordenates values)
; bit drawing function

 dibujarLinea:
 
    mov     [X0], al
    mov     [Y0], bl
    mov     [Xf], cl
    mov     [Yf], dl
 
    push    edx ;se tira Yf para arriba
    mov     edx, ecx
    sub     edx, eax ;Xf - X0, este es el deltaX
    mov     [deltaX], edx
    pop     edx ;se devuelve a Yf
    
    push    ecx ;se tira Xf para arriba
    mov     ecx, edx
    sub     ecx, ebx; Yf - Y0, este es el deltaY
    mov     [deltaY], ecx
    pop     ecx ;se devuelve a Xf
    
    push    eax ;se tira X0 para arriba
    push    ebx ;se tira Y0 para arriba
    push    edx ;se tira Xf para arriba
    
    mov     al, [deltaX]
    mov     ebx, [deltaY]
    add     ebx, ebx ; 2*deltaY
    sub     ebx, eax ;se termina de calcular el valor de decision Pk. Pk = 2*deltaY - deltaX
    mov     edx, Pk
    mov     [edx], ebx ;se guarda el valor de Pk
    
    pop     eax ;se devuelve a X0
    pop     ebx ;se devuelve a Y0
    pop     edx ;se devuelve a Xf
    
    mov     bl, [Y0]
    mov     cl, [Xf]
    mov     dl, [Yf]
    mov     al, [X0]
    
    cmp     eax, ecx ;para saber si es vertical
    je      lineaSinPendiente
    
    cmp     ebx, edx ;para saber si es horizontal
    je      lineaSinPendiente
    
    jmp     lineaConPendiente
    
    ret
    
dibujarPixel:
    
    mov     [X0], al
    mov     [Y0], bl
    mov     [Xf], cl
    mov     [Yf], dl
    
    mov     al, [fila_j]
    add     eax, ebx ;para ver cuantas filas se tira para abajo
    mov     edx, 250
    mul     edx ;multiplica eax por edx y lo guarda en eax
    
    mov     ebx, eax
      
    mov     cl, [columna_i]
    mov     eax, 0
    mov     al, [X0]
    add     ecx, eax
    add     ecx, ebx ;ecx va a tener la posicion de memoria en la que se va a pintar el pixel
    
    mov     ebx, 1
    
    mov     eax, pixeles
    add     eax, ecx    ;Ahora eax posee la direccion de memoria donde se va a guardar la informacion del pixel
    
    mov     [eax], ebx ;se guarda el valor 1 en la direccion de memoria calculada
    
    mov     eax, 0
    mov     ebx, 0
    mov     ecx, 0
    mov     edx, 0
    
    mov     bl, [Y0]
    mov     cl, [Xf]
    mov     dl, [Yf]
    mov     al, [X0]
    
    ret

lineaSinPendiente:
    
    jmp     while_horizontal_vertical
    
while_horizontal_vertical:

    call    dibujarPixel
    
    mov     eax, [Pk]

    cmp     eax, 0
    jg      PkMayorQue0_horizontal_vertical
    
    cmp     eax, 0
    jl      PkMenorQue0_horizontal_vertical
    
PkMayorQue0_horizontal_vertical:
    
    mov     eax, [Pk]
    mov     bl, byte[deltaX]
    add     bl, bl ; 2*deltaX
    mov     cl, [deltaY]
    add     ecx, ecx ; 2*deltaY
    
    mov     edx, eax ; se guarda Pk en edx
    add     edx, ecx ; Pk + 2*deltaY
    sub     edx, ebx ; se obtiene el nuevo valor de Pk con el Pk_1. Pk + 2*deltaY - 2*deltaX
    
    mov     [Pk], dl ; se actualiza el valor de Pk
    
    mov     al, [X0]
    mov     bl, [Y0]
    mov     cl, [Xf]
    mov     dl, [Yf]
  
    add     ebx, 1 ;Se le suma una unidad a Y0
    
    cmp     eax, ecx
    jne     while_horizontal_vertical
    
    cmp     ebx, edx
    jne     while_horizontal_vertical
    
    call    dibujarPixel ;dibuja el ultimo pixel fuera del while
    
    ret     ;retorna a dibujar la siguiente linea

PkMenorQue0_horizontal_vertical:
    
    mov     eax, [Pk]
    mov     ebx, 0
    mov     bl, [deltaX]
    add     bl, bl ; 2*deltaX
    
    mov     ecx, 0
    mov     cl, [deltaY]
    add     cl, cl ; 2*deltaY
    
    mov     edx, eax ; se guarda Pk en edx
    add     edx, ecx ; se obtiene el nuevo valor de Pk con el Pk_1. Pk + 2*deltaY
    
    mov     [Pk], edx ; se actualiza el valor de Pk
    
    mov     ecx, 0
    mov     eax, 0
    mov     ebx, 0
    mov     edx, 0
    
    mov     al, [X0]
    mov     bl, [Y0]
    mov     cl, [Xf]
    mov     dl, [Yf]
    
    add     eax, 1 ;Se le suma una unidad a X0
    
    cmp     eax, ecx
    jne     while_horizontal_vertical
    
    cmp     ebx, edx
    jne     while_horizontal_vertical
    
    call    dibujarPixel ;dibuja el ultimo pixel fuera del while
    
    ret     ;retorna a dibujar la siguiente linea

lineaConPendiente:
    
    mov     eax, 0
    mov     ebx, 0
    mov     ecx, 0
    
    mov     bl, [deltaY]
    cmp     bl, 0
    jl      pendienteNegativa
    
    mov     ebx, 0
    mov     eax, 0
    
    mov     al, [deltaY]
    mov     bl, [deltaX]
    div     bl ;divide eax entre src que es ebx y lo guarda en eax
    
    cmp     eax, 0
    jg      pendientePositiva
    cmp     eax, 0
    jl      pendienteNegativa

pendientePositiva:
    mov     eax, 0
    mov     al, [X0]
    mov     bl, [Y0]
    mov     cl, [Xf]
    mov     dl, [Yf]

    jmp while_pendientePositiva

while_pendientePositiva:

    mov     ecx, 0

    mov     al, [X0]
    mov     bl, [Y0]
    mov     cl, [Xf]
    mov     dl, [Yf]

    call    dibujarPixel
    
    mov     eax, 0
    mov     eax, [Pk]

    cmp     eax, 0
    jge     PkMayorQue0_pendientePositiva
    
    cmp     eax, 0
    jl      PkMenorQue0_pendientePositiva

PkMayorQue0_pendientePositiva:

    mov     eax, [Pk]
    mov     ebx, 0
    mov     bl, [deltaX]
    add     bl, bl ; 2*deltaX
    
    mov     ecx, 0
    mov     cl, [deltaY]
    add     cl, cl ; 2*deltaY
    
    mov     edx, eax ; se guarda Pk en edx
    add     edx, ecx ; Pk + 2*deltaY
    sub     edx, ebx ;se obtiene el nuevo valor de Pk con el Pk_1. Pk + 2*deltaY - 2*deltaX
    
    mov     [Pk], edx ;se acutializa el valor de Pk
    
    mov     edx,0
    
    mov     al, [X0]
    mov     bl, [Y0]
    mov     cl, [Xf]
    mov     dl, [Yf]
    
    add     eax, 1 ;Se le suma una unidad a X0
    add     ebx, 1 ;Se le suma una unidad a Y0
    
    mov     [X0], al
    mov     [Y0], bl
    mov     [Xf], cl
    mov     [Yf], dl
    
    call    validarIguales
    
    cmp     eax, 1
    je      while_pendientePositiva ;deberia quedarse en el while porque los dos casos se cumplen
    mov     eax, 0
    mov     al, [X0]
    
    call    dibujarPixel ;dibuja el ultimo pixel fuera del while
    ret

PkMenorQue0_pendientePositiva:

    mov     eax, [Pk]
    
    mov     ecx, 0
    mov     cl, [deltaY]
    add     cl, cl ; 2*deltaY
    
    mov     edx, eax ; se guarda Pk en edx
    add     edx, ecx ; Pk + 2*deltaY
   
    mov     [Pk], edx ;se acutializa el valor de Pk
    
    mov     edx, 0
    mov     eax, 0
    
    mov     al, [X0]
    mov     bl, [Y0]
    mov     cl, [Xf]
    mov     dl, [Yf]
    
    add     eax, 1 ;Se le suma una unidad a X0
    
    mov     [X0], al
    mov     [Y0], bl
    mov     [Xf], cl
    mov     [Yf], dl
    
    call    validarIguales
    
    cmp     eax, 1
    je      while_pendientePositiva ;deberia quedarse en el while porque los dos casos se cumplen
    mov     eax, 0
    mov     al, [X0]
    
    call    dibujarPixel ;dibuja el ultimo pixel fuera del while
    ret
    
pendienteNegativa:

    mov     al, [X0]
    mov     bl, [Y0]
    mov     cl, [Xf]
    mov     dl, [Yf]

    jmp     while_pendienteNegativa

while_pendienteNegativa:

    mov     ecx, 0

    mov     al, [X0]
    mov     bl, [Y0]
    mov     cl, [Xf]
    mov     dl, [Yf]

    call    dibujarPixel
    
    mov     eax, 0
    mov     eax, [Pk]

    cmp     eax, 0
    jge     PkMayorQue0_pendienteNegativa
    
    cmp     eax, 0
    jl      PkMenorQue0_pendienteNegativa


PkMayorQue0_pendienteNegativa:

    mov     eax, [Pk]
    mov     ebx, 0
    mov     bl, [deltaX]
    add     bl, bl ; 2*deltaX
    
    mov     ecx, 0
    mov     ecx, [deltaY]
    add     ecx, ecx ; 2*deltaY
    
    mov     edx, eax ; se guarda Pk en edx
    add     edx, ebx ; Pk + 2*deltaX
    sub     edx, ecx ;se obtiene el nuevo valor de Pk con el Pk_1. Pk + 2*deltaX - 2*deltaY
    
    mov     [Pk], edx ;se acutializa el valor de Pk
    
    mov     ecx, 0
    
    mov     al, [X0]
    mov     bl, [Y0]
    mov     cl, [Xf]
    mov     dl, [Yf]
    
    add     eax, 1 ;Se le suma una unidad a X0
    sub     ebx, 1 ;Se le suma una unidad a Y0
    
    mov     [X0], al
    mov     [Y0], bl
    mov     [Xf], cl
    mov     [Yf], dl
    
    call    validarIguales
    
    cmp     eax, 1
    je      while_pendienteNegativa ;deberia quedarse en el while porque los dos casos se cumplen
    mov     eax, 0
    mov     al, [X0]
    
    call    dibujarPixel ;dibuja el ultimo pixel fuera del while
    ret

PkMenorQue0_pendienteNegativa:

    mov     eax, [Pk]
    mov     ebx, 0
    mov     bl, [deltaX]
    add     bl, bl ; 2*deltaX
    
    mov     ecx, 0
    mov     ecx, [deltaY]
    add     ecx, ecx ; 2*deltaY
    
    mov     edx, eax ; se guarda Pk en edx
    add     edx, ebx ; Pk + 2*deltaX

    mov     [Pk], edx ;se acutializa el valor de Pk
    
    mov     ecx, 0
    
    mov     al, [X0]
    mov     bl, [Y0]
    mov     cl, [Xf]
    mov     dl, [Yf]
    
    add     eax, 1 ;Se le suma una unidad a X0
    
    mov     [X0], al
    mov     [Y0], bl
    mov     [Xf], cl
    mov     [Yf], dl
    
    call    validarIguales
    
    cmp     eax, 1
    je      while_pendienteNegativa ;deberia quedarse en el while porque los dos casos se cumplen
    mov     eax, 0
    mov     al, [X0]
    
    call    dibujarPixel ;dibuja el ultimo pixel fuera del while
    ret

validarIguales:
    cmp     eax, ecx
    jne     validarIguales2
    ret ;si entra aqui es que son iguales y deberia salir del while
    
validarIguales2:
    cmp     ebx, edx
    jne     retornarVal
    ret ;si entra aqui es que son iguales y deberia salir del while
    
funcionFinal:
    ;Se crea el archivo
    mov     eax, 0
    mov     ebx, 0
    mov     ecx, 0
    mov     edx, 0
    
    mov     ecx, 0777o          
    mov     ebx, outputTXT
    mov     eax, 8
    int     80h
 
    mov     edx, 62500             ; Numero de bytes que quiero escribir, uno para cada valor de pixel
    mov     ecx, pixeles
    mov     ebx, eax
    mov     eax, 4
    int     80h
    
    jmp    quit

retornar:
    push    eax
    mov     eax, 0 ;significa que debe seguir con el while porque los dos casos se cumplen
    ret
    
retornarVal:
    push    eax
    mov     eax, 1 ;significa que todavia hay texto
    pop     ecx
    pop     ecx
    jmp     ecx

;------------------------------------------
; int slen(String message)
; String length calculation function
slen:
    push    ebx
    mov     ebx, eax
 
nextchar:
    cmp     byte [eax], 0
    jz      finished
    inc     eax
    jmp     nextchar
 
finished:
    sub     eax, ebx
    pop     ebx
    ret
 
 
;------------------------------------------
; void sprint(String message)
; String printing function
sprint:
    push    edx
    push    ecx
    push    ebx
    push    eax
    call    slen
 
    mov     edx, eax
    pop     eax
 
    mov     ecx, eax
    mov     ebx, 1
    mov     eax, 4
    int     80h
 
    pop     ebx
    pop     ecx
    pop     edx
    ret
 
 
;------------------------------------------
; void sprintLF(String message)
; String printing with line feed function
sprintLF:
    call    sprint
 
    push    eax         ; push eax onto the stack to preserve it while we use the eax register in this function
    mov     eax, 0Ah    ; move 0Ah into eax - 0Ah is the ascii character for a linefeed
    push    eax         ; push the linefeed onto the stack so we can get the address
    mov     eax, esp    ; move the address of the current stack pointer into eax for sprint
    call    sprint      ; call our sprint function
    pop     eax         ; remove our linefeed character from the stack
    pop     eax         ; restore the original value of eax before our function was called
    ret                 ; return to our program
 
 
;------------------------------------------
; void exit()
; Exit program and restore resources
quit:
    mov     ebx, 0
    mov     eax, 1
    int     80h
    
;------------------------------------------
; int cases(letter value)
; choose which case to draw
cases:
    cmp     ebx, 0x0
    je      retornar
    cmp     ebx, 0x20
    je      retornarVal
    cmp     ebx, 0x41
    je      case_A
    cmp     ebx, 0x42
    je      case_B
    cmp     ebx, 0x43
    je      case_C
    cmp     ebx, 0x44
    je      case_D
    cmp     ebx, 0x45
    je      case_E
    cmp     ebx, 0x46
    je      case_F
    cmp     ebx, 0x47
    je      case_G
    cmp     ebx, 0x48
    je      case_H
    cmp     ebx, 0x49
    je      case_I
    cmp     ebx, 0x4a
    je      case_J
    cmp     ebx, 0x4b
    je      case_K
    cmp     ebx, 0x4c
    je      case_L
    cmp     ebx, 0x4d
    je      case_M
    cmp     ebx, 0x4e
    je      case_N
    cmp     ebx, 0x4f
    je      case_O
    cmp     ebx, 0x50
    je      case_P
    cmp     ebx, 0x51
    je      case_Q
    cmp     ebx, 0x52
    je      case_R
    cmp     ebx, 0x53
    je      case_S
    cmp     ebx, 0x54
    je      case_T
    cmp     ebx, 0x55
    je      case_U
    cmp     ebx, 0x56
    je      case_V
    cmp     ebx, 0x57
    je      case_W
    cmp     ebx, 0x58
    je      case_X
    cmp     ebx, 0x59
    je      case_Y
    cmp     ebx, 0x5a
    je      case_Z
    cmp     ebx, 0x2e
    je      case_punto
    cmp     ebx, 0x2c
    je      case_coma
    cmp     ebx, 0x2d
    je      case_firma
    ret
    
case_A: ;case A with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, 5
    mov     edx, eax
    call    dibujarLinea
    
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea
    
    mov     eax, 5
    mov     ebx, 1
    mov     ecx, eax
    mov     edx, eax
    call    dibujarLinea
    
    mov     eax, 1
    mov     ebx, 4
    mov     ecx, 5
    mov     edx, ebx
    call    dibujarLinea
    ret
    
case_B: ;case B with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, 4
    mov     edx, eax
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;segunda linea
    
    mov     eax, 1
    mov     ebx, 3
    mov     ecx, 5
    mov     edx, ebx
    call    dibujarLinea ;tercera linea
    
    mov     eax, 1
    mov     ebx, 5
    mov     ecx, ebx
    mov     edx, ebx
    call    dibujarLinea ;cuarta linea
    
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, eax
    mov     edx, 3
    call    dibujarLinea ;quinta linea
    
    mov     eax, 5
    mov     ebx, 3
    mov     ecx, eax
    mov     edx, eax
    call    dibujarLinea ;sexta linea
    
    ret
    
case_C: ;case C with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, 5
    mov     edx, eax
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;segunda linea
    
    mov     eax, 1
    mov     ebx, 5
    mov     ecx, ebx
    mov     edx, ebx
    call    dibujarLinea ;tercera linea
    ret
    
case_D: ;case D with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, 4
    mov     edx, eax
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;segunda linea
    
    mov     eax, 1
    mov     ebx, 5
    mov     ecx, 4
    mov     edx, ebx
    call    dibujarLinea ;tercera linea
    
    mov     eax, 5
    mov     ebx, 2
    mov     ecx, eax
    mov     edx, 4
    call    dibujarLinea ;cuarta linea
    ret
    
case_E: ;case E with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, 5
    mov     edx, eax
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;segunda linea
    
    mov     eax, 1
    mov     ebx, 5
    mov     ecx, ebx
    mov     edx, ebx
    call    dibujarLinea ;tercera linea
    
    mov     eax, 1
    mov     ebx, 3
    mov     ecx, 4
    mov     edx, ebx
    call    dibujarLinea ;cuarta linea
    ret
    
case_F: ;case F with its coordenates for each line
    
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, 5
    mov     edx, eax
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;segunda linea
    
    mov     eax, 1
    mov     ebx, 3
    mov     ecx, 4
    mov     edx, ebx
    call    dibujarLinea ;tercera linea
    ret
    
case_G: ;case G with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, 5
    mov     edx, eax
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;segunda linea
    
    mov     eax, 1
    mov     ebx, 5
    mov     ecx, ebx
    mov     edx, ebx
    call    dibujarLinea ;tercera linea
    
    mov     eax, 5
    mov     ebx, 3
    mov     ecx, eax
    mov     edx, eax
    call    dibujarLinea ;cuarta linea
    
    mov     eax, 3
    mov     ebx, eax
    mov     ecx, 5
    mov     edx, eax
    call    dibujarLinea ;quinta linea
    ret
    
case_H: ;case H with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, eax
    mov     edx, 5
    
    call    dibujarLinea ;primera linea
    
    mov     eax, 5
    mov     ebx, 1
    mov     ecx, eax
    mov     edx, eax
    call    dibujarLinea ;segunda linea
    
    mov     eax, 1
    mov     ebx, 3
    mov     ecx, 5
    mov     edx, ebx
    call    dibujarLinea ;tercera linea
    ret
    
case_I: ;case I with its coordenates for each line 
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, 5
    mov     edx, eax
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, 5
    mov     ecx, ebx
    mov     edx, ebx
    call    dibujarLinea ;segunda linea
    
    mov     eax, 3
    mov     ebx, 1
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;tercera linea
    ret
    
case_J: ;case J with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, 5
    mov     edx, eax
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, 5
    mov     ecx, 3
    mov     edx, ebx
    call    dibujarLinea ;segunda linea
    
    mov     eax, 3
    mov     ebx, 1
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;tercera linea
    ret
    
case_K: ;case K with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, 3
    mov     ecx, 5
    mov     edx, eax
    call    dibujarLinea ;segunda linea
    
    mov     eax, 1
    mov     ebx, 3
    mov     ecx, 5
    mov     edx, ecx
    call    dibujarLinea ;tercera linea
    ret
    
case_L: ;case L with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, 5
    mov     ecx, ebx
    mov     edx, ebx
    call    dibujarLinea ;segunda linea
    ret
    
case_M: ;case M with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, 5
    mov     edx, eax
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;segunda linea
    
    mov     eax, 3
    mov     ebx, 1
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;tercera linea
    
    mov     eax, 5
    mov     ebx, 1
    mov     ecx, eax
    mov     edx, eax
    call    dibujarLinea ;cuarta linea
    ret
    
case_N: ;case N with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;primera linea
    
    mov     eax, 5
    mov     ebx, 1
    mov     ecx, eax
    mov     edx, eax
    call    dibujarLinea ;segunda linea
    
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, 5
    mov     edx, ecx
    call    dibujarLinea ;tercera linea
    ret
    
case_O: ;case O with its coordenates for each line
    mov     eax, 2
    mov     ebx, 1
    mov     ecx, 4
    mov     edx, ebx
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;segunda linea
    
    mov     eax, 5
    mov     ebx, 1
    mov     ecx, eax
    mov     edx, eax
    call    dibujarLinea ;tercera linea
    
    mov     eax, 1
    mov     ebx, 5
    mov     ecx, ebx
    mov     edx, ebx
    call    dibujarLinea ;cuarta linea
    ret
    
case_P: ;case P with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, 5
    mov     edx, eax
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;segunda linea
    
    mov     eax, 1
    mov     ebx, 3
    mov     ecx, 4
    mov     edx, ebx
    call    dibujarLinea ;tercera linea
    
    mov     eax, 5
    mov     ebx, 1
    mov     ecx, eax
    mov     edx, 3
    call    dibujarLinea ;cuarta linea
    ret

case_Q: ;case Q with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, 5
    mov     edx, eax
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;segunda linea
    
    mov     eax, 1
    mov     ebx, 5
    mov     ecx, 3
    mov     edx, ebx
    call    dibujarLinea ;tercera linea
    
    mov     eax, 5
    mov     ebx, 1
    mov     ecx, eax
    mov     edx, 3
    call    dibujarLinea ;cuarta linea
    
    mov     eax, 3
    mov     ebx, eax
    mov     ecx, 5
    mov     edx, ecx
    call    dibujarLinea ;quinta linea
    ret

case_R: ;case R with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, 5
    mov     edx, eax
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;segunda linea
    
    mov     eax, 1
    mov     ebx, 3
    mov     ecx, 4
    mov     edx, ebx
    call    dibujarLinea ;tercera linea
    
    mov     eax, 5
    mov     ebx, 1
    mov     ecx, eax
    mov     edx, 3
    call    dibujarLinea ;cuarta linea
    
    mov     eax, 3
    mov     ebx, eax
    mov     ecx, 5
    mov     edx, ecx
    call    dibujarLinea ;quinta linea
    ret
    
case_S: ;case S with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, 5
    mov     edx, eax
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, 3
    mov     ecx, 5
    mov     edx, ebx
    call    dibujarLinea ;segunda linea
    
    mov     eax, 1
    mov     ebx, 5
    mov     ecx, ebx
    mov     edx, ebx
    call    dibujarLinea ;tercera linea
    
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, eax
    mov     edx, 3
    call    dibujarLinea ;cuarta linea
    
    mov     eax, 5
    mov     ebx, 3
    mov     ecx, eax
    mov     edx, eax
    call    dibujarLinea ;quinta linea
    ret
    
case_T: ;case T with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, 5
    mov     edx, eax
    call    dibujarLinea ;primera linea
    
    mov     eax, 3
    mov     ebx, 1
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;segunda linea
    ret

case_U: ;case U with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;primera linea
    
    mov     eax, 5
    mov     ebx, 1
    mov     ecx, eax
    mov     edx, eax
    call    dibujarLinea ;segunda linea
    
    mov     eax, 1
    mov     ebx, 5
    mov     ecx, ebx
    mov     edx, ebx
    call    dibujarLinea ;tercera linea
    ret
    
case_V: ;case V with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, 3
    mov     edx, 5
    call    dibujarLinea ;primera linea
    
    mov     eax, 3
    mov     ebx, 5
    mov     ecx, ebx
    mov     edx, 1
    call    dibujarLinea ;segunda linea
    ret
    
case_W: ;case W with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;primera linea
    
    mov     eax, 5
    mov     ebx, 1
    mov     ecx, eax
    mov     edx, eax
    call    dibujarLinea ;segunda linea
    
    mov     eax, 1
    mov     ebx, 5
    mov     ecx, ebx
    mov     edx, ebx
    call    dibujarLinea ;tercera linea
    
    mov     eax, 3
    mov     ebx, 1
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;cuarta linea
    ret
    
case_X: ;case X with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, 5
    mov     edx, ecx
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, 5
    mov     ecx, ebx
    mov     edx, eax
    call    dibujarLinea ;segunda linea
    ret

case_Y: ;case Y with its coordenates for each line 
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, 3
    mov     edx, ecx
    call    dibujarLinea ;primera linea
    
    mov     eax, 3
    mov     ebx, eax
    mov     ecx, 5
    mov     edx, 1
    call    dibujarLinea ;segunda linea
    
    mov     eax, 3
    mov     ebx, eax
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;tercera linea
    ret
    
case_Z: ;case Z with its coordenates for each line
    mov     eax, 1
    mov     ebx, eax
    mov     ecx, 5
    mov     edx, eax
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, 5
    mov     ecx, ebx
    mov     edx, eax
    call    dibujarLinea ;segunda linea
    
    mov     eax, 1
    mov     ebx, 5
    mov     ecx, ebx
    mov     edx, ebx
    call    dibujarLinea ;tercera linea
    ret
    
case_punto:
    mov     eax, 1
    mov     ebx, 4
    mov     ecx, 2
    mov     edx, ebx
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, 5
    mov     ecx, 2
    mov     edx, ebx
    call    dibujarLinea ;segunda linea
    ret
    
case_coma:
    mov     eax, 1
    mov     ebx, 4
    mov     ecx, eax
    mov     edx, 5
    call    dibujarLinea ;primera linea
    ret
    
case_firma:

    mov     eax, 1
    mov     ebx, 5
    mov     ecx, 5
    mov     edx, 1
    call    dibujarLinea ;primera linea
    
    mov     eax, 5
    mov     ebx, 1
    mov     ecx, 10
    mov     edx, 1
    call    dibujarLinea ;primera linea
    
    mov     eax, 10
    mov     ebx, 1
    mov     ecx, 15
    mov     edx, 5
    call    dibujarLinea ;primera linea
    
    mov     eax, 15
    mov     ebx, 5
    mov     ecx, 15
    mov     edx, 10
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, 5
    mov     ecx, 1
    mov     edx, 10
    call    dibujarLinea ;primera linea
    
    mov     eax, 1
    mov     ebx, 10
    mov     ecx, 5
    mov     edx, 15
    call    dibujarLinea ;primera linea
    
    mov     eax, 5
    mov     ebx, 15
    mov     ecx, 10
    mov     edx, 15
    call    dibujarLinea ;primera linea
    
    mov     eax, 10
    mov     ebx, 15
    mov     ecx, 15
    mov     edx, 10
    call    dibujarLinea ;primera linea
    
    mov     eax, 5
    mov     ebx, 15
    mov     ecx, 10
    mov     edx, 1
    call    dibujarLinea ;primera linea
    
    mov     eax, 5
    mov     ebx, 1
    mov     ecx, 10
    mov     edx, 15
    call    dibujarLinea ;primera linea
    
    mov     eax, 10
    mov     ebx, 15
    mov     ecx, 20
    mov     edx, 20
    call    dibujarLinea ;primera linea
    
    mov     eax, 15
    mov     ebx, 10
    mov     ecx, 20
    mov     edx, 20
    call    dibujarLinea ;primera linea
    ret

    

