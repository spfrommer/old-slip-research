function [ statedot, compvars ] = dynamics( state, raddot, sp )
    stateCell = num2cell(state');
    [xtoe, x, xdot, y, ydot, ra, radot] = deal(stateCell{:});
    
    r = sqrt((x - xtoe)^2 + y^2);
    rdot = ((x-xtoe)*(xdot) + y*ydot) / (r);
    fs = sp.spring * (ra - r) + sp.damp * (radot - rdot);

    xddot = fs * (x - xtoe) / (sp.masship * r);
    yddot = fs * y / (sp.masship * r) - sp.gravity;
    
    xtoedot = 0;

    statedot = [xtoedot; xdot; xddot; ydot; yddot; radot; raddot];

    compvars.r = r;
    compvars.grf = fs;
end

