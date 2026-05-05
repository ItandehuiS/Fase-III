function resultado = aplicar_canny(img, umbral_bajo, umbral_alto)
    % Convertir a escala de grises
    if size(img, 3) == 3
        gris = rgb2gray(img);
    else
        gris = img;
    end
    
    % Suavizado previo con Gaussiano
    gris_suav = imgaussfilt(gris, 1.5);
    
    % Canny con umbrales ajustables
    % umbral_bajo ~ 0.05-0.1, umbral_alto ~ 0.15-0.3 para fuego
    resultado = edge(gris_suav, 'Canny', [umbral_bajo umbral_alto]);
    
    % Visualizar
    figure;
    subplot(1,2,1); imshow(img); title('Original');
    subplot(1,2,2); imshow(resultado); title('Canny');
end