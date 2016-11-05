classdef VisParams < handle
    properties
        camFollow = true;
        camArea = [-3, 3, -3, 3];
        drawText = false;
        dt = 0.03;
        pauseFactor = 0.5;
        springWidth = 0.07;
        hipColor = [1 .5 0];
        interpolate = false;
    end
end

