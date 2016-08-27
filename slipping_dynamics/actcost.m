function [ cost ] = actcost( funparams, sp )
    % Unpack the vector
    [phaseT, xtoe, xtoedot, x, xdot, y, ydot, ra, radot, raddot, hiptorque] = ...
        unpack(funparams, sp);
        
    cost = sum(hiptorque.^2) + sum(raddot.^2);
end

