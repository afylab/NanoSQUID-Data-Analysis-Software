function [A] = Plot_nSOT_Mag_Linecut( data_num)
%PLOTME2D Summary of this function goes here
%   Detailed explanation goes here

if isa(data_num,'double')
    ZurichGain = 10000; %Gain on the Zurich
    SRGain = 10; %Gain on the SR preamp
    squidSlope = 40; %Sensitivity of SQUID in volts / tesla
    unit = 1e9; %Desired unit in tesla. 1e6 is uT, 1e9 is nT

    dataset = OpenDataVaultFile(data_num);

    trace = dataset(dataset(:,1) ==0,:);
    retrace = dataset(dataset(:,1) ==1,:);

    l= max(dataset(:,2))+1;

    Axis1 = reshape(trace(:,4),l,[]);
    Axis2 = reshape(trace(:,5),l,[]);
    Axis3 = reshape((trace(:,9)+retrace(:,9))./2,l,[]);

    %1.1 volts to 5.9 microns for x
    %Assuming same for y 

    x = Axis1.*5.333;
    y = Axis2.*5.333;
    z = Axis3.*unit./(ZurichGain*SRGain*squidSlope);
    %z = filter(gausswin(41)./sum(gausswin(41)), 1, z);
    z = z- mean(mean(z));
    % For some reason, not having the grid specified for pcolor makes weird
    % artifacts. To be investigated, but for now just use pcolor
    x = [x(1,end) x(end,end)];
    %y is flipped because imagesc by default has weird non cartesian
    %coordinates
    y = [y(end,end) y(end,1)];
end

if isa(data_num, 'struct')
    x = data_num.x;
    y = data_num.y;
    z = data_num.z;
end

num_points = length(z(:,1));

pos = linspace(0, sqrt((x(2)-x(1))^2 + (y(2) - y(1))^2), num_points);

plot(pos, z(:,1));

A.x = x;
A.y = y;
A.z = z;

end

