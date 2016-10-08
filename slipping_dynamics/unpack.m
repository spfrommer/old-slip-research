function [ phaseT, cTdAngle, sTdAngle, xtoe, x, xdot, y, ydot, ...
           ra, radot, raddot] = unpack( funparams, sp )
    p = size(sp.phases, 1);
    cnt = sp.gridn * p;
    
    phaseT        = funparams(1                   : p);
    cTdAngle      = funparams(p + 1               : p * 2 - 1);
    sTdAngle      = funparams(p * 2               : p * 3 - 2);
    xtoe          = funparams(p * 3 - 1           : p * 3 - 2 + cnt);
    x             = funparams(p * 3 - 1 + cnt     : p * 3 - 2 + cnt * 2);
    xdot          = funparams(p * 3 - 1 + cnt * 2 : p * 3 - 2 + cnt * 3);
    y             = funparams(p * 3 - 1 + cnt * 3 : p * 3 - 2 + cnt * 4);
    ydot          = funparams(p * 3 - 1 + cnt * 4 : p * 3 - 2 + cnt * 5);
    ra            = funparams(p * 3 - 1 + cnt * 5 : p * 3 - 2 + cnt * 6);
    radot         = funparams(p * 3 - 1 + cnt * 6 : p * 3 - 2 + cnt * 7);
    raddot        = funparams(p * 3 - 1 + cnt * 7 : p * 3 - 2 + cnt * 8);
end

