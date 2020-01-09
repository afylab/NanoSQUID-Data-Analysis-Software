function [A] = TFScanDataProcessor( data_num)
%PLOTME2D Summary of this function goes here
%   Detailed explanation goes here


if isa(data_num,'double')
    ZurichGain = 10000; %Gain on the Zurich
    SRGain = 10; %Gain on the SR preamp
    squidSlope = 29.7; %Sensitivity of SQUID in volts / tesla
    unit = 1e9; %Desired unit in tesla. 1e6 is uT, 1e9 is nT
    TF_Amp = 162; %In nm
    GaussFilter = 11; 

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
    z = Axis3.*unit./(ZurichGain*SRGain*squidSlope*TF_Amp);
    
    %x = x(:,26:93);
    %y = y(:,26:93);
    %z = z(:,26:93);
    
    %H = ones(21,3)./(sum(sum(ones(21,3))));
    winsize = GaussFilter; 
    H = [gausswin(winsize) , gausswin(winsize), gausswin(winsize)];
    H = H./sum(sum(H));
    z = filter2(H,z);
    %z = z- mean(mean(z(3:53, 86:96)));
    z = z- mean(mean(z));
    
    x = x(50:end-50,2:end-1);
    y = y(50:end-50,2:end-1);
    z = z(50:end-50,2:end-1);

%     x = x(4:end-4,50:end-50);
%     y = y(4:end-4,50:end-50);
%     z = z(4:end-4,50:end-50);
    
    % For some reason, not having the grid specified for pcolor makes weird
    % artifacts. To be investigated, but for now just use pcolor
    end_points_y = [y(1,end) y(end,end)];
    %y is flipped because imagesc by default has weird non cartesian
    %coordinates
    end_points_x = [x(end,1) x(end,end)];
    A.end_points_x = end_points_x;
    A.end_points_y = end_points_y;
end

if isa(data_num, 'struct')
    x = data_num.x;
    y = data_num.y;
    z = data_num.z;
end

A.x = x';
A.y = y';
A.z = z';

figure
pcolor(A.x, A.y, A.z)
colormap(redblue(1000))
shading flat
axis equal

% imagesc(end_points_x, end_points_y, z'); shading flat; hold on
% colormap(redblue(500))
% %caxis([-120,120])
% axis off; 
% 
% h = colorbar;
% ylabel(h,'B_{TF} (nT)');
% set(gca, 'Layer', 'Top')
% 
% aspect = [(end_points_x(2)-end_points_x(1)) end_points_y(2)-end_points_y(1) 1];
% pbaspect(aspect);
% 
% %Length of the scale bar in unit of the specified x axis / y axis. 
% %In this case this is in microns
% scalebar_length = 0.5;
% quiver(end_points_x(end)- scalebar_length*1.5, end_points_y(1) - scalebar_length*0.25, scalebar_length, 0 ,'ShowArrowHead','off', 'linewidth',3, 'color', [0,0,0])
% hold off



end

