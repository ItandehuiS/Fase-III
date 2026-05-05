% =========================================================
% segmentacion_kmeans_lbp.m
% K-Means en HSV + LBP vectorizado para identificar regiones
% =========================================================
clear; clc; close all;

% ----------------------------------------------------------
% PASO 1: CARGAR IMAGEN
% ----------------------------------------------------------
imagen = imread('D:\Posgrado Segundo MR-2\PDI\Nueva carpeta (2)\ForesFireDataset(ObjectDetection)\valid\images\Sin_incendio\259_JPG.rf.096cb93255c0aa2f27a5dc146b71886c.jpg');
% Si quieres probar sin imagen real, comenta la línea anterior
% y descomenta esta:
% imagen = crear_imagen_prueba();

[filas, cols, ~] = size(imagen);
fprintf('Imagen cargada: %d x %d píxeles\n\n', filas, cols);

% ----------------------------------------------------------
% PASO 2: SEGMENTAR CON K-MEANS EN HSV
% ----------------------------------------------------------
etiquetas = segmentar_kmeans_hsv(imagen, 5);

% ----------------------------------------------------------
% PASO 3: CALCULAR LBP VECTORIZADO (rápido, sin bucles)
% ----------------------------------------------------------
fprintf('Calculando LBP vectorizado...\n');
imagen_gris = rgb2gray(imagen);
% lbp_img es una imagen donde cada píxel tiene su código LBP (0-255)
lbp_img = calcularLBP_vectorizado(imagen_gris);
fprintf('LBP calculado.\n\n');

% ----------------------------------------------------------
% PASO 4: CLASIFICAR CADA REGIÓN
% ----------------------------------------------------------
[nombres, info] = clasificar_regiones(imagen, etiquetas, lbp_img, 5);

% ----------------------------------------------------------
% PASO 5: VISUALIZAR RESULTADOS
% ----------------------------------------------------------
visualizar(imagen, etiquetas, nombres, info, 5);


% ==========================================================
% FUNCIÓN 1: segmentar_kmeans_hsv
% ----------------------------------------------------------
% Convierte la imagen a HSV y aplica K-Means.
% HSV es mejor que RGB porque el matiz (H) identifica
% colores cálidos (fuego) independientemente del brillo.
% ==========================================================
function etiquetas = segmentar_kmeans_hsv(imagen, k)
    [filas, cols, ~] = size(imagen);

    % Convertir a HSV: separa color (H), viveza (S) y brillo (V)
    hsv = rgb2hsv(imagen);

    % Aplanar a tabla de píxeles para kmeans
    pixeles = reshape(hsv, filas*cols, 3);

    fprintf('Aplicando K-Means (K=%d)...\n', k);
    [idx, ~] = kmeans(double(pixeles), k, ...
        'Distance',   'sqeuclidean', ...
        'Replicates', 3, ...
        'MaxIter',    200);

    % Devolver como imagen 2D de etiquetas
    etiquetas = reshape(idx, filas, cols);
    fprintf('K-Means completado.\n\n');
end


