function [Result, RotatedData, Residual] = PhaseRotation(OXQuad, OYQuad)
[r, c] = size(OXQuad);
XQuad = OXQuad - OXQuad(1, 1); %This two lines assumes the bottom left conner has 0 field
YQuad = OYQuad - OYQuad(1, 1); %This two lines assumes the bottom left conner has 0 field
InitialPhase = atan2(YQuad, XQuad);
FlatY = reshape(YQuad, 1, []);
FlatX = reshape(XQuad, 1, []);
FlatInitialPhase = reshape(InitialPhase, 1, []);
fun = @(weight)sum((sqrt(FlatX .^ 2 + FlatY .^ 2) .* sin(FlatInitialPhase - weight)) .^ 2);
p0 = mean(FlatInitialPhase);
[parameter, fval] = fminsearch(fun, p0);
Result = parameter;
% fval = reshape(fval, [r, c]);
Residual = sqrt(XQuad .^ 2 + YQuad .^ 2) .* sin(InitialPhase - parameter);
% Residual = fval;
RotatedData = sqrt(XQuad .^ 2 + YQuad .^ 2) .* cos(InitialPhase - parameter);
fprintf(['Rotation Successful, Angle = ' num2str(rad2deg(parameter)) ' degrees.'])
end
