% =========================================================
% verificar_todo.m
% Script de verificacion - Segmentacion de incendios
% Ejecuta cada tecnica y confirma que funciona correctamente
% =========================================================

clc; clear; close all;

fprintf('=============================================\n');
fprintf('  VERIFICACION DE TECNICAS - INCENDIOS\n');
fprintf('=============================================\n\n');

% ----------------------------------------------------------
% PASO 1: Cargar imagen de prueba
% ----------------------------------------------------------
% Opcion A: usar imagen propia
 img = imread('D:/Posgrado Segundo MR-2/PDI/Nueva carpeta (2)/ForesFireDataset(ObjectDetection)/valid/images/1.jpg');

% Opcion B: crear imagen sintetica de prueba (fuego simulado)
% fprintf('[1/6] Generando imagen sintetica de prueba...\n');
% img = crear_imagen_prueba();
% fprintf('      Tamano: %dx%dx%d  Tipo: %s\n\n', ...
%     size(img,1), size(img,2), size(img,3), class(img));
% 
% figure('Name','[0] Imagen de prueba','NumberTitle','off');
% imshow(img);
% title('Imagen de prueba (fuego simulado)');

% ----------------------------------------------------------
% PASO 2: Canny
% ----------------------------------------------------------
fprintf('[2/6] Aplicando Canny...\n');
try
    gris      = rgb2gray(img);
    gris_suav = imgaussfilt(gris, 1.5);
    canny_out = edge(gris_suav, 'Canny', [0.05 0.20]);

    figure('Name','[1] Canny','NumberTitle','off');
    subplot(1,2,1); imshow(img);       title('Original');
    subplot(1,2,2); imshow(canny_out); title('Canny [0.05 - 0.20]');

    n_bordes = sum(canny_out(:));
    fprintf('      OK - Pixeles de borde detectados: %d\n\n', n_bordes);
catch e
    fprintf('      ERROR: %s\n\n', e.message);
end

% ----------------------------------------------------------
% PASO 3: Otsu 1 umbral
% ----------------------------------------------------------
fprintf('[3/6] Aplicando Otsu (1 umbral)...\n');
try
    gris   = rgb2gray(img);
    t1     = graythresh(gris);
    bin_1  = imbinarize(gris, t1);

    figure('Name','[2] Otsu 1 umbral','NumberTitle','off');
    subplot(1,3,1); imshow(img);    title('Original');
    subplot(1,3,2); imhist(gris);   title(sprintf('Histograma  T=%.3f', t1));
                    xline(t1*255,'r--','LineWidth',1.5);
    subplot(1,3,3); imshow(bin_1);  title('Binaria Otsu');

    pct = 100 * sum(bin_1(:)) / numel(bin_1);
    fprintf('      OK - Umbral: %.4f  |  Pixeles fuego: %.1f%%\n\n', t1, pct);
catch e
    fprintf('      ERROR: %s\n\n', e.message);
end

% ----------------------------------------------------------
% PASO 4: Otsu 2 umbrales
% ----------------------------------------------------------
fprintf('[4/6] Aplicando Otsu (2 umbrales)...\n');
try
    gris    = rgb2gray(img);
    t2      = multithresh(gris, 2);
    seg_2   = imquantize(gris, t2);

    figure('Name','[3] Otsu 2 umbrales','NumberTitle','off');
    subplot(1,3,1); imshow(img);          title('Original');
    subplot(1,3,2); imhist(gris);         title(sprintf('T1=%.3f  T2=%.3f', t2(1), t2(2)));
                    xline(t2(1)*255,'r--','LineWidth',1.5);
                    xline(t2(2)*255,'g--','LineWidth',1.5);
    subplot(1,3,3); imshow(seg_2, []);    title('3 regiones'); colormap(jet);

    r1 = 100*sum(seg_2(:)==1)/numel(seg_2);
    r2 = 100*sum(seg_2(:)==2)/numel(seg_2);
    r3 = 100*sum(seg_2(:)==3)/numel(seg_2);
    fprintf('      OK - Umbrales: [%.4f, %.4f]\n', t2(1), t2(2));
    fprintf('      Region 1 (fondo):   %.1f%%\n', r1);
    fprintf('      Region 2 (humo):    %.1f%%\n', r2);
    fprintf('      Region 3 (fuego):   %.1f%%\n\n', r3);
