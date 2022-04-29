import numpy as np

pixeles = np.zeros((20, 20))

contadorLetra = 0

dirInicial= 0

def algoritmoBresenham (letra):
    if letra == "A":
        algoritmoB_A()

    elif letra == "B":
        algoritmoB_B()

    elif letra == "H":
        algoritmoB_H()
        
    elif letra == "K":
        algoritmoB_K()
        
    else:
        return

def algoritmoB_A():
    
    X0 = 1
    Y0 = 1
    Xf = 5
    Yf = 1
    dibujarLinea(X0, Y0, Xf, Yf) # Primera linea

    X0 = 1
    Y0 = 1
    Xf = 1
    Yf = 5
    dibujarLinea(X0, Y0, Xf, Yf) # Segunda linea

    X0 = 5
    Y0 = 1
    Xf = 5
    dibujarLinea(X0, Y0, Xf, Yf) # Tercera linea

    X0 = 1
    Y0 = 4
    Yf = 4
    dibujarLinea(X0, Y0, Xf, Yf) # Primera linea

def algoritmoB_H():
    
    X0 = 1
    Y0 = 1
    Xf = 1
    Yf = 5
    dibujarLinea(X0, Y0, Xf, Yf) # Primera linea

    X0 = 5
    Y0 = 1
    Xf = 5
    Yf = 5
    dibujarLinea(X0, Y0, Xf, Yf) # Segunda linea

    X0 = 1
    Y0 = 3
    Xf = 5
    Yf = 3
    dibujarLinea(X0, Y0, Xf, Yf) # Tercera linea

def algoritmoB_B():
    
    X0 = 1
    Y0 = 1
    Xf = 4
    Yf = 1
    dibujarLinea(X0, Y0, Xf, Yf) # Primera linea

    X0 = 1
    Y0 = 1
    Xf = 1
    Yf = 5
    dibujarLinea(X0, Y0, Xf, Yf) # Segunda linea

    X0 = 1
    Y0 = 3
    Xf = 5
    Yf = 3
    dibujarLinea(X0, Y0, Xf, Yf) # Tercera linea

    X0 = 1
    Y0 = 5
    Xf = 5
    Yf = 5
    dibujarLinea(X0, Y0, Xf, Yf) # Cuarta linea

    X0 = 4
    Y0 = 1
    Xf = 4
    Yf = 3
    dibujarLinea(X0, Y0, Xf, Yf) # Quinta linea

    X0 = 5
    Y0 = 3
    Xf = 5
    Yf = 5
    dibujarLinea(X0, Y0, Xf, Yf) # Sexta linea

def algoritmoB_K():
    X0 = 1
    Y0 = 1
    Xf = 1
    Yf = 5
    dibujarLinea(X0, Y0, Xf, Yf) # Primera linea

    X0 = 1
    Y0 = 3
    Xf = 5
    Yf = 1
    dibujarLinea(X0, Y0, Xf, Yf) # Primera linea

    X0 = 1
    Y0 = 3
    Xf = 5
    Yf = 5
    dibujarLinea(X0, Y0, Xf, Yf) # Primera linea
    

def dibujarLinea(X0, Y0, Xf, Yf):

    global contadorLetra
    
    deltaX = Xf - X0
    deltaY = Yf - Y0

    Xk_1 = X0
    Yk_1 = Y0

    Pk = 2 * deltaY - deltaX
    Pk_1 = 0
    

    if (X0 == Xf or Y0 == Yf):

        while (Xk_1 != Xf or Yk_1 != Yf):
            print (Pk)
            
            pixeles[Yk_1][Xk_1+contadorLetra] = 1 # Rellenar el pixel con un 1

            if (Pk > 0):
                Pk_1 = Pk + 2*deltaY - 2*deltaX

                Xk_1 = Xk_1
                Yk_1 = Yk_1 + 1

                Pk = Pk_1

            elif (Pk < 0):

                Pk_1 = Pk + 2*deltaY

                Xk_1 = Xk_1 + 1 # Yk_1 queda igual

                Pk = Pk_1

            else:
                return

    else:
        
        m = (Yf-Y0) / (Xf-X0)

        if (m > 0):

            print ("pendiente positiva")
            

            while (Xk_1 != Xf and Yk_1 != Yf):
                print (Pk)

                pixeles[Yk_1][Xk_1+contadorLetra] = 1 # Rellenar el pixel con un 1

                if (Pk >= 0):
                    
                    Pk_1 = Pk + 2*deltaY - 2*deltaX

                    Xk_1 = Xk_1 + 1
                    Yk_1 = Yk_1 + 1

                    Pk = Pk_1

                elif (Pk < 0):

                    Pk_1 = Pk + 2*deltaY

                    Xk_1 = Xk_1 + 1 # Yk_1 queda igual

                    Pk = Pk_1

                else:
                    return
            
        else:

            print ("pendiente negativa")

            while (Xk_1 != Xf and Yk_1 != Yf):
                print (Pk)
                #print (deltaY)

                pixeles[Yk_1][Xk_1+contadorLetra] = 1 # Rellenar el pixel con un 1

                if (Pk >= 0):
                    
                    Pk_1 = Pk + 2*deltaX - 2*deltaY

                    Xk_1 = Xk_1 + 1
                    Yk_1 = Yk_1 - 1
                    
                    Pk = Pk_1

                elif (Pk < 0):

                    Pk_1 = Pk + 2*deltaX

                    Xk_1 = Xk_1 + 1 # Yk_1 queda igual

                    Pk = Pk_1

                else:
                    
                    return
                
            pixeles[Yk_1][Xk_1+contadorLetra] = 1

    pixeles[Yk_1][Xk_1+contadorLetra] = 1 # Rellenar el pixel con un 1


    printMatrix (pixeles)

    return

def printMatrix (matrix):
    
    printedMatrix = np.array(matrix)
    print (printedMatrix)

#printMatrix(pixeles)

algoritmoBresenham ("K")

#contadorLetra += 6

#algoritmoBresenham ("K")
    

        
        
        
    
    
    
    

