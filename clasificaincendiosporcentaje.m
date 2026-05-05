% ==========================================
% Clasificación automática de incendios en 4 carpetas
% ==========================================

% Carpeta con imágenes
imageFolder = 'D:\Posgrado Segundo MR-2\PDI\Nueva carpeta (2)\ForesFireDataset(ObjectDetection)\valid\images'; % reemplaza con tu carpeta
imageFiles = dir(fullfile(imageFolder, '*.jpg'));

% Crear carpetas de salida si no existen
outputFolders = {'Sin_incendio','Bajo','Moderado','Alto'};
for i = 1:length(outputFolders)
    outPath = fullfile(imageFolder, outputFolders{i});
    if ~exist(outPath,'dir')
        mkdir(outPath);
    end
end

% Recorrer cada imagen
for k = 1:numel(imageFiles)
    % Leer imagen
    imgPath = fullfile(imageFolder, imageFiles(k).name);
    img = imread(imgPath);
    
    % Convertir a HSV
    hsvImg = rgb2hsv(img);
    H = hsvImg(:,:,1);
    S = hsvImg(:,:,2);
    V = hsvImg(:,:,3);
    
    % Máscara para colores rojos, naranjas y amarillos
    mask_red = (H < 0.05 | H > 0.95) & (S > 0.5) & (V > 0.5);
    mask_yellow_orange = (H >= 0 & H < 0.15) & (S > 0.5) & (V > 0.5);
    mask_fire_color = mask_red | mask_yellow_orange;
    
    % Limpiar pequeñas regiones
    mask_clean = bwareaopen(mask_fire_color, 50);
    mask_clean = imclose(mask_clean, strel('disk',5));
    
    % Medir área
    stats = regionprops(mask_clean, 'Area');
    areas = [stats.Area];
    total_area = sum(areas);
    image_area = size(img,1)*size(img,2);
    percent_fire = total_area / image_area * 100;
    
    % Determinar carpeta según porcentaje
    if percent_fire <= 1.85
        folderName = 'Sin_incendio';
    elseif percent_fire <= 7
        folderName = 'Bajo';
    elseif percent_fire <= 15
        folderName = 'Moderado';
    else
        folderName = 'Alto';
    end
    
    % Copiar imagen a la carpeta correspondiente
    copyfile(imgPath, fullfile(imageFolder, folderName, imageFiles(k).name));
    
    % Mostrar progreso
    fprintf('%s -> %s (%.2f%% de incendio)\n', imageFiles(k).name, folderName, percent_fire);
end

disp('✅ Clasificación completada en 4 carpetas');