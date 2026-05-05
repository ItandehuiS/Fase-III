%% SCRIPT 1: Uso de la función rgb2gray
% Utilizada para convertir imágenes a color (RGB) a escala de grises. 
clc;
clear all;
close all;

% Configuración de rutas de entrada y salida
rutaIn = 'D:\Posgrado Segundo MR-2\PDI\Nueva carpeta (2)\ForesFireDataset(ObjectDetection)\valid\images\Alto';
rutaOut = fullfile(rutaIn, 'Resultados_Herramienta');
if ~exist(rutaOut, 'dir'), mkdir(rutaOut); end

% Obtención de la estructura de archivos del dataset
lista = dir(fullfile(rutaIn, '*.jpg'));

fprintf('Iniciando procesamiento con rgb2gray (Standard BT.601)...\n');

for k = 1:length(lista)
    % Lectura de la función de intensidad original f(x,y,RGB)
    img = imread(fullfile(rutaIn, lista(k).name));
    
    % Aplicación de la herramienta de software (Procesamiento de caja negra)
    % rgb2gray es una función optimizada del Image Processing Toolbox.
    imgGris = rgb2gray(img); 
    
    % Almacenamiento del resultado para comparación analítica
    imwrite(imgGris, fullfile(rutaOut, lista(k).name));
end
fprintf('Completado. Resultados en: %s\n', rutaOut);