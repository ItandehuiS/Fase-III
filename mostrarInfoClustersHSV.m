function mostrarInfoClustersHSV(etiquetas, centroides, k)
    % Muestra información interpretable de los clusters en HSV
    
    fprintf('\n========================================\n');
    fprintf('📊 INFORMACIÓN DE CLUSTERS (ESPACIO HSV)\n');
    fprintf('========================================\n');
    
    nombres_colores = {'Rojo', 'Naranja', 'Amarillo', 'Verde', 'Cian', ...
                       'Azul', 'Morado', 'Rosa', 'Marrón', 'Gris', 'Blanco', 'Negro'};
    
    for i = 1:k
        num_pixeles = sum(etiquetas == i);
        porcentaje = (num_pixeles / length(etiquetas)) * 100;
        
        % Convertir HUE (0-1) a grados (0-360) y a nombre de color
        hue_grados = centroides(i, 1) * 360;
        sat = centroides(i, 2);
        val = centroides(i, 3);
        
        % Determinar nombre del color según HUE
        if sat < 0.1
            nombre_color = 'Gris/Blanco/Negro';
        elseif val < 0.1
            nombre_color = 'Negro';
        else
            if hue_grados < 15 || hue_grados >= 345
                nombre_color = 'Rojo';
            elseif hue_grados < 45
                nombre_color = 'Naranja';
            elseif hue_grados < 75
                nombre_color = 'Amarillo';
            elseif hue_grados < 165
                nombre_color = 'Verde';
            elseif hue_grados < 195
                nombre_color = 'Cian';
            elseif hue_grados < 255
                nombre_color = 'Azul';
            elseif hue_grados < 315
                nombre_color = 'Morado';
            else
                nombre_color = 'Rojo/Magenta';
            end
        end
        
        fprintf('\n🔴 CLUSTER %d:\n', i);
        fprintf('   🎨 Color dominante: %s\n', nombre_color);
        fprintf('   📐 HUE: %.1f° (%.3f en 0-1)\n', hue_grados, centroides(i,1));
        fprintf('   💧 Saturación: %.2f (0=grise, 1=vivo)\n', centroides(i,2));
        fprintf('   💡 Valor/Brillo: %.2f (0=oscuro, 1=brillante)\n', centroides(i,3));
        fprintf('   📍 Píxeles: %d (%.1f%% de la imagen)\n', num_pixeles, porcentaje);
    end
    
    fprintf('\n💡 INTERPRETACIÓN:\n');
    fprintf('   • HUE (0-360°): El color puro (rojo=0°, verde=120°, azul=240°)\n');
    fprintf('   • SATURACIÓN: Pureza del color (0=gris, 1=color puro)\n');
    fprintf('   • VALUE: Brillo/Intensidad (0=negro, 1=blanco)\n');
end