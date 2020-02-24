close all
clear x z theta interp_data interp_dataz i j I L 

%Load data and filter it
figure
A = Plot_nSOT_Mag(9176);
% hold on
% 
% x = A.x(1)+ (A.x(2) - A.x(1))*(1700-1)/2400;
% delta_x = (A.x(2) - A.x(1))*(100)/2400;
% 
% y = A.y(2)+ (A.y(1)-A.y(2))*(117-70)/117;
% delta_y = (A.y(1)-A.y(2))*(23)/117;
% rectangle('Position',[x,y,delta_x,delta_y],...
%           'Curvature',[0,0],...
%          'LineWidth',2,'LineStyle','--')

figure
B = Plot_nSOT_Mag(9177);

diff = A;
diff.z = A.z - B.z;

figure 
pcolor(diff.X,diff.Y,diff.z); shading flat; hold on
colormap(redblue(500))
caxis([-120,120])
axis off; 

h = colorbar;
ylabel(h,'B_{TF} (nT)');
set(gca, 'Layer', 'Top')

aspect = [(diff.x(2)-diff.x(1)) diff.y(1)-diff.y(2) 1];
pbaspect(aspect);
hold on
     
% NEXT SECTION IS FITTING TF DIRECTION LINECUTS
p0 = [20.4,16.914];
L = 1.2; %Length in microns of interpolated data from p1
theta = 30; %Angle of interpolated line data from p1. 0 degrees is vertical
    
%figure
leglist = {};
for j=0:3

    p1 = p0 + j*[0.1, 0];
    p2 = [p1(1) + L*sin(theta*pi/180), p1(2) + L*cos(30*pi/180)];

    interp_dataz = zeros(101,51);
    for i=1:201
        p1temp = p1 + [0.2, 0]*(i-101)/201;
        p2temp = p2 + [0.2, 0]*(i-101)/201;
        interp_dataz(i,:) = InterpDataLine(A, p1temp, p2temp, 51).z;
    end

    interp_dataz = mean(interp_dataz);

    interp_data = InterpDataLine(A, p1, p2, 51);
    interp_data.z = interp_dataz;

    [~,I] = max(abs(interp_data.z));

    x = (interp_data.x-interp_data.x(I))*1000*cos(0*pi/180);
    z = interp_data.z;

    ft = fittype('TFDomainWallSignal(x+x0, 162, A,27*pi/180,27*pi/180, 127, s, 130)');

    f = fit(x', z', ft, 'StartPoint', [0, 350, -1],'Exclude', x < -150, 'Exclude', x > 200);

    figure, plot(f, x', z')
    %leglist(end+1) = {strcat(num2str(p1(1)),', ',num2str(f.A),', ',num2str(f.s))};
    %legend(leglist)
    legend(strcat(num2str(p1(1)),', ',num2str(f.A),', ',num2str(f.s)))
    %hold on
end

% NEXT SECTION IS FITTING VERITCAL LINECUTS
p0 = [20.4,17.05];
%figure
leglist = {};
for j=0:3

    p1 = p0 + j*[0.1, 0];

    L = 0.9; %Length in microns of interpolated data from p1
    theta = 0; %Angle of interpolated line data from p1. 0 degrees is vertical

    p2 = [p1(1) + L*sin(theta*pi/180), p1(2) + L*cos(30*pi/180)];

    interp_dataz = zeros(101,51);
    for i=1:101
        p1temp = p1 + [0.2, 0]*(i-51)/101;
        p2temp = p2 + [0.2, 0]*(i-51)/101;
        interp_dataz(i,:) = InterpDataLine(A, p1temp, p2temp, 51).z;
    end

    interp_dataz = mean(interp_dataz);

    interp_data = InterpDataLine(A, p1, p2, 51);
    interp_data.z = interp_dataz;

    [~,I] = max(abs(interp_data.z));

    x = (interp_data.x-interp_data.x(I))*1000;
    z = interp_data.z;

    ft = fittype('TFDomainWallSignal(x+x0, 162, A,27*pi/180, 3*pi/180, 127, s, 130)');

    f = fit(x', z', ft, 'StartPoint', [0, 350, -1],'Exclude', x < -150, 'Exclude', x > 200);

    figure, plot(f, x', z')
    %leglist(end+1) = {strcat(num2str(p1(1)),', ',num2str(f.A),', ',num2str(f.s))};
    %legend(strcat(num2str(p1(1)),', ',num2str(f.A),', ',num2str(f.s)))
    legend(strcat(num2str(p1(1)),', ',num2str(f.A),', ',num2str(f.s)))
    %hold on
end