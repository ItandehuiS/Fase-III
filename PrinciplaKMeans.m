% SCRIPT PRINCIPAL - K-MEANS CON K=5 PARA TODAS LAS IMÁGENES
% ============================================================

% Limpiar entorno
clear; clc; close all;

% ========== CONFIGURACIÓN DE CARPETAS ==========
carpeta_origen = 'imagenes_originales';    % Carpeta donde están tus fotos
carpeta_destino = 'resultados_segmentacion'; % Carpeta donde se guardarán los resultados

% Crear carpeta de destino si no existe
if ~exist(carpeta_destino, 'dir')
    mkdir(carpeta_destino);
    fprintf('📁 Carpeta de resultados creada: %s\n', carpeta_destino);
end

% ========== OBTENER LISTA DE IMÁGENES ==========
% Buscar archivos de imagen en la carpeta de origen
formatos_imagen = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tif'};
archivos_imagen = {};

for i = 1:length(formatos_imagen)
    archivos_temp = dir(fullfile(carpeta_origen, formatos_imagen{i}));
    archivos_imagen = [archivos_imagen; archivos_temp];
end

% Verificar si hay imágenes
if isempty(archivos_imagen)
    fprintf('❌ ERROR: No se encontraron imágenes en la carpeta "%s"\n', carpeta_origen);
    fprintf('📌 Creando carpeta y una imagen de prueba...\n');
    
    % Crear carpeta de origen si no existe
    if ~exist(carpeta_origen, 'dir')
        mkdir(carpeta_origen);
    end
    
    % Crear imagen de prueba
    [X,Y] = meshgrid(1:300,1:200);
    imagen_prueba = uint8(cat(3, X/300*255, Y/200*255, (X+Y)/500*255));
    imwrite(imagen_prueba, fullfile(carpeta_origen, 'imagen_prueba.jpg'));
    fprintf('✅ Imagen de prueba creada\n');
    
    % Actualizar lista
    archivos_imagen = dir(fullfile(carpeta_origen, '*.jpg'));
end

% CONVERTIR A CELDA PARA EVITAR ERRORES
if isstruct(archivos_imagen)
    % Si es estructura, convertir a celda
    nombres_archivos = {archivos_imagen.name}';
else
    % Si ya es celda, usarlo directamente
    nombres_archivos = archivos_imagen;
end

fprintf('\n🔍 Encontradas %d imágenes para procesar\n', length(nombres_archivos));
fprintf('================================================\n\n');

% ========== PROCESAR CADA IMAGEN CON K=5 ==========
for idx_img = 1:length(nombres_archivos)
    
    % Obtener nombre del archivo (funciona con estructura o celda)
    if isstruct(archivos_imagen)
        nombre_archivo = archivos_imagen(idx_img).name;
    else
        nombre_archivo = nombres_archivos{idx_img};
    end
    
    fprintf('📷 [%d/%d] Procesando: %s\n', idx_img, length(nombres_archivos), nombre_archivo);
    
    % CARGAR IMAGEN
    ruta_imagen = fullfile(carpeta_origen, nombre_archivo);
    
    % Verificar que el archivo existe
    if ~exist(ruta_imagen, 'file')
        fprintf('   ⚠️ Archivo no encontrado: %s\n', nombre_archivo);
        continue;
    end
    
    imagen = imread(ruta_imagen);
    
    % Verificar dimensiones de la imagen
    [filas, columnas, canales] = size(imagen);
    fprintf('   📏 Dimensiones: %d x %d\n', filas, columnas);
    
    % Si es escala de grises, convertir a RGB
    if canales == 1
        imagen = cat(3, imagen, imagen, imagen);
        fprintf('   🔄 Convertida de grises a RGB\n');
    end
    
    % APLICAR K-MEANS CON K=5
    fprintf('   🔄 Aplicando K-Means con K=5...\n');
    tic;
    imagen_segmentada = aplicarKMeans(imagen, 5);
    tiempo = toc;
    
    fprintf('   ✅ Segmentada en %.2f segundos\n', tiempo);
    
    % CREAR CARPETA PARA ESTA IMAGEN
    [~, nombre_base, ~] = fileparts(nombre_archivo);
    carpeta_imagen_destino = fullfile(carpeta_destino, nombre_base);
    if ~exist(carpeta_imagen_destino, 'dir')
        mkdir(carpeta_imagen_destino);
        fprintf('   📁 Carpeta creada: %s\n', nombre_base);
    end
    
    % GUARDAR RESULTADOS
    % Guardar imagen segmentada
    ruta_segmentada = fullfile(carpeta_imagen_destino, 'segmentada_K5.jpg');
    imwrite(imagen_segmentada, ruta_segmentada);
    
    % Guardar comparación (original + segmentada)
    % Asegurar que ambas imágenes tengan el mismo tamaño para concatenar
    if size(imagen,1) == size(imagen_segmentada,1) && size(imagen,2) == size(imagen_segmentada,2)
        comparacion = [imagen, imagen_segmentada];
        ruta_comparacion = fullfile(carpeta_imagen_destino, 'comparacion.jpg');
        imwrite(comparacion, ruta_comparacion);
    else
        % Si hay diferencia de tamaño, guardar por separado
        fprintf('   ⚠️ Las dimensiones no coinciden, guardando solo segmentada\n');
    end
    
    fprintf('   💾 Guardado en: %s\n', carpeta_imagen_destino);
    fprintf('   📄 Archivos: segmentada_K5.jpg | comparacion.jpg\n');
    fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
end

% ========== RESUMEN FINAL ==========
fprintf('\n========================================\n');
fprintf('✨ PROCESO COMPLETADO ✨\n');
fprintf('========================================\n');
fprintf('📊 IMÁGENES PROCESADAS: %d\n', length(nombres_archivos));
fprintf('🎨 CLUSTERS USADOS: K=5\n');
fprintf('📁 RESULTADOS EN: %s\n', carpeta_destino);
fprintf('========================================\n');

% Mostrar estructura de carpetas creada
if exist(carpeta_destino, 'dir')
    fprintf('\n📁 ESTRUCTURA GENERADA:\n');
    fprintf('%s/\n', carpeta_destino);
    subcarpetas = dir(carpeta_destino);
    subcarpetas = subcarpetas([subcarpetas.isdir]);
    subcarpetas = subcarpetas(~ismember({subcarpetas.name}, {'.', '..'}));
    
    for i = 1:min(5, length(subcarpetas))
        fprintf('   ├── %s/\n', subcarpetas(i).name);
        fprintf('   │   ├── segmentada_K5.jpg\n');
        fprintf('   │   └── comparacion.jpg\n');
    end
    if length(subcarpetas) > 5
        fprintf('   └── ... (%d carpetas más)\n', length(subcarpetas)-5);
    end
end

% ============================================
% FUNCIÓN aplicarKMeans (incluir al final)
% ============================================
function imagen_segmentada = aplicarKMeans(imagen, k)
    % aplicarKMeans: Segmenta imagen usando K-Means en espacio RGB
    % Entrada: imagen (MxNx3), k (número de clusters)
    % Salida: imagen_segmentada (MxNx3)
    
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
    tolerancia = 1e-4;
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
        pixeles_segmentados(idx_cluster, :) = repmat(centroides(c, :), sum(idx_cluster), 1);
    end
    
    % Reconstruir y convertir a uint8
    imagen_segmentada = reshape(pixeles_segmentados, filas, columnas, 3);
    imagen_segmentada = uint8(imagen_segmentada * 255);
end