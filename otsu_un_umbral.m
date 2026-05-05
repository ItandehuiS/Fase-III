function [bin, umbral] = otsu_un_umbral(img)
    gris = rgb2gray(img);
    umbral = graythresh(gris);          % Calcula umbral óptimo de Otsu
    bin   = imbinarize(gris, umbral);   % Aplica el umbral
    
    fprintf('Umbral Otsu: %.4f\n', umbral);
    
    figure;
    subplot(1,3,1); imshow(img);        title('Original');
    subplot(1,3,2); imhist(gris);       title(sprintf('Histograma (T=%.2f)', umbral));
    subplot(1,3,3); imshow(bin);        title('Otsu 1 umbral');
end