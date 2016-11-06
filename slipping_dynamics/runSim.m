function [ optimal, cost, flag ] = runSim( sp )
    disp('Slip patch: ');
    disp(sp.slipPatch);
    disp('Initial state: ');
    disp(sp.initialState);
    disp('Final x: ');
    disp(sp.finalProfileX);

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
    B = [];
    Aeq = [];
    Beq = [];
    % Set up the bounds
    [lb, ub] = bounds(sp);

    numVars = size(sp.phases, 1) * 2 - 1 + sp.gridn * size(sp.phases, 1) * 10;
    funparams = conj(sym('x', [1 numVars], 'real')');
    
    fprintf('Generating constraints...\n');
    [c, ceq] = constraints(funparams, sp);
    cjac = jacobian(c, funparams).';
    ceqjac = jacobian(ceq, funparams).';
    constraintsFun = matlabFunction(c, ceq, cjac, ceqjac, 'Vars', {funparams});
    fprintf('Done generating constraints...\n');
    
    
    fprintf('Generating costs...\n');
    ccost = constcost(funparams, sp);
    ccostjac = jacobian(ccost, funparams).';
    ccostFun = matlabFunction(ccost, ccostjac, 'Vars', {funparams});

    acost = actsqrcost(funparams, sp);
    acostjac = jacobian(acost, funparams).';
    acostFun = matlabFunction(acost, acostjac, 'Vars', {funparams});
    fprintf('Done generating costs...\n');
    
    
    flag = -1;
    tryCount = 0;
    while flag < 0 && tryCount < 5
        % Generate initial guess
        x0 = MinMaxCheck(lb, ub, ones(numVars, 1) * rand() * 2);
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
            fmincon(@(x) call(ccostFun, x, 2),x0,A,B,Aeq,Beq,lb,ub, ...
                    @(x) call(constraintsFun, x, 4), cOptions);
        tryCount = tryCount + 1;
    end

    if flag > 0
        [optimal, cost, flag, ~] = ...
            fmincon(@(x) call(acostFun, x, 2),feasible,A,B, ...
                    Aeq,Beq,lb,ub,@(x) call(constraintsFun,x,4),aOptions);
    else
        optimal = [];
        cost = 0;
        fprintf('Exited with non-positive flag: %d\n', flag);
    end            
end
