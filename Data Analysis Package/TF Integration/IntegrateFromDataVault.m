%The three lines below are the parameters to be changed: 
%file_numbe = file NO. in datavault , for example, 09648
%DO NOT FORGET TO CHANGE PATH IN OpenDataVaultFile script when running this
%on a different computer
%angle = the angle (in degrees) for tuning fork oscillation starts from +y 
%axis, clockwise as positive. The angle from tunning fork fitting can apply 
%directly here.
%FOR NOW, this script only works for angles: 0~180. The plot for DC data is commented. 

%amplitude = the amplitude of tuning fork oscillations (in um)

% Load the functions necessary for the script
%addpath(fullfile('..','Functions'))


file_number = 09934;
angle = 29.3; % in degrees
amplitude = 0.1954; %in um
offset = 0.2685; 
conversion_factor = 5.36; %This is the conversion factor from Voltage data to distance (um/V)
TFGain = 500; %This is the relative gain between TF and DC data, assuming gain is on TF

[dataset, Variable_Names, ~] = OpenDataVaultFile(file_number);
tf = 0;
while tf == 0
    [yindx,tf] = listdlg('PromptString', 'Please Select TF Y Quadrature Data','SelectionMode','single','ListString',Variable_Names);
    if tf == 0
        answer = questdlg('TF X Quadrature Data Not Selected. Please Select Again.', ...
            'Warning', ...
            'OK','Cancel','OK');
        switch answer
            case 'Cancel'
                return
            case ''
                return
        end
    end
end

tf = 0;
exitflag = 0;
while tf == 0 && exitflag == 0
    [xindx,tf] = listdlg('PromptString', 'Please Select TF X Quadrature Data','SelectionMode','single','ListString',Variable_Names);
    if tf == 0
        answer = questdlg('TF X Quadrature Data Not Selected. Proceed without rotation?', ...
            'Warning', ...
            'Yes','No, Select Again','Exit');
        switch answer
            case 'Yes'
                exitflag = 1;
            case 'No, Select Again'
                exitflag = 0;
            case 'Exit'
                return
            case ''
                return
        end
    end
end

trace = dataset(dataset(:,1) == 0,:);

l= max(dataset(:,2))+1;

DataX = transpose(reshape(trace(:,4),l,[])) .* conversion_factor;
DataY = transpose(reshape(trace(:,5),l,[])) .* conversion_factor;
YQuad = transpose(reshape(trace(:,yindx),l,[]));

switch exitflag
    case 1
        Data = YQuad;
        PData = Data;
        XCOOR = DataX;
        YCOOR = DataY;
    case 0
        XQuad = transpose(reshape(trace(:,xindx),l,[]));
        [PhaseAngle, Data, RotationResidual] = PhaseRotation(XQuad, YQuad);
end

%The following line is only for testing
DC = transpose(reshape(trace(:,7),l,[]));

[m, n] = size(Data);

if m < 6 || n < 6
    waitfor(errordlg('Input Matrix Dimension Too Small','Input Error'));
    return;
end

tf = 0;
Edges = {'top','bottom','left','right'};
[edge,tf] = listdlg('PromptString', 'Please Select The Edge With 0 Field','SelectionMode','single','ListString',Edges);
if tf == 0
    answer = questdlg('No Selection Recorded. Please Select Again.', ...
        'Warning', ...
        'OK','Cancel','OK');
    switch answer
        case 'Cancel'
            return
        case ''
            return
    end
end

switch edge
    case 1
        if angle == 0  || angle == 180
            errordlg('Unable to Compute','Input Error')
            return;
        elseif 0 < angle < 180
            [XCOOR, YCOOR, rawResult, dl, PData] = MatrixIntegrate(Data, DataX, DataY, angle + 180, amplitude);
            Result = rawResult .* (-1);
        elseif 180 < angle < 360
            [XCOOR, YCOOR, Result, dl, PData] = MatrixIntegrate(Data, DataX, DataY, angle, amplitude);
        else
            errordlg('Have not Developed','Input Error')
            return;
        end
        [p, q] = size(Result);
        x2 = round(-p * tand(angle));
        y2 = 0;
        y1 = 0;
        x1 = x2 + q;
        x = [0, q, x1, x2];
        y = [p, p, y1, y2];
        Mask = poly2mask(x, y, p, q);
        RawOutput = Result .* Mask;
    case 2
        if angle == 0  || angle == 180
            Result = NewMatrixIntegrate(Data, DataX, DataY, angle, amplitude);
            errordlg('Unable to Compute','Input Error')
            return;
        elseif 0 < angle < 180
            [XCOOR, YCOOR, Result, dl, PData] = MatrixIntegrate(Data, DataX, DataY, angle, amplitude);
        elseif 180 < angle < 360
            [XCOOR, YCOOR, rawResult, dl, PData] = MatrixIntegrate(Data, DataX, DataY, angle - 180, amplitude);
            Result = rawResult .* (-1);
        else
            errordlg('Have not Developed','Input Error')
            return;
        end
        [p, q] = size(Result);        
        x2 = round(p / tand(90 - angle));
        y2 = p;
        y1 = p;
        x1 = x2 + q;
        x = [0, q, x1, x2];
        y = [0, 0, y1, y2];
        Mask = poly2mask(x, y, p, q);
        RawOutput = Result .* Mask;
    otherwise
        errordlg('Have not Developed','Input Error')
        return;
end
Output = RawOutput ./ TFGain;


figure
subplot(2,4,2)
pcolor(DataX, DataY, Data);
% pcolor(XCOOR,YCOOR,CorrectedPData);
shading flat
axis equal
colorbar
title('Rotated TF Data Before Integration')


% [FX, FY] = gradient(Result * amplitude, dl);
% Derivative = FX * sind(angle) + FY * cosd(angle);

subplot(2,4,6)
pcolor(DataX, DataY, RotationResidual);
shading flat
axis equal
colorbar
title(['Residual After ' num2str(radtodeg(PhaseAngle)) ' Degrees Integration'])

subplot(2,4,1)
pcolor(DataX, DataY, YQuad);
shading flat
axis equal
colorbar
title('Y Quadrature Before Phase Rotation')

subplot(2,4,5)
pcolor(DataX, DataY, XQuad);
shading flat
axis equal
colorbar
title('X Quadrature Before Phase Rotation')

subplot(2,4,3)
pcolor(XCOOR, YCOOR, Output);
shading flat
axis equal
colorbar
title(['After ' num2str(angle) ' Degrees Integration,'])


%The following two lines is only for testing
CorrectedDC = DC - mean(DC(1, :));
PDC = ProcessDCData(CorrectedDC, DataX, DataY);

subplot(2,4,7)
pcolor(DataX, DataY, CorrectedDC);
% pcolor(XCOOR,YCOOR,PDC)
shading flat
axis equal
colorbar
title(['DC Data'])

subplot(2,4,[4 8])
% pcolor(DataX, DataY, DC);
pcolor(XCOOR,YCOOR,(PDC - Output) .* Mask)
shading flat
axis equal
colorbar
title(['Residual of TF fittin'])
sgtitle(['File NO.' num2str(file_number) ', Angle = ' num2str(angle) ', Amplitude = ' num2str(amplitude * 1000) 'nm'])

