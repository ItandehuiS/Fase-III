%% Programa para detectar rojo y amarillo en una imagen

% 1️⃣ Cargar imagen
img = imread('9.jpg'); % reemplaza 'tu_imagen.jpg' por tu archivo

% 2️⃣ Convertir de RGB a HSV
hsvImg = rgb2hsv(img);
H = hsvImg(:,:,1);  % canal de tono
S = hsvImg(:,:,2);  % canal de saturación
V = hsvImg(:,:,3);  % canal de brillo

% 3️⃣ Crear máscaras para rojo y amarillo
maskRed = ((H >= 0 & H <= 0.05) | (H >= 0.95 & H <= 1)) & (S > 0.5) & (V > 0.3);
maskYellow = (H >= 0.10 & H <= 0.17) & (S > 0.5) & (V > 0.3);

% 4️⃣ Aplicar máscaras a la imagen original
redPixels = img;
redPixels(repmat(~maskRed, [1 1 3])) = 0;    % deja solo rojo

yellowPixels = img;
yellowPixels(repmat(~maskYellow, [1 1 3])) = 0; % deja solo amarillo

% 5️⃣ Mostrar resultados 
figure;
subplot(1,3,1);
imshow(img);
title('Imagen Original');

subplot(1,3,2);
imshow(redPixels);
title('Píxeles Rojos');

subplot(1,3,3);
imshow(yellowPixels);
title('Píxeles Amarillos');