function [etiquetas, centros] = kmeans_rgb(img, K)
    % Reshape: (H×W×3) → (H*W × 3)
    [h, w, ~] = size(img);
    pixeles   = double(reshape(img, h*w, 3));
    
    % K-Means (K=3 suele funcionar bien: fondo, humo, fuego)
    [idx, centros] = kmeans(pixeles, K, ...
        'Distance',     'sqeuclidean', ...
        'Replicates',   5, ...
        'MaxIter',      200);
    
    etiquetas = reshape(idx, h, w);
    
    figure;
    subplot(1,2,1); imshow(img);           title('Original');
    subplot(1,2,2); imshow(etiquetas, []); title(sprintf('K-Means RGB  K=%d', K));
    colormap(jet);
end