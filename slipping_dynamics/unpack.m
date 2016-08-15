function [ xtoe, xtoedot, x, xdot, y, ydot, ...
           ra, radot, raddot, hiptorque] = unpack( funparams, simparams )
    p = simparams.phases;
    cnt = simparams.gridN * p;
    
    xtoe          = funparams(p + 1           : p + cnt);
    xtoedot       = funparams(p + 1 + cnt     : p + cnt * 2);
    x             = funparams(p + 1 + cnt * 2 : p + cnt * 3);
    xdot          = funparams(p + 1 + cnt * 3 : p + cnt * 4);
    y             = funparams(p + 1 + cnt * 4 : p + cnt * 5);
    ydot          = funparams(p + 1 + cnt * 5 : p + cnt * 6);
    ra            = funparams(p + 1 + cnt * 6 : p + cnt * 7);
    radot         = funparams(p + 1 + cnt * 7 : p + cnt * 8);
    raddot        = funparams(p + 1 + cnt * 8 : p + cnt * 9);
    hiptorque     = funparams(p + 1 + cnt * 9 : p + cnt * 10);
end

