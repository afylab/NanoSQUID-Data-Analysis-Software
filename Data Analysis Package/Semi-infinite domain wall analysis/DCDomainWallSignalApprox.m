function [B] = DCDomainWallSignalApprox(x, d, h, s, a)
%TFDOMAINWALLSIGNAL This function uses an analytical formula for the
%convolution with the SQUID, where the SQUID is approximated as two
%parabolas instead of a circle. This makes the computation much faster.
%Formula taken from Andrea's wiresim2.nb mathematica filel. 
%   x - position relative to the wall edge (0 being on the edge) in nm
%   d - squid diameter in nm
%   h - squid height in nm
%   s - moments per unit cell
%   a - unit cell area in nm^2
%   B - output magnetic field in units of nT

B = ((3709600*pi*s)/a)*(3*(4.*x.*(d + 2*h*atan((-(d/2) + x)/h) - 2*h*atan((d/2 + x)/h)) + (d^2 + 4*h^2 - 4*x.^2).*atanh((4*d*x)./(d^2 + 4*(h^2 + x.^2)))))./(4*d^3*pi);

end