% ==========================================================
% FUNCIÓN 2: calcularLBP_vectorizado
% ----------------------------------------------------------
% Calcula el patrón binario local de TODA la imagen a la vez
% usando operaciones matriciales en lugar de bucles.
%
% ¿Por qué es más rápido?
%   El bucle original recorre cada píxel uno por uno (O(N²)).
%   La versión vectorizada opera sobre TODA la matriz de una vez.
%   Para una imagen de 500x500 = 250,000 píxeles,
%   el bucle tarda ~30 segundos; esta versión tarda <0.1 segundos.
%
% ¿Cómo funciona el LBP?
%   Para cada píxel central, compara sus 8 vecinos:
%   vecino >= centro → bit = 1
%   vecino <  centro → bit = 0
%   Los 8 bits forman un número binario (0-255) = código LBP
%
%   Posición de los 8 vecinos alrededor del centro:
%   [7][6][5]
%   [0][C][4]   ← C = centro
%   [1][2][3]
%
%   Peso binario de cada vecino: 2^0, 2^1, ..., 2^7
% ==========================================================
function lbp = calcularLBP_vectorizado(img)
    img = double(img);
    [h, w] = size(img);

    % Extraer los 8 vecinos desplazando la imagen completa
    % En lugar de "para cada píxel, mira sus vecinos",
    % hacemos "desplaza toda la imagen en cada dirección"
    %
    % Cada vecino se extrae con un desplazamiento diferente:
    %   img(1:h-2, 1:w-2) = desplazamiento arriba-izquierda
    %   img(1:h-2, 2:w-1) = desplazamiento arriba (mismo x)
    %   etc.
    %
    % La región válida es la zona interior sin bordes: [2:h-1, 2:w-1]
    C  = img(2:h-1, 2:w-1);          % Centro (región interior)

    % Los 8 vecinos en sentido horario empezando desde arriba-izquierda
    v1 = img(1:h-2, 1:w-2);          % vecino arriba-izquierda  → bit 0 → peso 1
    v2 = img(1:h-2, 2:w-1);          % vecino arriba            → bit 1 → peso 2
    v3 = img(1:h-2, 3:w);            % vecino arriba-derecha    → bit 2 → peso 4
    v4 = img(2:h-1, 3:w);            % vecino derecha           → bit 3 → peso 8
    v5 = img(3:h,   3:w);            % vecino abajo-derecha     → bit 4 → peso 16
    v6 = img(3:h,   2:w-1);          % vecino abajo             → bit 5 → peso 32
    v7 = img(3:h,   1:w-2);          % vecino abajo-izquierda   → bit 6 → peso 64
    v8 = img(2:h-1, 1:w-2);          % vecino izquierda         → bit 7 → peso 128

    % Comparar cada vecino con el centro (resultado: 0 o 1)
    % y multiplicar por el peso binario correspondiente
    % La suma acumula los bits activos → código LBP final
    interior = (v1>=C)*1   + (v2>=C)*2   + (v3>=C)*4   + (v4>=C)*8 + ...
               (v5>=C)*16  + (v6>=C)*32  + (v7>=C)*64  + (v8>=C)*128;

    % El resultado tiene tamaño (h-2) x (w-2) (sin los bordes)
    % Restauramos el tamaño original con zeros en el borde
    lbp = zeros(h, w);
    lbp(2:h-1, 2:w-1) = interior;
end


