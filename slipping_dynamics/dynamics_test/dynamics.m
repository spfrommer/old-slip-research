function [ xdot ] = dynamics( t, x )
    global masship masstoe spring damp friction gravity
    xcell = num2cell(x');
    [xtoe, xtoedot, len, lendot, actlen, actlendot, phi, phidot] = ...
        deal(xcell{:});
    hiptorque = 0;
    
    fs = spring * (actlen - len) + damp * (actlendot - lendot);
    ft = hiptorque / len;
    fg = masship * gravity;
    ff = friction * tanh(xtoedot*50) * smoothzero(fs*sin(phi)+ft*cos(phi));
    xtoeddot = (1/masstoe) * (fs*cos(phi) - ft*sin(phi) - ff);
    lenddot = (fs - fg*sin(phi))/masship + xtoeddot*cos(phi);
    actlenddot = 0;
    phiddot = (1/(len^2 * masship)) * (-len*masship*xtoeddot*sin(phi)-...
               len*fg*cos(phi));
    xdot = [xtoedot; xtoeddot; lendot; lenddot; actlendot; actlenddot; ...
            phidot; phiddot];
end