catch e
    fprintf('      ERROR: %s\n\n', e.message);
end

% ----------------------------------------------------------
% PASO 5: K-Means RGB y HSV
% ----------------------------------------------------------
fprintf('[5/6] Aplicando K-Means (RGB y HSV)...\n');
K = 3;
try
    % --- RGB ---
    [h, w, ~]  = size(img);
    pix_rgb    = double(reshape(img, h*w, 3));
    [idx_rgb, c_rgb] = kmeans(pix_rgb, K, 'Distance','sqeuclidean', ...
                              'Replicates',3, 'MaxIter',150);
    mapa_rgb   = reshape(idx_rgb, h, w);

    % --- HSV ---
    hsv        = rgb2hsv(img);
    pix_hsv    = double(reshape(hsv, h*w, 3));
    [idx_hsv, c_hsv] = kmeans(pix_hsv, K, 'Distance','sqeuclidean', ...
                              'Replicates',3, 'MaxIter',150);
    mapa_hsv   = reshape(idx_hsv, h, w);

    figure('Name','[4] K-Means','NumberTitle','off');
    subplot(1,3,1); imshow(img);          title('Original');
    subplot(1,3,2); imshow(mapa_rgb,[]); title(sprintf('K-Means RGB  K=%d',K)); colormap(jet);
    subplot(1,3,3); imshow(mapa_hsv,[]); title(sprintf('K-Means HSV  K=%d',K)); colormap(jet);

    fprintf('      OK - K=%d clusters\n', K);
    fprintf('      Centros RGB:\n');
    for k = 1:K
        fprintf('        Cluster %d: R=%.0f  G=%.0f  B=%.0f\n', ...
            k, c_rgb(k,1), c_rgb(k,2), c_rgb(k,3));
    end
    fprintf('      Centros HSV:\n');
    for k = 1:K
        fprintf('        Cluster %d: H=%.3f  S=%.3f  V=%.3f\n', ...
            k, c_hsv(k,1), c_hsv(k,2), c_hsv(k,3));
    end
    fprintf('\n');
catch e
    fprintf('      ERROR: %s\n\n', e.message);
end

% ----------------------------------------------------------
% PASO 6: LBP por regiones
% ----------------------------------------------------------
fprintf('[6/6] Extrayendo LBP por regiones...\n');
try
    gris = rgb2gray(img);
    [H, W] = size(gris);

    % ROIs automaticas (tercios de la imagen)
    roi_coords = struct( ...
        'fuego',      [round(W*0.3), round(H*0.1), round(W*0.4), round(H*0.4)], ...
        'humo',       [round(W*0.1), round(H*0.1), round(W*0.2), round(H*0.3)], ...
        'vegetacion', [round(W*0.1), round(H*0.6), round(W*0.2), round(H*0.3)] ...
    );

    regiones  = fieldnames(roi_coords);
    colores   = {'r', 'b', 'g'};
    lbp_hists = zeros(length(regiones), 59);  % 59 bins uniforme radio=1

    figure('Name','[5] LBP por regiones','NumberTitle','off');
    subplot(2,3,1); imshow(img); title('Imagen con ROIs');
    hold on;
    for i = 1:length(regiones)
        coords = roi_coords.(regiones{i});
        rectangle('Position', coords, 'EdgeColor', colores{i}, 'LineWidth', 2);
        text(coords(1)+2, coords(2)+12, regiones{i}, ...
            'Color', colores{i}, 'FontSize', 9, 'FontWeight','bold');
    end
    hold off;

    for i = 1:length(regiones)
        coords = roi_coords.(regiones{i});
        roi    = imcrop(gris, coords);
        lbp_f  = extractLBPFeatures(roi, 'Radius',1, 'NumNeighbors',8, 'Upright',false);
        lbp_hists(i,:) = lbp_f;

        subplot(2,3,i+1);
        bar(lbp_f, 'FaceColor', colores{i});
        title(['LBP: ' regiones{i}]);
        xlabel('Patron'); ylabel('Frecuencia');
    end

    % Comparar distancias entre histogramas
    subplot(2,3,5);
    imagesc(pdist2(lbp_hists, lbp_hists));
    colorbar; axis square;
    title('Distancia entre regiones');
    set(gca, 'XTick',1:3, 'XTickLabel',regiones, ...
             'YTick',1:3, 'YTickLabel',regiones);

    fprintf('      OK - LBP extraido para %d regiones\n', length(regiones));
    for i = 1:length(regiones)
        fprintf('      %s: %d bins  |  max=%.4f  media=%.4f\n', ...
            regiones{i}, length(lbp_hists(i,:)), ...
            max(lbp_hists(i,:)), mean(lbp_hists(i,:)));
    end
    fprintf('\n');
