function [] = Plot_nSOT_linevsgate(data_num_start, data_num_end)
%PLOTME2D Summary of this function goes here
%   Detailed explanation goes here

ZurichGain = 10000; %Gain on the Zurich
SRGain = 10; %Gain on the SR preamp
squidSlope = 43; %Sensitivity of SQUID in volts / tesla
unit = 1e9; %Desired unit in tesla. 1e6 is uT, 1e9 is nT

%volts = linspace(8,10.3,121);
volts = (linspace(-4,-0.0025,118) + 0.08)*3/3.9;
scandata = [];

for i = data_num_start:data_num_end
    dataset = OpenDataVaultFile(i);
    trace = dataset(dataset(:,1) ==0,:);
    retrace = dataset(dataset(:,1) ==1,:);
    
    trace = trace - mean(trace(end/2:end)); 
    retrace = retrace - mean(retrace(end/2:end)); 
    
    datum = trace(:,10);
    scandata = [scandata datum];
end

%B = 1/100*ones(10,10);
%scandata = filter2(B,scandata);

scanlength = sqrt((trace(end,4)-trace(1,4))^2 + (trace(end,5)-trace(1,5))^2)*5.33;
%1.1 volts to 5.9 microns for x
%Assuming same for y 

z = scandata.*unit./(ZurichGain*SRGain*squidSlope);
%z = z - mean(mean(z(:)));
z = z - mean(mean(z(1:8)));

% For some reason, not having the grid specified for pcolor makes weird
% artifacts. To be investigated, but for now just use pcolor
x = [volts(1) volts(data_num_end-data_num_start+1) ]
%y is flipped because imagesc by default has weird non cartesian
%coordinates
y = [0 scanlength]

imagesc(x, y, z); shading flat; hold on
colormap(redblue(500))
set(gca,'YDir','normal')
%caxis([-75,75])

h = colorbar;
ylabel(h,'B_{TF} (nT)');
set(gca, 'Layer', 'Top')
xlabel('Density (10^{12} cm^{-2})')
ylabel('Position (um)')
caxis([-75,75])

end

