function imagen_final = generarImagenCLAHE(p1,p2,p3,p4,PARTE1,PARTE2,PARTE3,PARTE4)

%% Calcular CDF de cada histograma
cdf1 = cumsum(p1);
cdf1 = cdf1 / max(cdf1);
T1 = uint8(255 * cdf1);

cdf2 = cumsum(p2);
cdf2 = cdf2 / max(cdf2);
T2 = uint8(255 * cdf2);

cdf3 = cumsum(p3);
cdf3 = cdf3 / max(cdf3);
T3 = uint8(255 * cdf3);

cdf4 = cumsum(p4);
cdf4 = cdf4 / max(cdf4);
T4 = uint8(255 * cdf4);

%% Aplicar transformación a cada cuadrante
imagN1 = T1(double(PARTE1)+1);
imagN2 = T2(double(PARTE2)+1);
imagN3 = T3(double(PARTE3)+1);
imagN4 = T4(double(PARTE4)+1);

%% Unir las 4 imágenes
fila1 = [imagN1 imagN3];
fila2 = [imagN2 imagN4];

imagen_final = [fila1; fila2];

end