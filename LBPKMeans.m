% VERSIÓN SIMPLIFICADA - SIN ERRORES
% ===================================

clear; clc; close all;

% Cargar imagen
imagen = imread('13.jpg');
imagen_gris = rgb2gray(imagen);

% Segmentación por color (K-Means en HSV)
imagen_hsv = rgb2hsv(imagen);
[filas, cols, ~] = size(imagen_hsv);
pixeles = reshape(imagen_hsv, filas*cols, 3);

k = 5;
[etiquetas, centroides] = kmeans(pixeles, k, 'MaxIter', 100);
etiquetas = reshape(etiquetas, filas, cols);

% Calcular LBP (versión simple)
lbp = zeros(filas, cols);
for i = 2:filas-1
    for j = 2:cols-1
        centro = double(imagen_gris(i,j));
        % Vecinos
        v = [double(imagen_gris(i-1,j-1)), double(imagen_gris(i-1,j)), ...
             double(imagen_gris(i-1,j+1)), double(imagen_gris(i,j+1)), ...
             double(imagen_gris(i+1,j+1)), double(imagen_gris(i+1,j)), ...
             double(imagen_gris(i+1,j-1)), double(imagen_gris(i,j-1))];
        % Umbral y suma
        lbp(i,j) = 0;
        for n = 1:8
            if v(n) >= centro
                lbp(i,j) = lbp(i,j) + 2^(n-1);
            end
        end
    end
end

% Analizar cada región
fprintf('=== ANÁLISIS POR REGIÓN ===\n\n');

for r = 1:k
    mascara = (etiquetas == r);
    lbp_region = lbp(mascara);
    
    color_rgb = hsv2rgb(centroides(r,:)) * 255;
    
    fprintf('Región %d:\n', r);
    fprintf('  Color: RGB(%.0f, %.0f, %.0f)\n', color_rgb(1), color_rgb(2), color_rgb(3));
    fprintf('  Tamaño: %d píxeles\n', sum(mascara(:)));
    fprintf('  Media LBP: %.2f\n', mean(lbp_region(:)));
    fprintf('  Entropía: %.2f\n', entropy(uint8(lbp_region)));
    
    if entropy(uint8(lbp_region)) < 3
        fprintf('  Textura: LISA\n');
    elseif entropy(uint8(lbp_region)) < 5
        fprintf('  Textura: MEDIA\n');
    else
        fprintf('  Textura: RUGOSA\n');
    end
    fprintf('------------------------\n');
end

% Visualización
figure;
subplot(2,2,1); imshow(imagen); title('Original');
subplot(2,2,2); imshow(label2rgb(etiquetas)); title('Regiones por Color');
subplot(2,2,3); imshow(lbp, []); title('LBP (Textura)'); colormap('jet');
subplot(2,2,4);
imshow(imagen); hold on;
for r = 1:k
    boundaries = bwboundaries(etiquetas == r);
    for b = 1:length(boundaries)
        plot(boundaries{b}(:,2), boundaries{b}(:,1), 'yellow', 'LineWidth', 1);
    end
end
title('Regiones Segmentadas');

fprintf('\n✅ Análisis completado\n');