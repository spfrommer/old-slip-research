function [ lb, ub ] = bounds(sp)
timeMin            = sp.mintime;
timeMax            = sp.maxtime;
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
cTdAngleMin        = -Inf;
cTdAngleMax        = Inf;
sTdAngleMin        = -Inf;
sTdAngleMax        = Inf;

minXtoe = [];
maxXtoe = [];

for p=1:size(sp.phases, 1)
    phase = sp.phases(p, :);
    if strcmp(phase, 'sli')
        minXtoe = [minXtoe; ones(sp.gridn, 1) * sp.slipPatch(1)];
        maxXtoe = [maxXtoe; ones(sp.gridn, 1) * sp.slipPatch(2)];
    elseif strcmp(phase, 'stl')
        %minXtoe = [minXtoe; ones(sp.gridn, 1) * (sp.slipPatch(1)-0.2)];
        minXtoe = [minXtoe; ones(sp.gridn, 1) * -Inf];
        maxXtoe = [maxXtoe; ones(sp.gridn, 1) * sp.slipPatch(1)];
    elseif strcmp(phase, 'str')
        minXtoe = [minXtoe; ones(sp.gridn, 1) * sp.slipPatch(2)];
        %maxXtoe = [maxXtoe; ones(sp.gridn, 1) * (sp.slipPatch(2)+0.2)];
        maxXtoe = [maxXtoe; ones(sp.gridn, 1) * Inf];
    end
end

grid = ones(sp.gridn * size(sp.phases, 1), 1);
lb = [ones(size(sp.phases, 1), 1) * timeMin;
      ones(size(sp.phases, 1) - 1, 1) * cTdAngleMin;
      ones(size(sp.phases, 1) - 1, 1) * sTdAngleMin;
      minXtoe;
      grid*minX;      grid*minXdot;
      grid*minY;      grid*minYdot;
      grid*minRa;     grid*minRadot;
      grid*minRaddot];
ub = [ones(size(sp.phases, 1), 1) * timeMax;
      ones(size(sp.phases, 1) - 1, 1) * cTdAngleMax;
      ones(size(sp.phases, 1) - 1, 1) * sTdAngleMax;
      maxXtoe;
      grid*maxX;      grid*maxXdot;
      grid*maxY;      grid*maxYdot;
      grid*maxRa;     grid*maxRadot;
      grid*maxRaddot];
end

