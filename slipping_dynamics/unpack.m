function [ phaseT, cTdAngle, sTdAngle, xtoe, xtoedot, x, xdot, y, ydot, ...
           ra, radot, raddot, torque] = unpack( funparams, sp )
    p = length(sp.phases);
    cnt = sp.gridn * p;
    
    phaseT        = funparams(1                   : p);
    cTdAngle      = funparams(p + 1               : p * 2 - 1);
    sTdAngle      = funparams(p * 2               : p * 3 - 2);
    xtoe          = funparams(p * 3 - 1           : p * 3 - 2 + cnt);
    xtoedot       = funparams(p * 3 - 1 + cnt     : p * 3 - 2 + cnt * 2);
    x             = funparams(p * 3 - 1 + cnt * 2 : p * 3 - 2 + cnt * 3);
    xdot          = funparams(p * 3 - 1 + cnt * 3 : p * 3 - 2 + cnt * 4);
    y             = funparams(p * 3 - 1 + cnt * 4 : p * 3 - 2 + cnt * 5);
    ydot          = funparams(p * 3 - 1 + cnt * 5 : p * 3 - 2 + cnt * 6);
    ra            = funparams(p * 3 - 1 + cnt * 6 : p * 3 - 2 + cnt * 7);
    radot         = funparams(p * 3 - 1 + cnt * 7 : p * 3 - 2 + cnt * 8);
    raddot        = funparams(p * 3 - 1 + cnt * 8 : p * 3 - 2 + cnt * 9);
    torque        = funparams(p * 3 - 1 + cnt * 9 : p * 3 - 2 + cnt * 10);
end

