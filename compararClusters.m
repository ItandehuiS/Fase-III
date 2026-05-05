function compararClusters(imagen)
    % compararClusters: Prueba diferentes valores de k y muestra resultados
    % Entrada: imagen original
    
    % Valores de k a probar
    valores_k = [2, 3, 5, 8, 10];
    
    % Crear figura con múltiples subplots
    figure('Name', 'Comparación de diferentes K', 'NumberTitle', 'off');
    num_plots = length(valores_k) + 1;
    
    % Mostrar original
    subplot(2, 3, 1);
    imshow(imagen);
    title('Original');
    
    % Para cada k, segmentar y mostrar
    for i = 1:length(valores_k)
        k = valores_k(i);
        segmentada = aplicarKMeans(imagen, k);
        
        subplot(2, 3, i+1);
        imshow(segmentada);
        title(sprintf('K = %d clusters', k));
    end
    
    set(gcf, 'Position', [50, 50, 1500, 800]);
    
    % Explicación interactiva
    fprintf('\n--- EFECTO DEL NÚMERO DE CLUSTERS (K) ---\n');
    fprintf('• K pequeño (2-3): Segmentación gruesa, pocas regiones\n');
    fprintf('• K mediano (5-8): Buen equilibrio detalle/regiones\n');
    fprintf('• K grande (10+): Segmentación fina, casi cada color único\n');
end