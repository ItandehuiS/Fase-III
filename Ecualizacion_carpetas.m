%%Ecualizaci´on 
close all;
clear;
clc;
imageFolder = 'D:\Posgrado Segundo MR-2\PDI\Nueva carpeta (2)\ForesFireDataset(ObjectDetection)\valid\images\Sin_incendio\Resultados_Herramienta sin incendio'; % cambia a la carpeta donde están tus imágenes
imageFiles = dir(fullfile(imageFolder, '*.jpg')); % todas las imágenes BMP
L = 256;
for k = 1:numel(imageFiles)
    
    % Leer imagen
    imgPath = fullfile(imageFolder, imageFiles(k).name);
    img = imread(imgPath);
    
    % Aplicar función de ecualización
    [imagN, hisN] = EcualizacionF(img, L);
    
   
    
    % Mostrar progreso
    fprintf('Procesada imagen %d/%d: \n', k, numel(imageFiles));
    
end