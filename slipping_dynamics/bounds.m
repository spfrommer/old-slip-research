function [ lb, ub ] = bounds(sp)
time_min            = 0.1;
time_max            = 5;
min_xtoe            = -Inf;
max_xtoe            = Inf;
min_xtoedot         = -Inf;
max_xtoedot         = Inf;
min_x               = -Inf;
max_x               = Inf;
min_xdot            = -Inf;
max_xdot            = Inf;
min_y               = -Inf;
max_y               = Inf;
min_ydot            = -Inf;
max_ydot            = Inf;
min_ra              = -Inf;
max_ra              = Inf;
min_radot           = -Inf;
max_radot           = Inf;
min_raddot          = -10;
max_raddot          = 10;
min_hiptorque       = -100;
max_hiptorque       = 100;

grid = ones(sp.gridN * sp.phases, 1);
lb = [ones(sp.phases, 1) * time_min;
      grid*min_xtoe;   grid*min_xtoedot;
      grid*min_x;      grid*min_xdot;
      grid*min_y;      grid*min_ydot;
      grid*min_ra;     grid*min_radot;
      grid*min_raddot; grid*min_hiptorque;];
ub = [ones(sp.phases, 1) * time_max;
      grid*max_xtoe;   grid*max_xtoedot;
      grid*max_x;      grid*max_xdot;
      grid*max_y;      grid*max_ydot;
      grid*max_ra;     grid*max_radot;
      grid*max_raddot; grid*max_hiptorque];
end

