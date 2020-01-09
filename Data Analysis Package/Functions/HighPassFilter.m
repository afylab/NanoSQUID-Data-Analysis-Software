function [FilteredImage] = HighPassFilter(DataX, DataY, Data, height)
[rows, cols] = size(Data);
dx = DataX(3, 2) - DataX(3, 1);
dy = DataY(5, 2) - DataY(4, 2);
dkx = 2 * pi / dx;
dky = 2 * pi / dy;
fftData = fftshift(fft2(Data));
KX = (linspace(0, cols - 1, cols) - ceil((cols - 1) / 2)) .* (dkx / cols);
KY = (linspace(0, rows - 1, rows) - ceil((rows - 1) / 2)) .* (dky / rows);
kz = 2 * pi / height;
[kx, ky] = meshgrid(KX, KY);
k = sqrt(kx .^ 2 + ky .^ 2);
flagMatrix = k > kz | k < -kz;
w = (1 + cos(k .* (height / 2))) .* 0.5 .* flagMatrix;
fftDataF = fftData .* w;
FilteredImage = ifft2(ifftshift(fftDataF));
end