% SCRIPT PRINCIPAL PARA EJECUTAR EL PROGRAMA
% =============================================

% Limpiar entorno
clear; clc; close all;

% Cargar imagen (puedes cambiar por tu imagen)
% Si no tienes imagen, crear una de prueba
if exist('8.jpg', 'file')    % <<--- SOLO CAMBIÉ 'Alto' por 'file'
    imagen = imread('8.jpg');
else
    % Crear imagen de prueba con degradado
    [X,Y] = meshgrid(1:300,1:200);
    imagen = uint8(cat(3, X/300*255, Y/200*255, (X+Y)/500*255));
    imwrite(imagen, 'imagen_ejemplo.jpg');
    fprintf('Imagen de prueba creada: imagen_ejemplo.jpg\n');
end

% Opciones de ejecución
fprintf('=== SEGMENTACIÓN CON K-MEANS (ESPACIO RGB) ===\n');
fprintf('Algoritmo: K-Means en espacio de color RGB\n');
fprintf('Distancia: Euclidiana entre vectores [R,G,B]\n\n');

% 1. Segmentación básica
fprintf('Ejecutando segmentación básica...\n');
imagen_segmentada = aplicarKMeans(imagen, 5);
visualizarResultados(imagen, imagen_segmentada, 5);

% 2. Comparar diferentes clusters
fprintf('\nComparando diferentes números de clusters...\n');
compararClusters(imagen);

% 3. Guardar resultados
guardarResultados(imagen, imagen_segmentada, 'resultado_segmentacion.jpg');

fprintf('\n¡PROCESO COMPLETADO!\n');