function [ProcessedDCData] = ProcessDCData( rawDCData, rawDataX, rawDataY )
[rows, cols] = size(rawDCData);
dx = rawDataX(3, 2) - rawDataX(3, 1);
dy = rawDataY(5, 2) - rawDataY(4, 2);
if dx ~= dy
    if dx < dy
        ratio = dy / dx;
        ProcessedDCData = zeros(1 + round(ratio * (rows - 1)), cols);
        y = linspace(0, rows - 1, rows);
        yex = linspace(0, rows - 1, 1 + round(ratio * (rows - 1)));
        for i = 1 : cols
            ProcessedDCData(: , i) = interp1( y, rawDCData(: , i), yex );
        end
    else
        ratio = dx / dy;
        ProcessedDCData = zeros(rows, 1 + round(ratio * (cols - 1)));
        x = linspace(0, cols - 1, cols);
        xex = linspace(0, cols - 1, 1 + round(ratio * (cols - 1)));
        for i = 1 : rows
            ProcessedDCData(i , :) = interp1( x, rawDCData(i , :), xex );
        end
    end
else
    ProcessedDCData = rawDCData;
end
        