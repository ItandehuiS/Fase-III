function [img_seg, umbrales] = otsu_dos_umbrales(img)
    gris = rgb2gray(img);
    
    % multithresh genera N-1 umbrales para N clases
    umbrales = multithresh(gris, 2);    % 2 umbrales → 3 regiones
    img_seg  = imquantize(gris, umbrales);
    
    fprintf('Umbrales Otsu: %.4f  %.4f\n', umbrales(1), umbrales(2));
    
    figure;
    subplot(1,2,1); imshow(img);         title('Original');
    subplot(1,2,2); imshow(img_seg, []); title('Otsu 2 umbrales (3 regiones)');
    colormap(jet);
end