% ==========================================================
% FUNCIÓN 3: clasificar_regiones
% ----------------------------------------------------------
% Para cada región (cluster), calcula:
%   - Color promedio (desde HSV → RGB)
%   - Histograma LBP de la región
%   - Entropía del histograma LBP (medida de textura)
%   - Uniformidad (textura regular vs caótica)
%
% Con esos datos toma una decisión de clasificación más robusta
% que antes (no depende solo de umbrales de color).
% ==========================================================
function [nombres, info] = clasificar_regiones(imagen, etiquetas, lbp_img, k)
    imagen_hsv = rgb2hsv(imagen);
    [filas, cols] = size(etiquetas);
    total_px = filas * cols;

    nombres = cell(k, 1);
    info    = struct();

    fprintf('=== CLASIFICACIÓN AUTOMÁTICA POR REGIÓN ===\n\n');

    for r = 1:k
        mascara = (etiquetas == r);

        % --- Color promedio de la región en HSV y RGB ---
        H_vals = imagen_hsv(:,:,1);
        S_vals = imagen_hsv(:,:,2);
        V_vals = imagen_hsv(:,:,3);

        H_prom = mean(H_vals(mascara));  % matiz promedio (0-1)
        S_prom = mean(S_vals(mascara));  % saturación promedio (0-1)
        V_prom = mean(V_vals(mascara));  % brillo promedio (0-1)

        % Convertir a RGB para los umbrales (escala 0-255)
        rgb_prom = hsv2rgb([H_prom, S_prom, V_prom]) * 255;
        R = rgb_prom(1);
        G = rgb_prom(2);
        B = rgb_prom(3);

        % --- Análisis de textura LBP ---
        % Extraer los valores LBP solo de los píxeles de esta región
        lbp_vals = lbp_img(mascara);

        % Histograma de patrones LBP (256 posibles valores, 0-255)
        % El histograma describe QUÉ tipo de texturas hay en la región:
        %   - picos concentrados = textura uniforme (cielo, humo liso)
        %   - distribución plana = textura caótica (fuego, vegetación densa)
        hist_lbp = histcounts(lbp_vals, 0:256);
        hist_norm = hist_lbp / sum(hist_lbp);  % normalizar a probabilidades

        % ENTROPÍA: mide qué tan variada/caótica es la textura
        %   - entropía alta (>5) = textura muy irregular → fuego, vegetación
        %   - entropía baja (<3) = textura muy uniforme → cielo, humo liso
        %   Fórmula: -Σ p(x) * log2(p(x)) para todo x donde p(x)>0
        p = hist_norm(hist_norm > 0);      % solo probabilidades no-cero
        entropia = -sum(p .* log2(p));     % entropía de Shannon

        % UNIFORMIDAD: porcentaje de patrones LBP "uniformes"
        % Un patrón uniforme tiene máximo 2 transiciones 0→1 o 1→0
        % (bordes simples, esquinas). El fuego tiene muy pocos uniformes.
        % La vegetación y el cielo tienen muchos uniformes.
        patrones_uniformes = contar_patrones_uniformes(lbp_vals);
        uniformidad = 100 * patrones_uniformes / numel(lbp_vals);

        % --- Decisión de clasificación ---
        % Usa TANTO color (RGB) COMO textura (entropía, uniformidad)
        % para una clasificación más robusta
        nombre = clasificar_por_color_y_textura(R, G, B, H_prom, S_prom, V_prom, entropia, uniformidad);

        % Guardar información
        nombres{r} = nombre;
        info(r).R          = R;
        info(r).G          = G;
        info(r).B          = B;
        info(r).H          = H_prom;
        info(r).S          = S_prom;
        info(r).V          = V_prom;
        info(r).entropia   = entropia;
        info(r).uniformidad = uniformidad;
        info(r).porcentaje = 100 * sum(mascara(:)) / total_px;

        % Imprimir resumen
        fprintf('Región %d: %s\n', r, nombre);
        fprintf('   Color RGB:    R=%.0f  G=%.0f  B=%.0f\n', R, G, B);
        fprintf('   Color HSV:    H=%.3f  S=%.3f  V=%.3f\n', H_prom, S_prom, V_prom);
        fprintf('   Textura:      entropía=%.2f  uniformidad=%.1f%%\n', entropia, uniformidad);
        fprintf('   Tamaño:       %.1f%% de la imagen\n\n', info(r).porcentaje);
    end
end


% ==========================================================
% FUNCIÓN 4: clasificar_por_color_y_textura
% ----------------------------------------------------------
% Lógica de decisión usando color HSV + métricas de textura.
%
% Se usa HSV en lugar de RGB porque:
%   H (matiz): el fuego está en H=0.00-0.12 (rojo/naranja)
%              la vegetación en H=0.20-0.45 (verde)
%              el cielo en H=0.55-0.70 (azul)
%   S (saturación): el humo tiene S baja (gris = sin color)
%                   el fuego tiene S alta (color vívido)
%   V (valor/brillo): el fuego brillante tiene V alta
%                     el fondo nocturno tiene V muy baja
% ==========================================================
function nombre = clasificar_por_color_y_textura(R, G, B, H, S, V, entropia, uniformidad)
    % FUEGO/LAVA:
    %   Matiz cálido (H bajo = rojo/naranja)
    %   Saturación alta (S > 0.35, colores vívidos)
    %   Brillo visible (V > 0.30)
    %   Textura caótica (entropía alta, pocas uniformes)
    if H < 0.13 && S > 0.24 && V > 0.30 && entropia > 4.5
        nombre = 'FUEGO / LAVA';

    % TIERRA/ROCA OSCURA:
    %   Rojo moderado dominante, sin azul
    %   Textura variada (roca es irregular)
    elseif R > 100 && R > G && R > B && G < 120 && B < 80 && V < 0.55
        nombre = 'TIERRA / ROCA';

    % VEGETACIÓN:
    %   Matiz verde (H entre 0.20 y 0.50)
    %   Saturación moderada-alta
    %   Textura compleja (hojas tienen muchos bordes)
    elseif H > 0.20 && H < 0.50 && S > 0.15 && G > R && G > B
        nombre = 'VEGETACION';

    % CIELO DESPEJADO:
    %   Matiz azul (H entre 0.55 y 0.75)
    %   Saturación moderada
    %   Textura uniforme (el cielo es homogéneo)
    elseif H > 0.55 && H < 0.75 && S > 0.15 && B > R && entropia < 4.5
        nombre = 'CIELO';

    % HUMO:
    %   Saturación muy baja (gris, casi sin color)
    %   No muy oscuro (V > 0.25, no es noche)
    %   Textura moderada (el humo tiene algo de variación)
    elseif S < 0.20 && V > 0.25 && V < 0.88
        nombre = 'HUMO';

    % NUBES / ZONAS MUY BRILLANTES:
    %   Todos los canales altos → blanco
    %   Textura uniforme
    elseif R > 200 && G > 200 && B > 170 && entropia < 4.5
        nombre = 'NUBES / BRILLO';

    % FONDO OSCURO / NOCHE:
    %   Brillo muy bajo
    elseif V < 0.30
        nombre = 'FONDO OSCURO';

    % Si no encaja en ninguna categoría clara
    else
        nombre = sprintf('ZONA MIXTA (H=%.2f S=%.2f)', H, S);
    end
