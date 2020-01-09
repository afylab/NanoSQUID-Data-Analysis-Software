function [Magnetization] = NewMomentCalculatorWithPadding(BfieldX, BfieldY, Bfield, height)
[p, q] = size(Bfield);
rows = 3 * p;
cols = 3 * q;
dx = (BfieldX(3, 2) - BfieldX(3, 1)) * 5.36 * 10 ^ (-6);
dy = (BfieldY(5, 2) - BfieldY(4, 2)) * 5.36 * 10 ^ (-6);
% dx = (BfieldX(3, 2) - BfieldX(3, 1));
% dy = (BfieldY(5, 2) - BfieldY(4, 2));
dkx = 2 * pi / dx;
dky = 2 * pi / dy;
paddedBfield = zeros(rows, cols);
paddedBfield(p + 1 : 2 * p, q + 1 : 2 * q) = Bfield;
fftBfield = fftshift(fft2(paddedBfield)) / (rows * cols);
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
        sigma(m, n) = w(m, n) * fftBfield(m, n) / (miu * k * exp(-k * height) / 2);
    end
end

sigma(isnan(sigma)) = 0; %WHAT SHOULD IT BE?
M = (ifft2(ifftshift(sigma)) * (rows * cols));
Magnetization = M(p + 1 : 2 * p, q + 1 : 2 * q);
% I = ones(p, q);
% I(1:end,2:end-1)=0;
% MI = Magnetization.*I;
% edge = reshape(MI,1,[]);
% avg = sum(edge)/(2 * p);
% Magnetization = Magnetization - avg;
end