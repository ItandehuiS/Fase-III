close all;
clear;
clc;

%% Carpeta con imágenes
imageFolder = 'D:\Posgrado Segundo MR-2\PDI\Nueva carpeta (2)\ForesFireDataset(ObjectDetection)\valid\images\Moderado\Resultados_Herramienta';
imageFiles = dir(fullfile(imageFolder, '*.jpg'));

%% Parámetros
L = 256;    % niveles de gris
lim = 50;   % límite para recorte de histograma

%% Función de recorte de histograma
recorteHist = @(freq,lim) recortar(freq,lim);

%% Recorrer todas las imágenes
for k = 1:numel(imageFiles)
    
    % Leer imagen
    im1 = imread(fullfile(imageFolder, imageFiles(k).name));
    
    % Convertir a gris si es RGB
    if size(im1,3)==3
        im1 = rgb2gray(im1);
    end
    
    figure; imshow(im1); title(['Imagen Original: ', imageFiles(k).name]);
    
    [M,N] = size(im1);
    tam1 = floor(M/2);
    tam2 = floor(N/2);
    
    % Dividir imagen en 4 partes
    PARTE1 = im1(1:tam1, 1:tam2);
    PARTE2 = im1(tam1+1:M, 1:tam2);
    PARTE3 = im1(1:tam1, tam2+1:N);
    PARTE4 = im1(tam1+1:M, tam2+1:N);
    
    % Ecualizar cada parte
    [imagN1, ~] = EcualizacionF(PARTE1, L);
    [imagN2, ~] = EcualizacionF(PARTE2, L);
    [imagN3, ~] = EcualizacionF(PARTE3, L);
    [imagN4, ~] = EcualizacionF(PARTE4, L);
    
    % Histogramas de cada parte
    [freq1,r1] = imhist(imagN1);
    [freq2,r2] = imhist(imagN2);
    [freq3,r3] = imhist(imagN3);
    [freq4,r4] = imhist(imagN4);
    
    % Recortar histogramas de cada parte
    p1 = recorteHist(freq1, lim);
    p2 = recorteHist(freq2, lim);
    p3 = recorteHist(freq3, lim);
    p4 = recorteHist(freq4, lim);
    
    % ======== HISTOGRAMA GLOBAL ========
    % Histograma global de los 4 cuadrantes
    hist_global = freq1 + freq2 + freq3 + freq4;

    % Recorte
    p_global = min(hist_global, lim);

    % CDF global
    cdf_global = cumsum(p_global);
    cdf_global = cdf_global / max(cdf_global); % normaliza a [0,1]

    % Transformación a 0-255
    T_global = uint8(255 * cdf_global);

    % Aplicar a cada cuadrante asegurando índices correctos
    imagN1 = T_global(double(PARTE1)+1);
    imagN2 = T_global(double(PARTE2)+1);
    imagN3 = T_global(double(PARTE3)+1);
    imagN4 = T_global(double(PARTE4)+1);

    % Unir cuadrantes
    fila1 = [imagN1 imagN3];
    fila2 = [imagN2 imagN4];
    imagen_final = [fila1; fila2];
    % ===== Mostrar los histogramas recortados de cada parte =====
%     figure
%     subplot(2,2,1)
%     bar(r1,p1)
%     title('Histograma Recortado Parte 1')
%     xlabel('Nivel de gris')
%     ylabel('Frecuencia')
% 
%     subplot(2,2,2)
%     bar(r2,p2)
%     title('Histograma Recortado Parte 2')
%     xlabel('Nivel de gris')
%     ylabel('Frecuencia')
% 
%     subplot(2,2,3)
%     bar(r3,p3)
%     title('Histograma Recortado Parte 3')
%     xlabel('Nivel de gris')
%     ylabel('Frecuencia')
% 
%     subplot(2,2,4)
%     bar(r4,p4)
%     title('Histograma Recortado Parte 4')
%     xlabel('Nivel de gris')
%     ylabel('Frecuencia')
%     
    % ===== Mostrar imagen final =====
    
    figure
    imshow(imagen_final)
    title(['Imagen con histograma global recortado: ', imageFiles(k).name])
    
end

%% ===== Función para recortar un histograma =====
function p = recortar(freq, lim)
    p = min(freq, lim);
    exceso = sum(max(freq - lim, 0));

    while exceso > 0
        libres = find(p < lim);
        if isempty(libres)
            break;
        end
        incremento = floor(exceso / length(libres));
        if incremento == 0
            incremento = 1;
        end
        for i = 1:length(libres)
            idx = libres(i);
            espacio = lim - p(idx);
            suma = min(incremento, espacio);
            p(idx) = p(idx) + suma;
            exceso = exceso - suma;
            if exceso == 0
                break;
            end
        end
    end
end