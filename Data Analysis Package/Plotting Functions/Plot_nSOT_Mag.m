function [A] = Plot_nSOT_Mag(data_num)
%PLOTME2D Summary of this function goes here
%   Detailed explanation goes here

if isa(data_num,'double')
    ZurichGain = 50000; %Gain on the Zurich
    SRGain = 1; %Gain on the SR preamp
    squidSlope = -34.7; %Sensitivity of SQUID in volts / tesla
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
    
    %x = x(:,26:93);
    %y = y(:,26:93);
    %z = z(:,26:93);
    
    winsize = 31;
    %H = [gausswin(winsize) , gausswin(winsize) , gausswin(winsize)];
    %H = H./sum(sum(H));
    H = [1];
    z = filter2(H,z);
    %z = z- mean(mean(z(3:53, 86:96)));
    z = z- mean(mean(z));
    
    x = x(50:end-50,2:end-1);
    y = y(50:end-50,2:end-1);
    z = z(50:end-50,2:end-1);
    
    A.X = x;
    A.Y = y;
    
    x = [0 ((A.X(end,1)-A.X(1,1))^2+(A.Y(end,1)-A.Y(1,1))^2)^(1/2)];
    %y is flipped because imagesc by default has weird non cartesan
    %coordinates
    y = [((A.X(1,end)-A.X(1,1))^2+(A.Y(1,end)-A.Y(1,1))^2)^(1/2) 0];
end

if isa(data_num, 'struct')
    x = data_num.x;
    y = data_num.y;
    z = data_num.z;
end

imagesc(x, y, z'); shading flat; hold on
colormap(redblue(500))
caxis([-170,170])
axis off; 

h = colorbar;
ylabel(h,'B_{TF} (nT)');
set(gca, 'Layer', 'Top')

aspect = [(x(2)-x(1)) y(1)-y(2) 1];
pbaspect(aspect);

%Length of the scale bar in unit of the specified x axis / y axis. 
%In this case this is in microns
scalebar_length = 0.5;
quiver(x(end)- scalebar_length*1.5, y(1) - scalebar_length*0.25, scalebar_length, 0 ,'ShowArrowHead','off', 'linewidth',3, 'color', [0,0,0])
hold off

A.x = x;
A.y = y;
A.z = z;

end

