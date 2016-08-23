function [ time ] = actcost( funparams, sp )
    % Unpack the vector
    [phaseT, xtoe, xtoedot, x, xdot, y, ydot, ra, radot, raddot, hiptorque] = ...
        unpack(funparams, sp);
        
    %time = sum(hiptorque.^2) + sum(raddot.^2);
    time = 1;
end

