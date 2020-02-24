function [B] = TFDomainWallSignal(x, d, A, theta, phi, z, s, a)
%TFDOMAINWALLSIGNAL Summary of this function goes here
%   x - position relative to the wall edge (0 being on the edge) in nm
%   d - squid diameter
%   A - TF peak to peak amplitude
%   theta - oscillation angle relative to domain wall in radians
%   phi - linecut angle relative to domain wall in radians
%   z - squid height
%   s - moments per unit cell
%   a - unit cell area in nm^2
%   B - output magnetic field in units of nT

fun = @(x, d, z, s, a, t)DCDomainWallSignalApprox(x.*cos(phi) + A.*cos(theta).*sin(t)./2, d, z, s, a).*sin(t)/pi;

dims = size(x);
B = zeros(dims);

for i = 1:dims(1)
    for j = 1:dims(2)
        B(i,j) = integral(@(t)fun(x(i,j), d, z, s, a, t), -pi, pi);
    end
end
end

