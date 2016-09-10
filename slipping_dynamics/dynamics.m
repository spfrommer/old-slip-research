function [ statedot, compvars ] = dynamics( state, raddot, hiptorque, ...
                                            sp, curPhase)
    stateCell = num2cell(state');
    [xtoe, xtoedot, x, xdot, y, ydot, ra, radot] = deal(stateCell{:});
    
    r = sqrt((x - xtoe)^2 + y^2);
    rdot = ((x-xtoe)*(xdot-xtoedot)+y*ydot)/(r);
    cphi = (x-xtoe) / r;
    sphi = y / r;
    fs = sp.spring * (ra - r) + sp.damp * (radot - rdot);
    ft = hiptorque / r;
    fg = sp.masship * sp.gravity;

    xddot = (1/sp.masship) * (fs*cphi + ft * sphi);
    yddot = (1/sp.masship) * (fs*sphi + ft * (-cphi) - fg);

    grf = fs * sphi - ft * cphi + sp.masstoe * sp.gravity;

    % Check if the phase should be slipping
    if strcmp(curPhase, 'sli')
        ff = -sp.friction * tanh(xtoedot * 50) * grf;
        xtoeddot = (1/sp.masstoe) * (-fs*cphi - ft*sphi + ff);
    else
        xtoeddot = 0;
    end

    statedot = [xtoedot; xtoeddot; xdot; xddot; ydot; yddot; ...
            radot; raddot];

    compvars.r = r;
    compvars.grf = grf;
end

