function imagen_segmentada = aplicarKMeans(imagen, k)
    % aplicarKMeans: Segmenta imagen usando algoritmo K-Means en espacio RGB
    % Entrada: imagen (matriz MxNx3 uint8), k (número de clusters)
    % Salida: imagen_segmentada (matriz MxNx3 uint8)
    
    % CONVERSIÓN DE DATOS
    % Obtener dimensiones
    [filas, columnas, ~] = size(imagen);
    
    % Convertir imagen de uint8 (0-255) a double (0-1) para cálculos
    imagen_double = double(imagen) / 255;
    
    % REORGANIZAR DATOS RGB
    % Cada píxel es un punto con 3 coordenadas (R,G,B)
    % Convertir matriz 3D en matriz 2D: (total_pixeles) x 3
    pixeles = reshape(imagen_double, filas * columnas, 3);
    % reshape reorganiza los datos: primer argumento es la matriz
    % segundo: número de filas (todos los píxeles)
    % tercero: número de columnas (3 canales RGB)
    
    % INICIALIZAR CENTROIDES
    % Seleccionar k píxeles aleatorios como centroides iniciales
    num_pixeles = size(pixeles, 1);  % Total de píxeles
    idx_aleatorios = randperm(num_pixeles, k);  % Genera k índices aleatorios
    centroides = pixeles(idx_aleatorios, :);  % Centroides iniciales kx3
    
    % ITERACIONES DEL ALGORITMO K-MEANS
    max_iteraciones = 100;  % Límite de iteraciones
    tolerancia = 1e-4;      % Criterio de convergencia
    etiquetas_anteriores = zeros(num_pixeles, 1);  % Inicializar etiquetas
    
    for iter = 1:max_iteraciones
        % PASO A: Asignar cada píxel al centroide más cercano
        % Calcular distancias euclidianas entre cada píxel y cada centroide
        
        % Inicializar matriz de distancias
        distancias = zeros(num_pixeles, k);
        
        % Para cada centroide, calcular distancia a todos los píxeles
        for c = 1:k
            % diff: diferencia entre píxeles y centroide c
            % sqrt(sum(diff.^2,2)): norma euclidiana por fila
            diff = pixeles - centroides(c, :);
            distancias(:, c) = sqrt(sum(diff.^2, 2));
        end
        
        % Encontrar centroide más cercano para cada píxel
        [~, nuevas_etiquetas] = min(distancias, [], 2);
        % min(distancias,[],2): mínimo por fila (dimension 2)
        % [valores, índices]: índices indican cluster asignado
        
        % PASO B: Verificar convergencia
        if all(nuevas_etiquetas == etiquetas_anteriores)
            fprintf('Convergencia alcanzada en iteración %d\n', iter);
            break;
        end
        etiquetas_anteriores = nuevas_etiquetas;
        
        % PASO C: Actualizar centroides (media de píxeles en cada cluster)
        for c = 1:k
            % Encontrar píxeles pertenecientes al cluster c
            idx_cluster = (nuevas_etiquetas == c);
            
            % Si el cluster no está vacío, recalcular centroide
            if sum(idx_cluster) > 0
                centroides(c, :) = mean(pixeles(idx_cluster, :), 1);
                % mean(...,1): media a lo largo de cada columna (R,G,B por separado)
            end
        end
    end
    
    % CONSTRUIR IMAGEN SEGMENTADA
    % Reemplazar cada píxel por el color de su centroide asignado
    pixeles_segmentados = zeros(size(pixeles));
    
    for c = 1:k
        idx_cluster = (nuevas_etiquetas == c);
        % Asignar color del centroide a todos los píxeles del cluster
        pixeles_segmentados(idx_cluster, :) = repmat(centroides(c, :), ...
                                                      sum(idx_cluster), 1);
        % repmat: replica el centroide tantas veces como píxeles en cluster
    end
    
    % RECONSTRUIR IMAGEN ORIGINAL
    % Convertir de formato vector a matriz 3D
    imagen_segmentada = reshape(pixeles_segmentados, filas, columnas, 3);
    
    % Convertir de double a uint8 (necesario para mostrar imagen)
    imagen_segmentada = uint8(imagen_segmentada * 255);
    
end