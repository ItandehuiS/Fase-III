function guardarResultados(original, segmentada, nombre_archivo)
    % guardarResultados: Guarda las imágenes segmentadas en archivos
    % Entrada: imágenes y nombre base para guardar
    
    % Construir nombres de archivo
    [path, name, ext] = fileparts(nombre_archivo);
    nombre_segmentada = fullfile(path, [name '_segmentada' ext]);
    
    % Guardar imagen segmentada
    imwrite(segmentada, nombre_segmentada);
    
    % Crear mosaico comparativo
    [filas, cols, ~] = size(original);
    mosaico = [original, segmentada];  % Concatenar horizontalmente
    
    nombre_mosaico = fullfile(path, [name '_comparacion' ext]);
    imwrite(mosaico, nombre_mosaico);
    
    fprintf('Resultados guardados:\n');
    fprintf('- Segmentada: %s\n', nombre_segmentada);
    fprintf('- Mosaico comparativo: %s\n', nombre_mosaico);
end