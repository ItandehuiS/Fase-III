%% Clasificación de incendios por la región más grande

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

% Umbrales según área de la región más grande (en pixeles)
th_low = 500;      % Bajo
th_moderate = 2000; % Moderado
th_high = 5000;    % Alto

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
    
    % Limpiar pequeñas regiones (apertura y cierre)
    mask_clean = bwareaopen(mask_fire_color, 30);
    mask_clean = imclose(mask_clean, strel('disk',5))%Disco de 5 px como elemento estructurante
    
    % Medir áreas de regiones
    stats = regionprops(mask_clean, 'Area');
    areas = [stats.Area];
    %disp(areas)
    
    % Determinar la región más grande
    if isempty(areas)
        max_area = 0;
    else
        max_area = max(areas);
    end

    % Clasificar según el área de la región más grande
    if max_area <= th_low
        folderName = 'Sin_incendio';
    elseif max_area <= th_moderate
        folderName = 'Bajo';
    elseif max_area <= th_high
        folderName = 'Moderado';
    else
        folderName = 'Alto';
    end
    
    % Copiar imagen a la carpeta correspondiente
    copyfile(imgPath, fullfile(imageFolder, folderName, imageFiles(k).name));
    
    % Mostrar progreso
    fprintf('%s -> %s (Área mayor: %d px)\n', imageFiles(k).name, folderName, max_area);
end

disp('Clasificación completada según la región más grande');