% SCRIPT COMPLETO: Segmentación + Nombrado automático
% ===================================================

clear; clc; close all;

% ===== 1. CARGAR Y SEGMENTAR =====
imagen = imread('11.jpg');
imagen_hsv = rgb2hsv(imagen);
[filas, cols, ~] = size(imagen_hsv);
pixeles = reshape(imagen_hsv, filas*cols, 3);

k = 5;
[etiquetas, centroides] = kmeans(pixeles, k, 'MaxIter', 100);
etiquetas = reshape(etiquetas, filas, cols);

% ===== 2. ANALIZAR CADA REGIÓN =====
fprintf('=== CLASIFICACIÓN AUTOMÁTICA ===\n\n');

for r = 1:k
    % Obtener características
    mascara = (etiquetas == r);
    rgb = hsv2rgb(centroides(r, :)) * 255;
    R = rgb(1); G = rgb(2); B = rgb(3);
    
    % Calcular textura (requiere LBP)
    imagen_gris = rgb2gray(imagen);
    lbp = calcularLBP_manual(imagen_gris);
    lbp_region = lbp(mascara);
    entropia = entropy(uint8(lbp_region));
    
    % ===== CLASIFICAR =====
    if R > 200 && G > 150 && B < 100 && entropia > 4
        nombre = '🔥 FUEGO/VOLCÁN';
        emoji = '🔥';
    elseif R > 100 && G < 100 && B < 100
        nombre = '🪨 TIERRA/ROCA';
        emoji = '🪨';
    elseif B > R && B > G && B > 100 && entropia < 3.5
        nombre = '🌤️ CIELO';
        emoji = '🌤️';
    elseif G > R && G > B && G > 100
        nombre = '🌿 VERDE/VEGETACIÓN';
        emoji = '🌿';
    elseif abs(R-G) < 30 && abs(G-B) < 30 && R > 150
        nombre = '💨 HUMO/NUBES';
        emoji = '💨';
    elseif R > 200 && G > 200 && B > 150
        nombre = '☁️ NUBES BLANCAS';
        emoji = '☁️';
    else
        nombre = '❓ DESCONOCIDO';
        emoji = '❓';
    end
    
    % Mostrar resultado
    fprintf('%s Región %d: %s\n', emoji, r, nombre);
    fprintf('   Color: RGB(%.0f, %.0f, %.0f)\n', R, G, B);
    fprintf('   Textura: entropía %.2f\n', entropia);
    fprintf('   Tamaño: %.1f%% de la imagen\n\n', 100*sum(mascara(:))/(filas*cols));
end

% ===== 3. VISUALIZACIÓN CON NOMBRES =====
figure('Position', [100, 100, 1400, 600]);

% Imagen segmentada con etiquetas
subplot(1,2,1);
imshow(label2rgb(etiquetas));
title('Regiones Segmentadas', 'FontSize', 14);

% Imagen con nombres
subplot(1,2,2);
imshow(imagen);
hold on;
for r = 1:k
    mascara = (etiquetas == r);
    stats = regionprops(mascara, 'Centroid');
    if ~isempty(stats)
        centroid = stats(1).Centroid;
        text(centroid(1), centroid(2), sprintf('R%d', r), ...
            'Color', 'red', 'FontSize', 14, 'FontWeight', 'bold', ...
            'BackgroundColor', 'white');
    end
end
title('Regiones Numeradas', 'FontSize', 14);

% Función LBP
function lbp = calcularLBP_manual(img)
    img = double(img);
    [h,w] = size(img);
    lbp = zeros(h,w);
    for i = 2:h-1
        for j = 2:w-1
            centro = img(i,j);
            v = [img(i-1,j-1), img(i-1,j), img(i-1,j+1), ...
                 img(i,j+1), img(i+1,j+1), img(i+1,j), ...
                 img(i+1,j-1), img(i,j-1)];
            lbp(i,j) = 0;
            for n = 1:8
                if v(n) >= centro
                    lbp(i,j) = lbp(i,j) + 2^(n-1);
                end
            end
        end
    end
end