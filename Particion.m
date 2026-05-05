close all;
clear;
clc;

%% Carpeta con imágenes
imageFolder = 'D:\Posgrado Segundo MR-2\PDI\Nueva carpeta (2)\ForesFireDataset(ObjectDetection)\valid\images\Moderado\Resultados_Herramienta'; % Cambia esto a la carpeta donde están tus imágenes
imageFiles = dir(fullfile(imageFolder, '*.jpg')); % todas las imágenes BMP

%% Recorrer todas las imágenes
for k = 1:numel(imageFiles)
    
    % Leer imagen
    im1 = imread(fullfile(imageFolder, imageFiles(k).name));
    figure; imshow(im1);
    
    [M,N] = size(im1);
    tam1 = floor(M/2);
    tam2 = floor(N/2);
    
    PARTE1 = im1(1:tam1, 1:tam2);
    PARTE2 = im1(tam1+1:M, 1:tam2);
    PARTE3 = im1(1:tam1, tam2+1:N);
    PARTE4 = im1(tam1+1:M, tam2+1:N);

    %L 256 porque son imágenes de 8 bits
    L = 256;

    % Retorno de la función la imagen y el histograma de la ecualizada
    [imagN1, hisN1] = EcualizacionF(PARTE1, L);
    [imagN2, hisN2] = EcualizacionF(PARTE2, L);
    [imagN3, hisN3] = EcualizacionF(PARTE3, L);
    [imagN4, hisN4] = EcualizacionF(PARTE4, L);

    % Obtener las frecuencias y las intensidades
    [freq1,r1] = imhist(imagN1);
    [freq2,r2] = imhist(imagN2);
    [freq3,r3] = imhist(imagN3);
    [freq4,r4] = imhist(imagN4);

    lim = 50;
    % 1. Recorte inicial
    p = min(freq4, lim);
    exceso = sum(max(freq4 - lim, 0));

    % 2. Reparto iterativo del exceso
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

    disp(['Exceso restante en ', imageFiles(k).name, ': ', num2str(exceso)]);

    figure
 
    subplot(2,2,1)
    bar(r1,p(1))
    title('Histograma Recortado Parte 1')
    xlabel('Nivel de gris')
    ylabel('Frecuencia')

    subplot(2,2,2)
    bar(r2,p(2))
    title('Histograma Recortado Parte 2')
    xlabel('Nivel de gris')
    ylabel('Frecuencia')

    subplot(2,2,3)
    bar(r3,p(3))
    title('Histograma Recortado Parte 3')
    xlabel('Nivel de gris')
    ylabel('Frecuencia')

    subplot(2,2,4)
    bar(r4,p(4))
    title('Histograma Recortado Parte 4')
    xlabel('Nivel de gris')
    ylabel('Frecuencia')
    
    imagen_final = generarImagenCLAHE(p(1),p(2),p(3),p(4),PARTE1,PARTE2,PARTE3,PARTE4);
    figure
    imshow(imagen_final)
    title('Imagen generada con los 4 histogramas recortados')
    
        
end