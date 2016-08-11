function [ statedot ] = dynamics( state, raddot, hiptorque )
    global masship masstoe spring damp friction gravity
    statecell = num2cell(state');
    [xtoe, xtoedot, x, xdot, y, ydot, ra, radot] = deal(statecell{:});
    
    r = sqrt((x - xtoe)^2 + y^2);
    rdot = ((x-xtoe)*(xdot-xtoedot)+y*ydot)/(sqrt((x - xtoe)^2 + y^2));
    phi = mod(atan2(y, x-xtoe), 2 * pi);
    fs = spring * (ra - r) + damp * (radot - rdot);
    fs = spring * (ra - r);
    ft = hiptorque / r;
    fg = masship * gravity;
    
    ff = -friction * tanh(xtoedot * 50) * smoothzero(fs * sin(phi) - ...
                    ft * cos(phi) + masstoe*gravity);
    
    xddot = (1/masship) * (fs*cos(phi) + ft * sin(phi));
    yddot = (1/masship) * (fs*sin(phi) + ft * (-cos(phi)) - fg);
    xtoeddot = (1/masstoe) * (-fs*cos(phi) - ft*sin(phi) + ff);
    
    statedot = [xtoedot; xtoeddot; xdot; xddot; ydot; yddot; ...
            radot; raddot];
end

