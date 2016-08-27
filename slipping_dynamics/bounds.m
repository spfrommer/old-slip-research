function [ lb, ub ] = bounds(sp)
timeMin            = sp.mintime;
timeMax            = sp.maxtime;
minXtoe            = -Inf;
maxXtoe            = Inf;
minXtoedot         = -Inf;
maxXtoedot         = Inf;
minX               = -Inf;
maxX               = Inf;
minXdot            = -Inf;
maxXdot            = Inf;
minY               = -Inf;
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

grid = ones(sp.gridn * sp.phases, 1);
lb = [ones(sp.phases, 1) * timeMin;
      grid*minXtoe;   grid*minXtoedot;
      grid*minX;      grid*minXdot;
      grid*minY;      grid*minYdot;
      grid*minRa;     grid*minRadot;
      grid*minRaddot; grid*minTorque;];
ub = [ones(sp.phases, 1) * timeMax;
      grid*maxXtoe;   grid*maxXtoedot;
      grid*maxX;      grid*maxXdot;
      grid*maxY;      grid*maxYdot;
      grid*maxRa;     grid*maxRadot;
      grid*maxRaddot; grid*maxTorque];
end

