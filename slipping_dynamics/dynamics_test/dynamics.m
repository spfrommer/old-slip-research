function [ xdot ] = dynamics( t, x )
    global masship masstoe spring damp friction gravity
    xcell = num2cell(x');
    [xtoe, xtoedot, x, xdot, y, ydot, ra, radot] = ...
        deal(xcell{:});
    hiptorque = 0;
    raddot = 0;
    
    r = sqrt((x - xtoe)^2 + y^2);
    rdot = ((x-xtoe)*(xdot-xtoedot)+y*ydot)/(sqrt((x - xtoe)^2 + y^2));
    phi = mod(atan2(y, x-xtoe), 2 * pi);
    fs = spring * (ra - r) + damp * (radot - rdot);
    ft = hiptorque / r;
    fg = masship * gravity;
    ff = friction * tanh(xtoedot * 50) * smoothzero(fs * sin(phi) - ...
                    ft * sin(phi+pi/2) - masstoe*gravity);
    
    xddot = (1/masship) * (fs*cos(phi) + ft * cos(phi - pi/2));
    yddot = (1/masship) * (fs*sin(phi) + ft * sin(phi - pi/2) - fg);
    xtoeddot = (1/masstoe) * (-fs*cos(phi) - ft*cos(phi + pi/2) - ff);
    
    xdot = [xtoedot; xtoeddot; xdot; xddot; ydot; yddot; ...
            radot; raddot];
end

