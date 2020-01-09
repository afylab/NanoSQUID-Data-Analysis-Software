function [Magnetization] = NewMomentCalculator(BfieldX, BfieldY, Bfield, height)
[rows, cols] = size(Bfield);
dx = BfieldX(3, 2) - BfieldX(3, 1);
dy = BfieldY(5, 2) - BfieldY(4, 2);
dkx = 2 * pi / dx;
dky = 2 * pi / dy;
fftBfield = fftshift(fft2(Bfield)) / (rows * cols);
kx = zeros(rows, cols);
ky = zeros(rows, cols);
w = zeros(rows, cols);
kz = 2 * pi / height;
sigma = zeros(rows, cols);
miu = 4 * pi * 10 ^ (-7);


for m = 1:cols
    kx(1 : rows, m) = (m - 1 - cols / 2) * dkx / (cols - 1);
end
for n = 1:rows
    ky(n, 1 : cols) = (n - 1 - rows / 2) * dky / (rows - 1);
end


for m = 1 : rows
    for n = 1 : cols
        k = sqrt(kx(m, n) ^ 2 + ky(m, n) ^ 2);
        if k < kz && k > 0
            w(m, n) = (1 + cos(k * height / 2)) * 0.5;
        else
            w(m, n) = 0;
        end
%         w = ones(rows, cols);
        sigma(m, n) = w(m, n) * fftBfield(m, n) / (miu * k * exp(-k * height) / 2);
    end
end
sigma(isnan(sigma)) = 0; %WHAT SHOULD IT BE?
Magnetization = real(ifft2(ifftshift(sigma)) * (rows * cols));
% avg = (mean(Magnetization(:, end)) + mean(Magnetization(:, 1)))/2;
% Magnetization = Magnetization - avg;
end