
addpath(fullfile('..','Functions'))

%Set up the angle and amplitude of integration
angle = 29.2;
amplitude = 0.162;

%Grab the filetered data from TFScanDataProcessor
Data1 = TFScanDataProcessor(10132);
Data2 = TFScanDataProcessor(10133);

%Summing two data together
Data = Data1.z + Data2.z;
DataX = Data1.x;
DataY = Data1.y;
Data = Data - Data(1,:);


%High Pass Filtering the Data
FilteredData = HighPassFilter(DataX, DataY, Data, 0.003);

[XCOOR, YCOOR, Output, dl, Original] = IntegrateAndMask(FilteredData, DataX, DataY, angle, amplitude);

sumData.x = XCOOR;
sumData.y = YCOOR;
sumData.z = Output;
Original = Original';

end_points_x = [sumData.x(1,end) sumData.x(end,end)];
end_points_y = [sumData.y(end,end) sumData.y(end,1)];

figure
subplot(1,2,1)
pcolor(DataX, DataY, FilteredData);
colormap(redblue(1000))
shading flat
axis equal
colorbar
title('Summed Data Before Integration')

subplot(1,2,2)
pcolor(XCOOR,YCOOR,sumData.z);
colormap(redblue(1000))
shading flat
axis equal
colorbar
title(['Data After Integration'])

% figure
% subplot(1,2,1)
% imagesc(end_points_x, end_points_y, Original'); shading flat; hold on
% colormap(redblue(500))
% %caxis([-120,120])
% axis off; 
% 
% h = colorbar;
% ylabel(h,'B_{TF} (nT)');
% set(gca, 'Layer', 'Top')
% 
% aspect = [(end_points_x(2)-end_points_x(1)) end_points_y(1)-end_points_y(2) 1];
% pbaspect(aspect);
% 
% %Length of the scale bar in unit of the specified x axis / y axis. 
% %In this case this is in microns
% scalebar_length = 0.5;
% quiver(end_points_x(end)- scalebar_length*1.5, end_points_y(1) - scalebar_length*0.25, scalebar_length, 0 ,'ShowArrowHead','off', 'linewidth',3, 'color', [0,0,0])
% title('Summed Data Before Integration')
% hold off
% 
% subplot(1,2,2)
% imagesc(end_points_x, end_points_y, Output'); shading flat; hold on
% colormap(redblue(500))
% %caxis([-120,120])
% axis off; 
% 
% % h = colorbar;
% % ylabel(h,'B_{TF} (nT)');
% % set(gca, 'Layer', 'Top')
% % 
% % aspect = [(end_points_x(2)-end_points_x(1)) end_points_y(1)-end_points_y(2) 1];
% % pbaspect(aspect);
% % 
% % %Length of the scale bar in unit of the specified x axis / y axis. 
% % %In this case this is in microns
% % scalebar_length = 0.5;
% % quiver(end_points_x(end)- scalebar_length*1.5, end_points_y(1) - scalebar_length*0.25, scalebar_length, 0 ,'ShowArrowHead','off', 'linewidth',3, 'color', [0,0,0])
% % title('Summed Data Before Integration')
% % hold off
