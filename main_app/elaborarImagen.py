from matplotlib import pyplot as plt
import numpy as np
import cv2 as cv
import struct

finalMatrix = 0

def recieveMatrix():

    listaPixeles = fileToValue()

    arrayPixeles = np.array(listaPixeles)
    matrixPixeles = np.reshape(arrayPixeles, (250, 250))

    global finalMatrix

    finalMatrix = np.where((matrixPixeles == 0) | (matrixPixeles == 1), matrixPixeles^1, matrixPixeles)
    finalMatrix *= 255
    #print (finalMatrix)

    crearImagen()

def printMatrix (matrix):
    
    printedMatrix = np.array(matrix)
    print (printedMatrix)

def fileToValue():
    
    file_data = open('output.txt', 'rb').read()

    finalData = struct.unpack('62500b',file_data)
    finalList = list(finalData)

    return finalList

def crearImagen():
    result = np.array(finalMatrix ,dtype=np.uint8)
    cv.imwrite('prueba.png', result)

#recieveMatrix()

#fileToValue()

#HOLA MUNDO AB C D E F G H I J K L M N O P Q R S T U V W X Y Z 

        
        
        
    
    
    
    

