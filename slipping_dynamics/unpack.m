function [ xtoe, xtoedot, x, xdot, y, ydot, ...
           ra, radot, raddot, hiptorque] = unpack( funparams, simparams )
    gridN = simparams.gridN;
    xtoe          = funparams(2             : 1 + gridN);
    xtoedot       = funparams(2 + gridN     : 1 + gridN * 2);
    x             = funparams(2 + gridN * 2 : 1 + gridN * 3);
    xdot          = funparams(2 + gridN * 3 : 1 + gridN * 4);
    y             = funparams(2 + gridN * 4 : 1 + gridN * 5);
    ydot          = funparams(2 + gridN * 5 : 1 + gridN * 6);
    ra            = funparams(2 + gridN * 6 : 1 + gridN * 7);
    radot         = funparams(2 + gridN * 7 : 1 + gridN * 8);
    raddot        = funparams(2 + gridN * 8 : 1 + gridN * 9);
    hiptorque     = funparams(2 + gridN * 9 : 1 + gridN * 10);
end

