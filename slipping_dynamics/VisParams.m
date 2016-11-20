classdef VisParams < handle
    properties
        camFollow = false;
        camArea = [-1.7, 3, -1.7, 3];
        drawText = false;
        dt = 0.03;
        pauseFactor = 0.5;
        springWidth = 0.07;
        hipColor = [1 .5 0];
        interpolate = false;
    end
end

