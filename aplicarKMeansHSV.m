function imagen_segmentada = aplicarKMeansHSV(imagen_rgb, k)
    % aplicarKMeansHSV: Segmenta usando K-Means en espacio HSV
    % Entrada: imagen RGB, número de clusters k
    % Salida: imagen segmentada en RGB
    
    % PASO 1: Convertir RGB a HSV
    % hsv = rgb2hsv(imagen_rgb)  % MATLAB tiene función nativa
    % Pero la implementamos manualmente para entender el proceso
    
    imagen_hsv = rgb2hsv(imagen_rgb);  % Convierte a HSV
    % HSV: H (0-1), S (0-1), V (0-1)
    % En MATLAB, H está normalizado: 0-1 (equivalente a 0-360°)
    
    % PASO 2: Reorganizar datos
    [filas, columnas, ~] = size(imagen_hsv);
    pixeles = reshape(imagen_hsv, filas * columnas, 3);
    % Cada píxel es ahora [Hue, Saturation, Value]
    
    % PASO 3: Inicializar centroides (en espacio HSV)
    num_pixeles = size(pixeles, 1);
    idx_aleatorios = randperm(num_pixeles, k);
    centroides = pixeles(idx_aleatorios, :);
    
    % PASO 4: Algoritmo K-Means
    max_iteraciones = 100;
    tolerancia = 1e-4;
    etiquetas_anteriores = zeros(num_pixeles, 1);
    
    for iter = 1:max_iteraciones
        % Calcular distancias (IMPORTANTE: distancia circular para el HUE)
        distancias = zeros(num_pixeles, k);
        
        for c = 1:k
            % Diferencia para cada canal
            diff_h = abs(pixeles(:,1) - centroides(c,1));
            % Distancia circular para el HUE (porque 0° = 360°)
            diff_h_circular = min(diff_h, 1 - diff_h);
            
            diff_s = pixeles(:,2) - centroides(c,2);
            diff_v = pixeles(:,3) - centroides(c,3);
            
            % Distancia euclidiana con hue circular
            distancias(:,c) = sqrt(diff_h_circular.^2 + diff_s.^2 + diff_v.^2);
        end
        
        % Asignar al centroide más cercano
        [~, nuevas_etiquetas] = min(distancias, [], 2);
        
        % Verificar convergencia
        if all(nuevas_etiquetas == etiquetas_anteriores)
            fprintf('  Convergencia en iteración %d\n', iter);
            break;
        end
        etiquetas_anteriores = nuevas_etiquetas;
        
        % Actualizar centroides (promedio en HSV)
        for c = 1:k
            idx_cluster = (nuevas_etiquetas == c);
            if sum(idx_cluster) > 0
                % IMPORTANTE: Para el HUE, usar promedio circular
                hues = pixeles(idx_cluster, 1);
                
                % Promedio circular para el HUE
                if range(hues) > 0.5  % Si los hues están dispersos alrededor del círculo
                    % Convertir a coordenadas cartesianas para promedio circular
                    angulos = hues * 2 * pi;
                    x_prom = mean(cos(angulos));
                    y_prom = mean(sin(angulos));
                    hue_promedio = atan2(y_prom, x_prom) / (2 * pi);
                    if hue_promedio < 0
                        hue_promedio = hue_promedio + 1;
                    end
                else
                    hue_promedio = mean(hues);
                end
                
                % Promedio normal para S y V
                sat_promedio = mean(pixeles(idx_cluster, 2));
                val_promedio = mean(pixeles(idx_cluster, 3));
                
                centroides(c, :) = [hue_promedio, sat_promedio, val_promedio];
            end
        end
    end
    
    % PASO 5: Reconstruir imagen segmentada
    pixeles_segmentados = zeros(size(pixeles));
    for c = 1:k
        idx_cluster = (nuevas_etiquetas == c);
        pixeles_segmentados(idx_cluster, :) = repmat(centroides(c, :), sum(idx_cluster), 1);
    end
    
    % Reconstruir y convertir de vuelta a RGB
    imagen_hsv_segmentada = reshape(pixeles_segmentados, filas, columnas, 3);
    imagen_segmentada = hsv2rgb(imagen_hsv_segmentada);
    imagen_segmentada = uint8(imagen_segmentada * 255);
end