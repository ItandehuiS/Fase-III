info = imfinfo('1.jpg');
bitDepth = info.BitDepth;   % bits por píxel o por canal
L = 2^bitDepth;             % número de niveles