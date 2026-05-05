function [imagN,hisN] = EcualizacionF(img,L)

figure('Name','Imagen ');
%imshow(img);

%Dimensiones de la imagen
[M,N]=size(img);
nu_pix= M*N;

%histograma 
[nk1,rk1]=imhist(img);


%suma
tot1=sum(nk1);

%Vector para la normalizacion
pk = zeros(1, L); 

for i=1: L
   pk(i)=nk1(i)/nu_pix;
end

n = length(pk);
%Vector para la suma 
p = zeros(1, n); 
suma_actual = 0;
% Acumulados
for i = 1:n
   suma_actual = suma_actual + pk(i);
   p(i) = suma_actual;
end

s= zeros(1,L);
sr= zeros(1,L);

%Transformacion
for i=1:L
   s=p(i)*(L-1);
   sr(i)=round(s);
end

% Nueva imagen ecualizada
imagN = zeros(M,N,'uint8');

for i = 1:M
    for j = 1:N
        valor = img(i,j);
        imagN(i,j) = sr(valor+1);
    end
end

% Histograma de salida
hisN = imhist(imagN);

% --- Arriba izquierda: Imagen original ---
subplot(2,2,1);
imshow(img);
title('Imagen Original');

% --- Arriba derecha: Histograma original ---
subplot(2,2,2);
imhist(img);
title('Histograma Original');

% --- Abajo izquierda: Imagen ecualizada ---
subplot(2,2,3);
imshow(imagN);
title('Imagen Ecualizada');

% --- Abajo derecha: Histograma ecualizado ---
subplot(2,2,4);
imhist(imagN);
title('Histograma Ecualizado');


end

