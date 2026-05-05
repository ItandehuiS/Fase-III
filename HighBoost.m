close all;
clear;
clc;

%% Carpeta con imágenes
inputFolder = 'D:\Posgrado Segundo MR-2\PDI\Nueva carpeta (2)\ForesFireDataset(ObjectDetection)\valid\images\Moderado\Resultados_Herramienta';       % Carpeta con las imágenes originales
outputFolder = 'D:\Posgrado Segundo MR-2\PDI\Nueva carpeta (2)\ForesFireDataset(ObjectDetection)\valid\images\Moderado\Resultados';    % Carpeta donde se guardarán los resultados

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);  % crear carpeta de salida si no existe
end

imageFiles = dir(fullfile(inputFolder, '*.jpg')); % Cambia extensión según tus imágenes

%% Máscara del filtro High-Boost
w = [1 2 1; 2 4 2; 1 2 1]; 
s = sum(w(:)); % suma para normalización
kValues = [2, 10, 100]; % factores de High-Boost

%% Recorrer todas las imágenes
for idx = 1:numel(imageFiles)
    
    % Leer imagen
    ImOrg = imread(fullfile(inputFolder, imageFiles(idx).name));
    
    % Convertir a doble para procesamiento
    J = double(ImOrg);
    
    % Filtrado suavizado (convolución)
    ConvI = imfilter(J, w, 0, 'conv') * (1/s);
    
    % Mascara de detalle
    M = J - ConvI;
    
    % Aplicar High-Boost para cada valor de k
    for i = 1:numel(kValues)
        kFactor = kValues(i);
        IH = J + kFactor * M;
        
        % Normalizar a rango 0-255 y convertir a uint8
        IH_uint8 = uint8(min(max(IH, 0), 255));
        
        % Crear nombre de archivo de salida
        [~, name, ext] = fileparts(imageFiles(idx).name);
        outFileName = fullfile(outputFolder, [name, '_HB', num2str(kFactor), ext]);
        
        % Guardar la imagen
        imwrite(IH_uint8, outFileName);
    end
end

disp('Procesamiento completado. Todas las imágenes guardadas en la carpeta de resultados.');