function visualizarComparacionHSV(imagen_rgb, imagen_segmentada, k)
    % Muestra comparación entre segmentación RGB y HSV
    
    % Segmentar también en RGB para comparar
    imagen_segmentada_rgb = aplicarKMeansRGB(imagen_rgb, k);
    
    figure('Name', sprintf('Comparación RGB vs HSV (K=%d)', k), 'Position', [100, 100, 1400, 500]);
    
    % Original
    subplot(1, 3, 1);
    imshow(imagen_rgb);
    title('Imagen Original');
    
    % Segmentación RGB
    subplot(1, 3, 2);
    imshow(imagen_segmentada_rgb);
    title(sprintf('RGB - K=%d', k));
    xlabel('Sensible a cambios de brillo');
    
    % Segmentación HSV
    subplot(1, 3, 3);
    imshow(imagen_segmentada);
    title(sprintf('HSV - K=%d', k));
    xlabel('Robusto a cambios de iluminación');
    
    sgtitle('Comparación: RGB vs HSV para K-Means');
end

function imagen_segmentada = aplicarKMeansRGB(imagen_rgb, k)
    % Versión simple de K-Means en RGB (sin optimizaciones)
    [filas, columnas, ~] = size(imagen_rgb);
    pixeles = reshape(double(imagen_rgb)/255, filas*columnas, 3);
    
    % Inicializar
    idx = randperm(size(pixeles,1), k);
    centroides = pixeles(idx, :);
    
    for iter = 1:50
        % Distancias
        distancias = zeros(size(pixeles,1), k);
        for c = 1:k
            distancias(:,c) = sqrt(sum((pixeles - centroides(c,:)).^2, 2));
        end
        [~, etiquetas] = min(distancias, [], 2);
        
        % Actualizar centroides
        for c = 1:k
            idx_c = (etiquetas == c);
            if sum(idx_c) > 0
                centroides(c,:) = mean(pixeles(idx_c,:), 1);
            end
        end
    end
    
    % Reconstruir
    pixeles_seg = zeros(size(pixeles));
    for c = 1:k
        pixeles_seg(etiquetas==c, :) = repmat(centroides(c,:), sum(etiquetas==c), 1);
    end
    imagen_segmentada = uint8(reshape(pixeles_seg, filas, columnas, 3) * 255);
end