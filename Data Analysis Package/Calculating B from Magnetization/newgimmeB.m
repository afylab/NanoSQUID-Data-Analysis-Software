function [Bfield] = newgimmeB(moments, inter_pixel_distance, d)
%gimmeB Calculates magnetic field above a uniformly magnetized 2D heterostructure.   
%   This function calculates the magnetic field in the region above a 2D
%   heterostructure.  It discretizes the magnetization density and then
%   computes the field contribution from each magnetic moment.  Variable
%   definitions: moments is the matrix of magnetic moment locations, it is
%   a Boolean matrix; inter_pixel_distance is the distance between pixels,
%   right now I haven't accounted for a non-unitary aspect ratio;
%   mag_density is the magnetic moment per unit area of the material, which
%   is something you'll have to calculate.  In the case of an exfoliated
%   magnetic insulator it will be fairly easy, just magnetic moments of the
%   atoms divided by the unit cell; d is the height of the tip above the
%   magnetic material (not the surface if there's a BN in the way); w is
%   the width of the window over which the calculation is done.  


[rows , cols]= size(moments); 
kx = zeros(rows, cols);
ky = zeros(rows, cols);
dk = (2 * pi) / inter_pixel_distance;
%moments = moments .* mag_density;
fftmoments = fftshift(fft2(moments)) / (rows * cols);
fftBfield = zeros(rows, cols);
miu = 4 * pi * 10 ^ (-7);
% magnetization_per_moment = mag_density / (inter_pixel_distance ^ 2);

for m = 1:cols
    kx(1 : rows, m) = (m - 1 - cols / 2) * dk / (cols - 1) ;
end
for n = 1:rows
    ky(n, 1 : cols) = (n - 1 - rows / 2) * dk / (rows - 1);
end


for i = 1 : rows
    for j = 1 : cols
        k = sqrt(kx(i, j) ^ 2 + ky(i, j) ^ 2);
        fftBfield(i, j) =  miu * k * exp(-k * d) * fftmoments(i, j) / 2;
    end
end
Bfield = real(ifft2(ifftshift(fftBfield)) * (rows * cols));

end

