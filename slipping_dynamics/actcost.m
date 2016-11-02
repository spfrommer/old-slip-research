function [ cost ] = actcost( funparams, sp )
    % Unpack the vector
    [stanceT, ~, xtoe, ~, x, xdot, y, ydot, ra, radot, ~, torque] = ...
        unpack(funparams, sp);
    phaseN = size(sp.phases, 1);
    
    r = sqrt((x - xtoe).^2 + y.^2);
    rdot = ((x-xtoe).*(xdot)+y.*ydot)./(r);
    fs = sp.spring * (ra - r) + sp.damp * (radot - rdot);

    epsilon = 0.001;
    % Actually doesn't take into account time (included in later summation)
    workRa = (sqrt((fs.*radot).^2 + epsilon^2) - epsilon);
    
    angles = atan2(y, x - xtoe);
    angleShift = [angles(1); angles(1 : end-1)];
    angleDeltas = angles - angleShift;
    remInd = 1 : sp.gridn : sp.gridn * phaseN;
    angleDeltas(remInd) = [];
    torque(remInd) = [];
    workAng = sqrt((torque.*angleDeltas).^2 + epsilon^2) - epsilon;
    
    cost = 0;
    for i = 1 : phaseN
        dt = stanceT(i) / sp.gridn;
        cost = cost + sum(workRa(sp.gridn * (i-1) + 1 : sp.gridn * i)) * dt;
        cost = cost + sum(workAng);
    end
end

