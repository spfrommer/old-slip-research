GEN_CONSTRAINTS = false;
GEN_COSTS = false;

sp = SimParams();

% Options for optimizing the constant cost function
cOptions = optimoptions(@fmincon, 'TolFun', 0.00000001, ...
                       'MaxIterations', 100000, ...
                       'MaxFunEvals', 50000, ...
                       'Display', 'iter', 'Algorithm', 'sqp', ...
                       'StepTolerance', 1e-13, ...
                       'SpecifyConstraintGradient', true, ...
                       'SpecifyObjectiveGradient', true, ...
                       'ConstraintTolerance', 1e-6, ...
                       'CheckGradients', false, ...
                       'HonorBounds', true, ...
                       'FiniteDifferenceType', 'forward');
% Options for optimizing the actual cost function
aOptions = optimoptions(@fmincon, 'TolFun', 0.00000001, ...
                       'MaxIterations', 1000, ...
                       'MaxFunEvals', 1000000, ...
                       'Display', 'iter', 'Algorithm', 'sqp', ...
                       'StepTolerance', 1e-13, ...
                       'SpecifyConstraintGradient', true, ...
                       'SpecifyObjectiveGradient', true, ...
                       'ConstraintTolerance', 1e-6, ...
                       'CheckGradients', false, ...
                       'HonorBounds', true, ...
                       'FiniteDifferenceType', 'forward');
% No linear inequality or equality constraints
A = [];
b = [];
Aeq = [];
Beq = [];
% Set up the bounds
[lb, ub] = bounds(sp);

tic

numVars = size(sp.phases, 1) * 2 - 1 + ...
          sp.gridn * size(sp.phases, 1) * 8;
funparams = conj(sym('x', [1 numVars], 'real')');

if GEN_CONSTRAINTS
    fprintf('Generating constraints...\n');
    [c, ceq] = constraints(funparams, sp);
    cjac = jacobian(c, funparams).';
    ceqjac = jacobian(ceq, funparams).';
    constraintsFun = matlabFunction(c, ceq, cjac, ceqjac, 'Vars', {funparams});
    fprintf('Done generating constraints...\n');
end

if GEN_COSTS
    fprintf('Generating costs...\n');
    ccost = constcost(funparams, sp);
    ccostjac = jacobian(ccost, funparams).';
    ccostFun = matlabFunction(ccost, ccostjac, 'Vars', {funparams});

    acost = actcost(funparams, sp);
    acostjac = jacobian(acost, funparams).';
    acostFun = matlabFunction(acost, acostjac, 'Vars', {funparams});
    fprintf('Done generating costs...\n');
end

numBest = 1;
bestCosts = inf(1, numBest);
bestTrajs = zeros(numVars, numBest);

for i = 1:1
    x0 = MinMaxCheck(lb, ub, ones(numVars, 1) * 0.75);
    x0(6:15) = 0.6;
    x0(16:25) = 2.3;
    x0(26:35) = 3.1;
    x0(36:45) = 0.6;
    x0(46:55) = 2.3;
    x0(56:65) = 3.1;
    %x0 = MinMaxCheck(lb, ub, rand(numVars, 1));
    [ci, ceqi, cjaci, ceqjaci] = constraintsFun(x0);
    while any(imag(ci))  || any(imag(ceqi))  || any(any(imag(cjaci)))  || any(any(imag(ceqjaci)))  || ...
          any(isnan(ci)) || any(isnan(ceqi)) || any(any(isnan(cjaci))) || any(any(isnan(ceqjaci))) || ...
          any(isinf(ci)) || any(isinf(ceqi)) || any(any(isinf(cjaci))) || any(any(isinf(ceqjaci)))
        fprintf('Regenerating initial guess...\n');
        x0 = MinMaxCheck(lb, ub, ones(numVars, 1) * rand());
        [ci, ceqi, cjaci, ceqjaci] = constraintsFun(x0);
    end
    
    % Find any feasible trajectory
    [feasible, ~, flag, ~] = ...
        fmincon(@(x) call(ccostFun, x, 2),x0,A,b,Aeq,Beq,lb,ub, ...
                @(x) call(constraintsFun, x, 4), cOptions);
    
    if flag > 0
        act = actcost(feasible, sp);
        [minCost, index] = max(bestCosts);
        if act < minCost
            bestCosts(index) = act;
            bestTrajs(:, index) = feasible;
        end
    else
        fprintf('Exited with non-positive flag: %d\n', flag);
    end
end

fprintf('Finished finding feasible trajectories in %f seconds\n', toc);
fprintf('Best trajectory has act cost of: %f\n', bestCosts);
tic

bestTrajs(:, i) = MinMaxCheck(lb, ub, ones(numVars, 1) * 0.5);
bestTrajs(6:15, i) = 0.4;
bestTrajs(16:25, i) = 2.1;
bestTrajs(26:35, i) = 3;
bestTrajs(36:45, i) = 0.4;
bestTrajs(46:55, i) = 2.1;
bestTrajs(56:65, i) = 3;

optimalTrajs = zeros(numVars, numBest);
optimalCosts = zeros(1, numBest);

for i = 1:numBest
    optimalTrajs(:, i) = bestTrajs(:, i);
    optimalCosts(i) = actcost(optimalTrajs(:, i), sp);
    flag = 1;
    lastCost = Inf;
    while flag >= 0 && optimalCosts(i) - lastCost < -1e-2
        lastCost = optimalCosts(i);
        [newOptimal, ~, flag, ~] = ...
            fmincon(@(x) call(acostFun, x, 2),optimalTrajs(:,i),A,b, ...
                    Aeq,Beq,lb,ub,@(x) call(constraintsFun,x,4),aOptions);
        
        if flag >= 0
            optimalTrajs(:, i) = newOptimal;
            optimalCosts(i) = actcost(optimalTrajs(:, i), sp);
        end
    end
end

fprintf('Finished optimizing in %f seconds\n', toc);
optimal = optimalTrajs(:, 1);
visualize