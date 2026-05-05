% main_analisis.m
categorias = {'Sin_incendio','Bajo', 'Moderado', 'Alto'};
resultados = table();

for c = 1:length(categorias)
    carpeta = fullfile('imagenes', categorias{c});
    archivos = dir(fullfile(carpeta, '*.jpg'));
    
    for f = 1:length(archivos)
        img = imread(fullfile(carpeta, archivos(f).name));
        
        % Aplicar cada técnica
        r_canny = aplicar_canny(img, 0.05, 0.15);
        [~, t1]  = otsu_un_umbral(img);
        [~, t2]  = otsu_dos_umbrales(img);
        [~, c_rgb] = kmeans_rgb(img, 3);
        [~, c_hsv] = kmeans_hsv(img, 3);
        
        % Agregar fila a tabla
        fila = {categorias{c}, archivos(f).name, t1, t2(1), t2(2)};
        resultados = [resultados; fila];
    end
end

writetable(resultados, 'tabla_comparativa.csv');
disp(resultados);