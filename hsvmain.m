% SCRIPT PRINCIPAL PARA EJECUTAR EL PROGR
% SEGMENTACIÓN HSV PARA UNA SOLA IMAGEN
% =====================================

clear; clc; close all;

% Cargar imagen
imagen = imread('11.jpg');  % Cambia por tu imagen

% Convertir a HSV
hsv = rgb2hsv(imagen);

% Parámetros
k = 5;  % Número de clusters

% Reorganizar datos
[filas, cols, ~] = size(hsv);
pixeles = reshape(hsv, filas*cols, 3);

% Inicializar centroides
idx = randperm(size(pixeles,1), k);
centroides = pixeles(idx, :);

% K-Means
for iter = 1:50
    % Calcular distancias
    dist = zeros(size(pixeles,1), k);
    for c = 1:k
        diff = pixeles - centroides(c,:);
        dist(:,c) = sqrt(sum(diff.^2, 2));
    end
    
    % Asignar clusters
    [~, etiquetas] = min(dist, [], 2);
    
    % Actualizar centroides
    for c = 1:k
        if sum(etiquetas == c) > 0
            centroides(c,:) = mean(pixeles(etiquetas == c,:), 1);
        end
    end
end

% Reconstruir imagen
pixeles_seg = zeros(size(pixeles));
for c = 1:k
    pixeles_seg(etiquetas == c,:) = repmat(centroides(c,:), sum(etiquetas == c), 1);
end

% Convertir de vuelta a RGB
hsv_seg = reshape(pixeles_seg, filas, cols, 3);
resultado = hsv2rgb(hsv_seg);

% Mostrar
figure;
subplot(1,2,1); imshow(imagen); title('Original');
subplot(1,2,2); imshow(resultado); title(sprintf('Segmentación HSV (K=%d)', k));

% Guardar
imwrite(uint8(resultado*255), 'segmentada_HSV.jpg');
fprintf('✅ Imagen segmentada guardada como: segmentada_HSV.jpg\n');