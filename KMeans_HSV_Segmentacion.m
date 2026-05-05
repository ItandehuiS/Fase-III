function KMeans_HSV_Segmentacion()
    % ============================================
    % K-MEANS SEGMENTACIÓN USANDO ESPACIO HSV
    % ============================================
    % HSV = Hue (Matiz), Saturation (Saturación), Value (Valor/Intensidad)
    % Ventaja: Separa el color real de la iluminación
    
    clear; clc; close all;
    
    % Cargar imagen
    nombre_imagen = 'imagen_ejemplo.jpg';
    if exist(nombre_imagen, 'file')
        imagen_rgb = imread(nombre_imagen);
    else
        [X,Y] = meshgrid(1:300,1:200);
        imagen_rgb = uint8(cat(3, X/300*255, Y/200*255, (X+Y)/500*255));
        imwrite(imagen_rgb, nombre_imagen);
        fprintf('Imagen de prueba creada\n');
    end
    
    fprintf('=== SEGMENTACIÓN CON K-MEANS EN ESPACIO HSV ===\n');
    fprintf('H (Hue): 0-360° (color puro)\n');
    fprintf('S (Saturation): 0-1 (intensidad del color)\n');
    fprintf('V (Value): 0-1 (brillo/luminosidad)\n\n');
    
    % Segmentar con diferentes valores de K
    valores_k = [3, 5, 8];
    
    for k = valores_k
        fprintf('Segmentando con K = %d clusters...\n', k);
        imagen_segmentada = aplicarKMeansHSV(imagen_rgb, k);
        visualizarComparacionHSV(imagen_rgb, imagen_segmentada, k);
    end
    
    % Segmentación interactiva
    k_elegido = 5;
    [imagen_hsv, imagen_segmentada, etiquetas, centroides] = aplicarKMeansHSV_Detallado(imagen_rgb, k_elegido);
    mostrarInfoClustersHSV(etiquetas, centroides, k_elegido);
    
    fprintf('\n✅ PROCESO COMPLETADO\n');
end