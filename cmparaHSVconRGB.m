% SEGMENTACIÓN CON K-MEANS PARA UNA SOLA IMAGEN
% =============================================

clear; clc; close all;

% ===== CONFIGURACIÓN =====
nombre_imagen = '14.jpg';        % Cambia por el nombre de tu imagen
k = 8;                          % Número de clusters

% ===== CARGAR IMAGEN =====
if ~exist(nombre_imagen, 'file')
    error('No se encuentra la imagen: %s', nombre_imagen);
end

imagen = imread(nombre_imagen);
fprintf('✅ Imagen cargada: %s\n', nombre_imagen);
fprintf('📏 Dimensiones: %d x %d píxeles\n', size(imagen,1), size(imagen,2));

% ===== 1. SEGMENTACIÓN RGB =====
fprintf('\n🔴 Segmentando en RGB...\n');
tic;
imagen_rgb = kmeans_rgb(imagen, k);
tiempo_rgb = toc;
fprintf('   ✅ Completado en %.2f segundos\n', tiempo_rgb);

% ===== 2. SEGMENTACIÓN HSV =====
fprintf('\n🟢 Segmentando en HSV...\n');
tic;
imagen_hsv = kmeans_hsv(imagen, k);
tiempo_hsv = toc;
fprintf('   ✅ Completado en %.2f segundos\n', tiempo_hsv);

% ===== MOSTRAR RESULTADOS =====
figure('Name', 'Comparación RGB vs HSV', 'Position', [100, 100, 1200, 600]);

% Original
subplot(2, 2, 1);
imshow(imagen);
title('Imagen Original', 'FontSize', 12, 'FontWeight', 'bold');

% RGB
subplot(2, 2, 2);
imshow(imagen_rgb);
title(sprintf('RGB - K=%d', k), 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Sensible a cambios de brillo');

% HSV
subplot(2, 2, 3);
imshow(imagen_hsv);
title(sprintf('HSV - K=%d', k), 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Robusto a cambios de iluminación');

% Diferencia
subplot(2, 2, 4);
diferencia = imabsdiff(imagen_rgb, imagen_hsv);
imshow(diferencia);
title('Diferencia RGB vs HSV', 'FontSize', 12, 'FontWeight', 'bold');

% ===== GUARDAR RESULTADOS =====
imwrite(imagen_rgb, 'resultado_RGB.jpg');
imwrite(imagen_hsv, 'resultado_HSV.jpg');
fprintf('\n💾 Resultados guardados:\n');
fprintf('   - resultado_RGB.jpg\n');
fprintf('   - resultado_HSV.jpg\n');

% ===== FUNCIÓN K-MEANS RGB =====
function img_segmentada = kmeans_rgb(imagen, k)
    % Segmentación en espacio RGB
    
    % Convertir a double y normalizar
    img_double = double(imagen) / 255;
    [filas, cols, ~] = size(img_double);
    
    % Reorganizar píxeles
    pixeles = reshape(img_double, filas * cols, 3);
    
    % Inicializar centroides (aleatorios)
    idx_aleatorios = randperm(size(pixeles,1), k);
    centroides = pixeles(idx_aleatorios, :);
    
    % K-Means
    for iter = 1:100
        % Calcular distancias
        distancias = zeros(size(pixeles,1), k);
        for c = 1:k
            diff = pixeles - centroides(c, :);
            distancias(:, c) = sqrt(sum(diff.^2, 2));
        end
        
        % Asignar clusters
        [~, etiquetas] = min(distancias, [], 2);
        
        % Actualizar centroides
        centroides_nuevos = centroides;
        for c = 1:k
            idx = (etiquetas == c);
            if sum(idx) > 0
                centroides_nuevos(c, :) = mean(pixeles(idx, :), 1);
            end
        end
        
        % Verificar convergencia
        if norm(centroides_nuevos - centroides) < 1e-4
            break;
        end
        centroides = centroides_nuevos;
    end
    
    % Reconstruir imagen
    pixeles_seg = zeros(size(pixeles));
    for c = 1:k
        idx = (etiquetas == c);
        if sum(idx) > 0
            pixeles_seg(idx, :) = repmat(centroides(c, :), sum(idx), 1);
        end
    end
    
    img_segmentada = uint8(reshape(pixeles_seg, filas, cols, 3) * 255);
end

% ===== FUNCIÓN K-MEANS HSV =====
function img_segmentada = kmeans_hsv(imagen, k)
    % Segmentación en espacio HSV
    
    % Convertir RGB a HSV (esta es la única diferencia)
    img_hsv = rgb2hsv(imagen);
    [filas, cols, ~] = size(img_hsv);
    
    % Reorganizar píxeles
    pixeles = reshape(img_hsv, filas * cols, 3);
    
    % Inicializar centroides (aleatorios)
    idx_aleatorios = randperm(size(pixeles,1), k);
    centroides = pixeles(idx_aleatorios, :);
    
    % K-Means
    for iter = 1:100
        % Calcular distancias
        distancias = zeros(size(pixeles,1), k);
        for c = 1:k
            diff = pixeles - centroides(c, :);
            distancias(:, c) = sqrt(sum(diff.^2, 2));
        end
        
        % Asignar clusters
        [~, etiquetas] = min(distancias, [], 2);
        
        % Actualizar centroides
        centroides_nuevos = centroides;
        for c = 1:k
            idx = (etiquetas == c);
            if sum(idx) > 0
                centroides_nuevos(c, :) = mean(pixeles(idx, :), 1);
            end
        end
        
        % Verificar convergencia
        if norm(centroides_nuevos - centroides) < 1e-4
            break;
        end
        centroides = centroides_nuevos;
    end
    
    % Reconstruir imagen
    pixeles_seg = zeros(size(pixeles));
    for c = 1:k
        idx = (etiquetas == c);
        if sum(idx) > 0
            pixeles_seg(idx, :) = repmat(centroides(c, :), sum(idx), 1);
        end
    end
    
    % Convertir de HSV a RGB
    img_hsv_seg = reshape(pixeles_seg, filas, cols, 3);
    img_segmentada = uint8(hsv2rgb(img_hsv_seg) * 255);
end