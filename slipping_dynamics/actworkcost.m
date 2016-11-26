function [ cost ] = actworkcost( funparams, sp )
    % Unpack the vector
    [stanceT, ~, xtoe, ~, x, xdot, y, ydot, ra, radot, ~, torque] = ...
        unpack(funparams, sp);
    phaseN = size(sp.phases, 1);
    
    r = sqrt((x - xtoe).^2 + y.^2);
    rdot = ((x-xtoe).*(xdot)+y.*ydot)./(r);
    fs = sp.spring * (ra - r) + sp.damp * (radot - rdot);
    
    startRemInd = 1 : sp.gridn : sp.gridn * phaseN;
    endRemInd = sp.gridn : sp.gridn : sp.gridn * phaseN;
    
    [fsA, fsB] = deal(fs);
    fsA(startRemInd) = [];
    fsB(endRemInd) = [];
    fsCombined = (fsA + fsB) .* 0.5;
    
    [radotA, radotB] = deal(radot);
    radotA(startRemInd) = [];
    radotB(endRemInd) = [];
    radotCombined = (radotA + radotB) .* 0.5;
    
    epsilon = 0.001;
    workRa = (sqrt((fsCombined.*radotCombined).^2 + epsilon^2) - epsilon);
    workRa = workRa .* kron(stanceT./sp.gridn, ones(sp.gridn - 1, 1));
    
    angles = atan2(y, x - xtoe);
    angleShift = [angles(1); angles(1 : end-1)];
    angleDeltas = angles - angleShift;
    angleDeltas(startRemInd) = [];
    [torqueA,torqueB] = deal(torque);
    torqueA(startRemInd) = [];
    torqueB(endRemInd) = [];
    torqueCombined = (torqueA + torqueB) .* 0.5;
    
    workAng = sqrt((torqueCombined.*angleDeltas).^2 + epsilon^2) - epsilon;
    cost = sum(workRa) + sum(workAng);
    
    %{
    vi = sqrt(xdot(41)^2 + ydot(41)^2);
    vf = sqrt(xdot(60)^2 + ydot(60)^2);
    kei = 0.5 * sp.masship * vi^2;
    kef = 0.5 * sp.masship * vf^2;
    pei = sp.gravity * sp.masship * y(41);
    pef = sp.gravity * sp.masship * y(60);
    endSpringEnergy = 0.5 * sp.spring * (ra(60)-r(60))^2;
    ei = kei + pei;
    ef = kef + pef + endSpringEnergy;
    edif = ef - ei;
    
    workAngPrecise = torqueCombined.*angleDeltas;
    angWorkSum = sum(workAngPrecise(39:57));
    %}
end