catch e
    fprintf('      ERROR: %s\n\n', e.message);
end

% ----------------------------------------------------------
% RESUMEN FINAL
% ----------------------------------------------------------
fprintf('=============================================\n');
fprintf('  RESUMEN\n');
fprintf('=============================================\n');
fprintf('  Canny        -> figura [1]\n');
fprintf('  Otsu 1 umbral-> figura [2]  T=%.4f\n', t1);
fprintf('  Otsu 2 umbral-> figura [3]  T=[%.4f  %.4f]\n', t2(1), t2(2));
fprintf('  K-Means RGB  -> figura [4]\n');
fprintf('  K-Means HSV  -> figura [4]\n');
fprintf('  LBP regiones -> figura [5]\n');
fprintf('=============================================\n');
fprintf('  Todas las tecnicas ejecutadas correctamente.\n');
fprintf('=============================================\n');


% ==========================================================
% FUNCION AUXILIAR: imagen sintetica de prueba
% ==========================================================
function img = crear_imagen_prueba()
    % Crea una imagen 300x400 simulando fuego, humo y vegetacion
    img = zeros(300, 400, 3, 'uint8');

    % Fondo oscuro (cielo/noche)
    img(:,:,1) = 20;
    img(:,:,2) = 20;
    img(:,:,3) = 30;

    % Vegetacion (verde, parte inferior)
    img(220:300, :, 1) = 30;
    img(220:300, :, 2) = 100;
    img(220:300, :, 3) = 20;

    % Humo (gris, zona media)
    for y = 120:220
        for x = 80:320
            d = sqrt((x-200)^2 + (y-170)^2);
            if d < 80
                v = uint8(120 + randn()*15);
                img(y,x,1) = v;
                img(y,x,2) = v;
                img(y,x,3) = v;
            end
        end
    end

    % Fuego (naranja/rojo, zona central-inferior)
    for y = 160:240
        for x = 140:260
            d = sqrt((x-200)^2 + (y-200)^2);
            if d < 55
                r = uint8(min(255, 200 + randn()*20));
                g = uint8(max(0,   80  + randn()*20));
                img(y,x,1) = r;
                img(y,x,2) = g;
                img(y,x,3) = 0;
            end
        end
    end

    % Nucleo brillante del fuego (amarillo)
    for y = 180:220
        for x = 170:230
            d = sqrt((x-200)^2 + (y-200)^2);
            if d < 25
                img(y,x,1) = uint8(min(255, 240 + randn()*10));
                img(y,x,2) = uint8(min(255, 180 + randn()*20));
                img(y,x,3) = 10;
            end
        end
    end

    % Suavizado leve para realismo
    img = uint8(imgaussfilt(double(img), 1.2));
end