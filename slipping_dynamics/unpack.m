function [ stanceT, flightT, xtoe, x, xdot, y, ydot, ...
           ra, radot, raddot] = unpack( funparams, sp )
    p = size(sp.phases, 1);
    cnt = sp.gridn * p;
    
    stanceT       = funparams(1               : p);
    flightT       = funparams(p + 1           : p * 2 - 1);
    xtoe          = funparams(p * 2           : p * 2 - 1 + cnt);
    x             = funparams(p * 2 + cnt     : p * 2 - 1 + cnt * 2);
    xdot          = funparams(p * 2 + cnt * 2 : p * 2 - 1 + cnt * 3);
    y             = funparams(p * 2 + cnt * 3 : p * 2 - 1 + cnt * 4);
    ydot          = funparams(p * 2 + cnt * 4 : p * 2 - 1 + cnt * 5);
    ra            = funparams(p * 2 + cnt * 5 : p * 2 - 1 + cnt * 6);
    radot         = funparams(p * 2 + cnt * 6 : p * 2 - 1 + cnt * 7);
    raddot        = funparams(p * 2 + cnt * 7 : p * 2 - 1 + cnt * 8);
end

