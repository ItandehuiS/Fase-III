close all;
clear;
clc;

%% Carpeta con imágenes
imageFolder = 'D:\Posgrado Segundo MR-2\PDI\Nueva carpeta (2)\ForesFireDataset(ObjectDetection)\valid\images\Moderado\Resultados_Herramienta';
imageFiles = dir(fullfile(imageFolder, '*.jpg'));

%% Parámetros CLAHE
clipLimit = 0.01;     % recorte de histograma (0-1), 0.01 es bastante contrastado
tileGridSize = [8 8]; % dividir imagen en 8x8 bloques

%% Recorrer todas las imágenes
for k = 1:numel(imageFiles)
    
    % Leer imagen
    im1 = imread(fullfile(imageFolder, imageFiles(k).name));
    
    % Convertir a gris si es RGB
    if size(im1,3) == 3
        im1 = rgb2gray(im1);
    end
    
    figure; imshow(im1); title(['Imagen Original: ', imageFiles(k).name]);
    
    % ===== Aplicar CLAHE =====
    imagen_final = adapthisteq(im1, ...
        'ClipLimit', clipLimit, ...
        'NumTiles', tileGridSize, ...
        'Distribution', 'uniform'); % distribución uniforme
    
    % ===== Mostrar histogramas antes y después =====
    figure
    subplot(2,1,1)
    imhist(im1);
    title(['Histograma Original: ', imageFiles(k).name])
    xlabel('Nivel de gris'); ylabel('Frecuencia')
    
    subplot(2,1,2)
    imhist(imagen_final);
    title('Histograma con CLAHE')
    xlabel('Nivel de gris'); ylabel('Frecuencia')
    
    % ===== Mostrar imagen final =====
    figure
    imshow(imagen_final)
    title(['Imagen con CLAHE: ', imageFiles(k).name])
    
end