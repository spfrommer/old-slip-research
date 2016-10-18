function [ cost ] = actcost( funparams, sp )
    % Unpack the vector
    [stanceT, ~, xtoe, x, xdot, y, ydot, ra, radot, ~] = ...
        unpack(funparams, sp);
    
    r = sqrt((x - xtoe).^2 + y.^2);
    rdot = ((x-xtoe).*(xdot)+y.*ydot)./(r);
    fs = sp.spring * (ra - r) + sp.damp * (radot - rdot);

    epsilon = 0.001;
    work = sqrt((fs.*radot).^2 + epsilon^2) - epsilon;    
    
    cost = 0;
    for i = 1 : size(sp.phases, 1);
        dt = stanceT(i) / sp.gridn;
        cost = cost + sum(work(sp.gridn * (i-1) + 1 : sp.gridn * i) * dt);
    end
end

