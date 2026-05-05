% SCRIPT PARA APLICAR K-MEANS A TODAS LAS IMÁGENES DE UNA CARPETA
% ================================================================

% Limpiar entorno
clear; clc; close all;

% Configuración de carpetas
carpeta_origen = 'D:\Posgrado Segundo MR-2\PDI\Nueva carpeta (2)\ForesFireDataset(ObjectDetection)\valid\images\Sin_incendio';    % Carpeta donde están tus fotos
carpeta_destino = 'resultados_segmentacio'; % Carpeta donde se guardarán los resultados

% Crear carpeta de destino si no existe
if ~exist(carpeta_destino, 'dir')
    mkdir(carpeta_destino);
end

% Opciones de ejecución
fprintf('=== SEGMENTACIÓN CON K-MEANS (ESPACIO RGB) ===\n');
fprintf('Algoritmo: K-Means en espacio de color RGB\n');
fprintf('Distancia: Euclidiana entre vectores [R,G,B]\n');
fprintf('Número de clusters: K=5\n\n');

% Obtener lista de imágenes de la carpeta
archivos = dir(fullfile(carpeta_origen, '*.jpg'));
archivos = [archivos; dir(fullfile(carpeta_origen, '*.png'))];
archivos = [archivos; dir(fullfile(carpeta_origen, '*.jpeg'))];

% Verificar si hay imágenes
if isempty(archivos)
    error('❌ No se encontraron imágenes en la carpeta "%s"', carpeta_origen);
end

fprintf('🔍 Encontradas %d imágenes para procesar\n\n', length(archivos));

% Procesar cada imagen
for i = 1:length(archivos)
    
    % Obtener nombre del archivo
    nombre_imagen = archivos(i).name;
    fprintf('📷 [%d/%d] Procesando: %s\n', i, length(archivos), nombre_imagen);
    
    % Cargar imagen
    ruta_imagen = fullfile(carpeta_origen, nombre_imagen);
    imagen = imread(ruta_imagen);
    
    % Aplicar K-Means con K=5
    imagen_segmentada = aplicarKMeans(imagen, 8);
    
    % Guardar resultado en la carpeta destino
    ruta_segmentada = fullfile(carpeta_destino, nombre_imagen);
    imwrite(imagen_segmentada, ruta_segmentada);
    
    fprintf('   ✅ Guardada: %s\n', nombre_imagen);
    fprintf('   📁 En: %s\n\n', carpeta_destino);
end

fprintf('========================================\n');
fprintf('✨ ¡PROCESO COMPLETADO! ✨\n');
fprintf('========================================\n');
fprintf('📊 Total de imágenes procesadas: %d\n', length(archivos));
fprintf('📁 Resultados guardados en: %s\n', carpeta_destino);
fprintf('========================================\n');

% ============================================
% FUNCIÓN aplicarKMeans
% ============================================
function imagen_segmentada = aplicarKMeans(imagen, k)
    % aplicarKMeans: Segmenta imagen usando K-Means en espacio RGB
    
    % Convertir a double y normalizar
    imagen_double = double(imagen) / 255;
    
    % Obtener dimensiones
    [filas, columnas, ~] = size(imagen_double);
    
    % Reorganizar píxeles
    pixeles = reshape(imagen_double, filas * columnas, 3);
    
    % Inicializar centroides aleatorios
    num_pixeles = size(pixeles, 1);
    idx_aleatorios = randperm(num_pixeles, k);
    centroides = pixeles(idx_aleatorios, :);
    
    % Parámetros K-Means
    max_iteraciones = 100;
    etiquetas_anteriores = zeros(num_pixeles, 1);
    
    % Algoritmo K-Means
    for iter = 1:max_iteraciones
        % Calcular distancias
        distancias = zeros(num_pixeles, k);
        for c = 1:k
            diff = pixeles - centroides(c, :);
            distancias(:, c) = sqrt(sum(diff.^2, 2));
        end
        
        % Asignar etiquetas
        [~, nuevas_etiquetas] = min(distancias, [], 2);
        
        % Verificar convergencia
        if all(nuevas_etiquetas == etiquetas_anteriores)
            break;
        end
        etiquetas_anteriores = nuevas_etiquetas;
        
        % Actualizar centroides
        for c = 1:k
            idx_cluster = (nuevas_etiquetas == c);
            if sum(idx_cluster) > 0
                centroides(c, :) = mean(pixeles(idx_cluster, :), 1);
            end
        end
    end
    
    % Reconstruir imagen segmentada
    pixeles_segmentados = zeros(size(pixeles));
    for c = 1:k
        idx_cluster = (nuevas_etiquetas == c);
        if sum(idx_cluster) > 0
            pixeles_segmentados(idx_cluster, :) = repmat(centroides(c, :), sum(idx_cluster), 1);
        end
    end
    
    % Reconstruir y convertir a uint8
    imagen_segmentada = reshape(pixeles_segmentados, filas, columnas, 3);
    imagen_segmentada = uint8(imagen_segmentada * 255);
end