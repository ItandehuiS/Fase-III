function KMeans_Segmentacion_Imagen()
    % ============================================
    % PROGRAMA PRINCIPAL: Segmentación con K-Means
    % ============================================
    
    % PASO 1: Cargar la imagen
    imagen_original = imread('imagen_ejemplo.jpg'); % Lee archivo de imagen
    % imread devuelve matriz 3D (filas, columnas, canales RGB)
    
    % PASO 2: Mostrar información básica
    [filas, columnas, canales] = size(imagen_original);
    fprintf('Dimensiones: %d x %d x %d\n', filas, columnas, canales);
    
    % PASO 3: Aplicar segmentación K-Means
    num_clusters = 5;  % Número de segmentos (regiones a identificar)
    imagen_segmentada = aplicarKMeans(imagen_original, num_clusters);
    
    % PASO 4: Visualizar resultados
    visualizarResultados(imagen_original, imagen_segmentada, num_clusters);
    
end