function [Output] = InterpolateIntegrateAndMask(Data, DataX, DataY, angle, amplitude)
% -180 < angle <= 180
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
        Output = Result ;
        
    case 2
        if angle == 0  || angle == 180
            Result = InterpolateIntegrate(Data, DataX, DataY, angle, amplitude);
            errordlg('Unable to Compute','Input Error')
            return;
        elseif (-90 < angle) && (angle < 90)
            [Result] = InterpolateIntegrate(Data, DataX, DataY, angle, amplitude);
        else
            [rawResult] = InterpolateIntegrate(Data, DataX, DataY, angle - 180, amplitude);
            Result = rawResult .* (-1);
%         else
%             errordlg('Have not Developed','Input Error')
%             return;
        end
        [p, q] = size(Result);        
        x2 = round(p / tand(90 - angle));
        y2 = p;
        y1 = p;
        x1 = x2 + q;
        x = [0, q, x1, x2];
        y = [0, 0, y1, y2];
        Mask = poly2mask(x, y, p, q);
        Output = Result .* Mask;
    otherwise
        errordlg('Have not Developed','Input Error')
        return;
end
