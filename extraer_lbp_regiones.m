function histogramas = extraer_lbp_regiones(img, roi_coords)
    % roi_coords: struct con campos fuego, humo, vegetacion
    % Cada campo: [x, y, ancho, alto]
    
    gris = rgb2gray(img);
    
    regiones = {'fuego', 'humo', 'vegetacion'};
    histogramas = struct();
    
    for i = 1:length(regiones)
        nombre = regiones{i};
        coords = roi_coords.(nombre);    % [x y w h]
        
        % Recortar región de interés
        roi = imcrop(gris, coords);
        
        % Extraer LBP: radio y vecinos ajustables
        % Radio pequeño (1) captura textura fina; radio mayor (2-3) captura patrones más grandes
        lbp_feat = extractLBPFeatures(roi, ...
            'Radius',        2, ...
            'NumNeighbors',  8, ...
            'Upright',       false);
        
        histogramas.(nombre) = lbp_feat;
        
        % Visualizar región y su histograma LBP
        figure('Name', ['LBP - ' nombre]);
        subplot(1,2,1); imshow(roi);         title(['ROI: ' nombre]);
        subplot(1,2,2); bar(lbp_feat);       title('Histograma LBP');
        xlabel('Patrón'); ylabel('Frecuencia');
    end
end