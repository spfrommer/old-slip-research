function [ lb, ub ] = bounds(sp)
timeMin            = sp.mintime;
timeMax            = sp.maxtime;
minXtoedot         = -Inf;
maxXtoedot         = Inf;
minX               = -Inf;
maxX               = Inf;
minXdot            = -Inf;
maxXdot            = Inf;
minY               = 0;
maxY               = Inf;
minYdot            = -Inf;
maxYdot            = Inf;
minRa              = -Inf;
maxRa              = Inf;
minRadot           = -Inf;
maxRadot           = Inf;
minRaddot          = sp.minraddot;
maxRaddot          = sp.maxraddot;
minTorque          = sp.mintorque;
maxTorque          = sp.maxtorque;

minXtoe = [];
maxXtoe = [];

for p=1:length(sp.phases)
    phase = sp.phases(p, :);
    if strcmp(phase, 'sli')
        minXtoe = [minXtoe; ones(sp.gridn, 1) * sp.slipPatch(1)];
        maxXtoe = [maxXtoe; ones(sp.gridn, 1) * sp.slipPatch(2)];
    elseif strcmp(phase, 'stl')
        minXtoe = [minXtoe; ones(sp.gridn, 1) * (sp.slipPatch(1)-0.2)];
        maxXtoe = [maxXtoe; ones(sp.gridn, 1) * sp.slipPatch(1)];
    elseif strcmp(phase, 'str')
        minXtoe = [minXtoe; ones(sp.gridn, 1) * sp.slipPatch(2)];
        maxXtoe = [maxXtoe; ones(sp.gridn, 1) * (sp.slipPatch(2)+0.2)];
    end
end

grid = ones(sp.gridn * length(sp.phases), 1);
lb = [ones(length(sp.phases), 1) * timeMin;
      minXtoe;        grid*minXtoedot;
      grid*minX;      grid*minXdot;
      grid*minY;      grid*minYdot;
      grid*minRa;     grid*minRadot;
      grid*minRaddot; grid*minTorque;];
ub = [ones(length(sp.phases), 1) * timeMax;
      maxXtoe;        grid*maxXtoedot;
      grid*maxX;      grid*maxXdot;
      grid*maxY;      grid*maxYdot;
      grid*maxRa;     grid*maxRadot;
      grid*maxRaddot; grid*maxTorque];
end

