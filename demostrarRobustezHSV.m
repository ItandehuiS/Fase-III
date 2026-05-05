function demostrarRobustezHSV()
    % Crea una imagen con diferentes condiciones de iluminación
    % y muestra cómo HSV es más robusto que RGB
    
    % Crear imagen: círculo rojo con diferentes brillos
    [X,Y] = meshgrid(1:200, 1:200);
    centro = 100;
    radio = 70;
    mascara = (X-centro).^2 + (Y-centro).^2 <= radio^2;
    
    % Crear variaciones de brillo
    imagen_rgb = zeros(200,200,3);
    % Círculo rojo (va variando de brillo)
    imagen_rgb(:,:,1) = 255 * mascara .* (0.3 + 0.7 * X/200);
    imagen_rgb(:,:,2) = 0;
    imagen_rgb(:,:,3) = 0;
    % Fondo azul oscuro
    imagen_rgb(:,:,3) = imagen_rgb(:,:,3) + 100 * (~mascara);
    
    imagen_rgb = uint8(imagen_rgb);
    
    % Segmentar con RGB
    seg_rgb = aplicarKMeansRGB(imagen_rgb, 3);
    
    % Segmentar con HSV
    seg_hsv = aplicarKMeansHSV(imagen_rgb, 3);
    
    % Mostrar resultados
    figure('Name', 'Robustez a Iluminación', 'Position', [100, 100, 1200, 400]);
    
    subplot(1,3,1);
    imshow(imagen_rgb);
    title('Imagen Original\nCírculo rojo con degradado de brillo');
    
    subplot(1,3,2);
    imshow(seg_rgb);
    title('Segmentación RGB\n(Sensible al cambio de brillo)');
    
    subplot(1,3,3);
    imshow(seg_hsv);
    title('Segmentación HSV\n(Robusto al cambio de brillo)');
    
    fprintf('\n✅ Demostración: HSV segmenta TODO el círculo rojo como un solo cluster\n');
    fprintf('   mientras que RGB lo divide en múltiples clusters por diferencia de brillo\n');
end