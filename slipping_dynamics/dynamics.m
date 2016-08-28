function [ statedot, compvars ] = dynamics( state, raddot, hiptorque, ...
                                            sp, curPhase)
    stateCell = num2cell(state');
    [xtoe, xtoedot, x, xdot, y, ydot, ra, radot] = deal(stateCell{:});
    
    r = sqrt((x - xtoe)^2 + y^2);
    rdot = ((x-xtoe)*(xdot-xtoedot)+y*ydot)/(sqrt((x - xtoe)^2 + y^2));
    phi = mod(atan2(y, x-xtoe), 2 * pi);
    fs = sp.spring * (ra - r) + sp.damp * (radot - rdot);
    ft = hiptorque / r;
    fg = sp.masship * sp.gravity;

    xddot = (1/sp.masship) * (fs*cos(phi) + ft * sin(phi));
    yddot = (1/sp.masship) * (fs*sin(phi) + ft * (-cos(phi)) - fg);

    % Check if the phase should be slipping
    if strcmp(curPhase, 'sl')
        ff = -sp.friction*tanh(xtoedot * 50)*smoothZero(fs*sin(phi) -...
                   ft * cos(phi) + sp.masstoe*sp.gravity);
        xtoeddot = (1/sp.masstoe) * (-fs*cos(phi) - ft*sin(phi) + ff);
    else
        xtoeddot = 0;
    end

    statedot = [xtoedot; xtoeddot; xdot; xddot; ydot; yddot; ...
            radot; raddot];
        
    compvars.r = r;
    compvars.fs = fs;
end

