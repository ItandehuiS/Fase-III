function [imagen_segmentada, imagen_hsv, etiquetas, centroides] = aplicarKMeansHSV_Detallado(imagen_rgb, k)
    % Versión detallada que devuelve más información
    
    % Convertir a HSV
    imagen_hsv = rgb2hsv(imagen_rgb);
    [filas, columnas, ~] = size(imagen_hsv);
    pixeles = reshape(imagen_hsv, filas * columnas, 3);
    
    % Inicializar centroides
    num_pixeles = size(pixeles, 1);
    idx_aleatorios = randperm(num_pixeles, k);
    centroides = pixeles(idx_aleatorios, :);
    
    % K-Means con inicialización mejorada (K-Means++)
    centroides = kmeans_plus_plus_hsv(pixeles, k);
    
    max_iter = 100;
    tol = 1e-4;
    etiquetas_prev = zeros(num_pixeles, 1);
    
    for iter = 1:max_iter
        % Matriz de distancias
        distancias = zeros(num_pixeles, k);
        
        for c = 1:k
            % Calcular distancias considerando circularidad del HUE
            diff_h = abs(pixeles(:,1) - centroides(c,1));
            diff_h = min(diff_h, 1 - diff_h);  % Distancia circular
            diff_s = pixeles(:,2) - centroides(c,2);
            diff_v = pixeles(:,3) - centroides(c,3);
            
            distancias(:,c) = sqrt(diff_h.^2 + diff_s.^2 + diff_v.^2);
        end
        
        [~, etiquetas] = min(distancias, [], 2);
        
        % Verificar convergencia
        if all(etiquetas == etiquetas_prev)
            break;
        end
        etiquetas_prev = etiquetas;
        
        % Actualizar centroides
        for c = 1:k
            idx = (etiquetas == c);
            if sum(idx) > 0
                % Promedio circular para HUE
                hues = pixeles(idx, 1);
                angulos = hues * 2 * pi;
                x_prom = mean(cos(angulos));
                y_prom = mean(sin(angulos));
                hue_prom = atan2(y_prom, x_prom) / (2 * pi);
                if hue_prom < 0
                    hue_prom = hue_prom + 1;
                end
                
                % Promedios normales para S y V
                sat_prom = mean(pixeles(idx, 2));
                val_prom = mean(pixeles(idx, 3));
                
                centroides(c, :) = [hue_prom, sat_prom, val_prom];
            end
        end
    end
    
    % Reconstruir imagen
    pixeles_seg = zeros(size(pixeles));
    for c = 1:k
        idx = (etiquetas == c);
        pixeles_seg(idx, :) = repmat(centroides(c, :), sum(idx), 1);
    end
    
    imagen_hsv_seg = reshape(pixeles_seg, filas, columnas, 3);
    imagen_segmentada = hsv2rgb(imagen_hsv_seg);
    imagen_segmentada = uint8(imagen_segmentada * 255);
end