end


% ==========================================================
% FUNCIÓN 5: contar_patrones_uniformes
% ----------------------------------------------------------
% Cuenta cuántos valores LBP corresponden a patrones "uniformes".
% Un patrón uniforme tiene ≤2 transiciones binarias (0→1 o 1→0).
%
% ¿Para qué sirve?
%   Los patrones uniformes corresponden a estructuras simples:
%   bordes rectos, esquinas, puntos brillantes.
%   El fuego tiene POCOS patrones uniformes (textura caótica).
%   El cielo tiene MUCHOS (uniforme, casi sin textura).
% ==========================================================
function n = contar_patrones_uniformes(lbp_vals)
    n = 0;
    for v = lbp_vals(:)'
        % Convertir el valor LBP a cadena de 8 bits
        bits = dec2bin(v, 8) - '0';  % vector de 8 ceros y unos

        % Hacer la cadena circular (el bit 8 conecta con el bit 1)
        bits_circular = [bits, bits(1)];

        % Contar cuántas veces cambia el bit (0→1 o 1→0)
        transiciones = sum(abs(diff(bits_circular)));

        % Patrón uniforme: ≤ 2 transiciones
        if transiciones <= 2
            n = n + 1;
        end
    end
end


% ==========================================================
% FUNCIÓN 6: visualizar
% ----------------------------------------------------------
% Crea 3 paneles de visualización:
%   1) Imagen original
%   2) Mapa de regiones coloreado con nombres
%   3) Tabla de métricas de cada región
% ==========================================================
function visualizar(imagen, etiquetas, nombres, info, k)
    figure('Name', 'Segmentación con K-Means + LBP', ...
           'NumberTitle', 'off', 'Position', [50 50 1400 550]);

    % --- Panel 1: Imagen original ---
    subplot(1, 3, 1);
    imshow(imagen);
    title('Imagen original', 'FontSize', 12);

    % --- Panel 2: Mapa de regiones con etiquetas ---
    subplot(1, 3, 2);
    imshow(label2rgb(etiquetas, 'jet', 'k', 'shuffle'));
    % label2rgb convierte el mapa numérico (1..k) a colores RGB
    % 'jet' = paleta de colores
    % 'k'   = color negro para el fondo (label=0)
    % 'shuffle' = mezcla los colores para que regiones
    %             adyacentes no tengan colores parecidos
    hold on;

    % Poner el nombre de cada región en su centroide
    for r = 1:k
        mascara = (etiquetas == r);
        props = regionprops(mascara, 'Centroid', 'Area');

        if ~isempty(props)
            % Tomar la sub-región más grande si hay varias
            [~, idx_max] = max([props.Area]);
            cx = props(idx_max).Centroid(1);
            cy = props(idx_max).Centroid(2);

            % Texto compacto con número y nombre
            label_texto = sprintf('R%d\n%s', r, nombres{r});
            text(cx, cy, label_texto, ...
                'Color',           'white', ...
                'FontSize',        8, ...
                'FontWeight',      'bold', ...
                'HorizontalAlignment', 'center', ...
                'BackgroundColor', [0 0 0 0.5]);
                % [0 0 0 0.5] = negro semitransparente de fondo
        end
    end
    hold off;
    title('Regiones clasificadas', 'FontSize', 12);

    % --- Panel 3: Tabla de métricas ---
    subplot(1, 3, 3);
    axis off;  % ocultar ejes, solo mostrar texto

    % Encabezado
    y = 0.98;
    text(0.0, y, 'Región', 'FontSize', 9, 'FontWeight', 'bold', 'Units', 'normalized');
    text(0.28, y, 'Nombre',  'FontSize', 9, 'FontWeight', 'bold', 'Units', 'normalized');
    text(0.68, y, 'Entr.',   'FontSize', 9, 'FontWeight', 'bold', 'Units', 'normalized');
    text(0.82, y, 'Área%',   'FontSize', 9, 'FontWeight', 'bold', 'Units', 'normalized');

    % Línea separadora
    y = y - 0.04;
    text(0.0, y, repmat('─', 1, 42), 'FontSize', 7, 'Units', 'normalized', 'Color', [0.5 0.5 0.5]);

    % Filas de la tabla
    colores_tabla = lines(k);  % colores distintos para cada fila
    for r = 1:k
        y = y - 0.13;
        color_fila = colores_tabla(r,:);

        text(0.0,  y, sprintf('R%d', r),          'FontSize', 9, 'Units', 'normalized', 'Color', color_fila, 'FontWeight', 'bold');
        text(0.14, y, nombres{r},                  'FontSize', 8, 'Units', 'normalized', 'Color', color_fila);
        text(0.68, y, sprintf('%.2f', info(r).entropia),   'FontSize', 9, 'Units', 'normalized');
        text(0.82, y, sprintf('%.1f%%', info(r).porcentaje), 'FontSize', 9, 'Units', 'normalized');

        % Subtítulo con color HSV
        text(0.14, y-0.055, sprintf('H=%.2f S=%.2f V=%.2f', info(r).H, info(r).S, info(r).V), ...
            'FontSize', 7, 'Units', 'normalized', 'Color', [0.5 0.5 0.5]);
    end

    title('Métricas por región', 'FontSize', 12);

    sgtitle('K-Means HSV + LBP Vectorizado', 'FontSize', 14, 'FontWeight', 'bold');
