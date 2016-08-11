function [ xtoe, xtoedot, x, xdot, y, ydot, ...
           ra, radot, raddot, hiptorque] = unpack( params )
    global gridN
    xtoe          = params(2             : 1 + gridN);
    xtoedot       = params(2 + gridN     : 1 + gridN * 2);
    x             = params(2 + gridN * 2 : 1 + gridN * 3);
    xdot          = params(2 + gridN * 3 : 1 + gridN * 4);
    y             = params(2 + gridN * 4 : 1 + gridN * 5);
    ydot          = params(2 + gridN * 5 : 1 + gridN * 6);
    ra            = params(2 + gridN * 6 : 1 + gridN * 7);
    radot         = params(2 + gridN * 7 : 1 + gridN * 8);
    raddot        = params(2 + gridN * 8 : 1 + gridN * 9);
    hiptorque     = params(2 + gridN * 9 : 1 + gridN * 10);
end

