function [ cost ] = actworkcost( funparams, sp )
    % Unpack the vector
    [stanceT, ~, xtoe, ~, x, xdot, y, ydot, ra, radot, ~, torque] = ...
        unpack(funparams, sp);
    phaseN = size(sp.phases, 1);
    
    r = sqrt((x - xtoe).^2 + y.^2);
    rdot = ((x-xtoe).*(xdot)+y.*ydot)./(r);
    fs = sp.spring * (ra - r) + sp.damp * (radot - rdot);

    epsilon = 0.001;
    workRa = (sqrt((fs.*radot).^2 + epsilon^2) - epsilon);
    workRa = workRa .* kron(stanceT./sp.gridn, ones(sp.gridn, 1));
    
    angles = atan2(y, x - xtoe);
    angleShift = [angles(1); angles(1 : end-1)];
    angleDeltas = angles - angleShift;
    startRemInd = 1 : sp.gridn : sp.gridn * phaseN;
    endRemInd = sp.gridn : sp.gridn : sp.gridn * phaseN;
    angleDeltas(startRemInd) = [];
    [torqueA,torqueB] = deal(torque);
    torqueA(startRemInd) = [];
    torqueB(endRemInd) = [];
    torqueCombined = (torqueA + torqueB) .* 0.5;
    
    workAng = sqrt((torqueCombined.*angleDeltas).^2 + epsilon^2) - epsilon;
    cost = sum(workRa) + sum(workAng);
    
    vi = sqrt(xdot(11)^2 + ydot(11)^2);
    vf = sqrt(xdot(20)^2 + ydot(20)^2);
    kei = 0.5 * sp.masship * vi^2;
    kef = 0.5 * sp.masship * vf^2;
    pei = sp.gravity * sp.masship * y(11);
    pef = sp.gravity * sp.masship * y(20);
    ei = kei + pei;
    ef = kef + pef;
    edif = ef - ei;
    angWorkSum = sum(workAng(10:18));
end

