function visualizarResultados(original, segmentada, k)
    % visualizarResultados: Muestra comparativa de imágenes original vs segmentada
    % Entrada: imagen original, imagen segmentada, número de clusters
    
    % Crear figura con subplots
    figure('Name', sprintf('Segmentación K-Means (k=%d)', k), 'NumberTitle', 'off');
    
    % Subplot 1: Imagen original
    subplot(1, 2, 1);
    imshow(original);  % imshow muestra imagen (uint8)
    title(sprintf('Imagen Original\n(%d x %d)', size(original,1), size(original,2)));
    
    % Subplot 2: Imagen segmentada
    subplot(1, 2, 2);
    imshow(segmentada);
    title(sprintf('Imagen Segmentada (K=%d clusters)\nCada región con color promedio', k));
    
    % Ajustar layout
    set(gcf, 'Position', [100, 100, 1200, 500]);
    
    % Mostrar información estadística
    disp('========================================');
    disp('RESUMEN DE SEGMENTACIÓN:');
    disp('========================================');
    fprintf('Número de clusters (regiones): %d\n', k);
    fprintf('Dimensión de trabajo: Espacio RGB (rojo, verde, azul)\n');
    fprintf('Cada píxel es un punto con coordenadas (R,G,B)\n');
    fprintf('K-Means agrupa píxeles con colores similares\n');
    
end