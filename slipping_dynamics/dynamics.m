function [ statedot, compvars ] = dynamics( state, raddot, hiptorque, simparams )
    statecell = num2cell(state');
    [xtoe, xtoedot, x, xdot, y, ydot, ra, radot] = deal(statecell{:});
    
    r = sqrt((x - xtoe)^2 + y^2);
    rdot = ((x-xtoe)*(xdot-xtoedot)+y*ydot)/(sqrt((x - xtoe)^2 + y^2));
    phi = mod(atan2(y, x-xtoe), 2 * pi);
    fs = simparams.spring * (ra - r) + simparams.damp * (radot - rdot);
    ft = hiptorque / r;
    fg = simparams.masship * simparams.gravity;
    
    ff = -simparams.friction*tanh(xtoedot * 50)*smoothzero(fs*sin(phi) -...
                    ft * cos(phi) + simparams.masstoe*simparams.gravity);
    
    xddot = (1/simparams.masship) * (fs*cos(phi) + ft * sin(phi));
    yddot = (1/simparams.masship) * (fs*sin(phi) + ft * (-cos(phi)) - fg);
    xtoeddot = (1/simparams.masstoe) * (-fs*cos(phi) - ft*sin(phi) + ff);
    statedot = [xtoedot; xtoeddot; xdot; xddot; ydot; yddot; ...
            radot; raddot];
        
    compvars.r = r;
    compvars.fs = fs;
end

