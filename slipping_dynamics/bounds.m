function [ lb, ub ] = bounds(gridN)
time_min            = 1;
time_max            = 5;
min_len             = 0.1;
max_len             = 1;
min_lendot          = -Inf;
max_lendot          = Inf;
min_actlen          = -Inf;
max_actlen          = Inf;
min_actlendot       = -Inf;
max_actlendot       = Inf;
min_actlenddot      = -4000;
max_actlenddot      = 4000;
min_groundangle     = -Inf;
max_groundangle     = Inf;
min_groundangledot  = -Inf;
max_groundangledot  = Inf;
min_hiptorque       = -8;
max_hiptorque       = 8;

grid = ones(gridN, 1);
lb = [time_min; grid * min_len;             grid * min_lendot;
                grid * min_actlen;          grid * min_actlendot;
                grid * min_actlenddot;      grid * min_groundangle;
                grid * min_groundangledot;  grid * min_hiptorque];
ub = [time_max; grid * max_len;             grid * max_lendot;
                grid * max_actlen;          grid * max_actlendot;
                grid * max_actlenddot;      grid * max_groundangle;
                grid * max_groundangledot;  grid * max_hiptorque];
end

