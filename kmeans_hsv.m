function [etiquetas, centros] = kmeans_hsv(img, K)
    hsv     = rgb2hsv(img);             % Conversión a HSV
    [h, w, ~] = size(hsv);
    pixeles = double(reshape(hsv, h*w, 3));
    
    % Opcionalmente usar solo H y S (ignorar V reduce ruido de iluminación)
    % pixeles = pixeles(:, 1:2);
    
    [idx, centros] = kmeans(pixeles, K, ...
        'Distance',   'sqeuclidean', ...
        'Replicates', 5);
    
    etiquetas = reshape(idx, h, w);
    
    % Identificar clúster de fuego (mayor saturación y matiz cálido)
    [~, cluster_fuego] = max(centros(:,2));  % Mayor saturación
    mascara_fuego = (etiquetas == cluster_fuego);
    
    figure;
    subplot(1,3,1); imshow(img);              title('Original');
    subplot(1,3,2); imshow(etiquetas,[]);     title(sprintf('K-Means HSV  K=%d',K)); colormap(jet);
    subplot(1,3,3); imshow(mascara_fuego);    title('Máscara fuego');
end