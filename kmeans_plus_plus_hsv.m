function centroides = kmeans_plus_plus_hsv(pixeles, k)
    % kmeans_plus_plus_hsv: Mejor inicialización de centroides
    % Elige centroides lejos unos de otros
    
    num_pixeles = size(pixeles, 1);
    
    % Primer centroide: aleatorio
    idx = randi(num_pixeles);
    centroides = pixeles(idx, :);
    
    % Elegir centroides restantes
    for c = 2:k
        % Calcular distancia de cada píxel al centroide más cercano
        distancias_min = inf(num_pixeles, 1);
        
        for i = 1:c-1
            % Distancia al centroide i
            diff_h = abs(pixeles(:,1) - centroides(i,1));
            diff_h = min(diff_h, 1 - diff_h);
            diff_s = pixeles(:,2) - centroides(i,2);
            diff_v = pixeles(:,3) - centroides(i,3);
            
            dist = sqrt(diff_h.^2 + diff_s.^2 + diff_v.^2);
            distancias_min = min(distancias_min, dist);
        end
        
        % Probabilidad proporcional a la distancia al cuadrado
        probabilidades = distancias_min.^2;
        probabilidades = probabilidades / sum(probabilidades);
        
        % Elegir nuevo centroide según probabilidad
        idx = randsample(num_pixeles, 1, true, probabilidades);
        centroides(c, :) = pixeles(idx, :);
    end
end