end


% ==========================================================
% FUNCIÓN 7: crear_imagen_prueba (para probar sin foto real)
% ==========================================================
function img = crear_imagen_prueba()
    img = zeros(300, 450, 3, 'uint8');
    img(:,:,1) = 12; img(:,:,2) = 12; img(:,:,3) = 28;  % fondo noche

    % Vegetación
    img(230:300, 1:140, 1) = 25;
    img(230:300, 1:140, 2) = 105;
    img(230:300, 1:140, 3) = 18;

    % Humo
    for y = 70:180
        for x = 110:330
            if sqrt((x-220)^2+(y-125)^2) < 95
                v = uint8(125 + randn()*10);
                img(y,x,:) = v;
            end
        end
    end

    % Fuego
    for y = 155:275
        for x = 145:305
            if sqrt((x-225)^2+(y-215)^2) < 68
                img(y,x,1) = uint8(min(255, 210+randn()*12));
                img(y,x,2) = uint8(max(0,   65+randn()*12));
                img(y,x,3) = 0;
            end
        end
    end

    % Núcleo amarillo
    for y = 182:248
        for x = 178:272
            if sqrt((x-225)^2+(y-215)^2) < 32
                img(y,x,1) = uint8(min(255, 248+randn()*4));
                img(y,x,2) = uint8(min(255, 192+randn()*12));
                img(y,x,3) = 8;
            end
        end
    end

    img = uint8(imgaussfilt(double(img), 1.2));
end