from elaborarImagen import *
import PySimpleGUI as sg
import os

sg.theme('BlueMono')

# Manejo primario de como van a estar ubicados los componentes dentro de la ventana. Son solo botones y labels
distribucion = [  [sg.Text('Elaboración de Arhivo e Imagen')],
               [sg.Text('Generar archivo output.txt desde Ensamblador x86'), sg.Button('Generar txt')  ],
               [sg.Text('Generar imagen basada en output.txt desde Python'), sg.Button('Generar imagen') ]]

#Creacion de la ventana con nombre
window = sg.Window('Bresenham y Modificaciones', distribucion)

while True:
    #Se encarga de leer los inputs de la ventana
    event, values = window.read()
    if event == sg.WIN_CLOSED: # Si se cierra la ventana se sale del ciclo y se termina el while
        break
    if event == 'Generar txt':
        os.system('./procesamiento')
    if event == 'Generar imagen':
        recieveMatrix()

window.close()

        
        
        
    
    
    
    

