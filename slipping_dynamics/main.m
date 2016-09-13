GEN_CONSTRAINTS = false;
GEN_COSTS = false;
RESET_X0 = true;

sp = SimParams();

% Options for fmincon
options = optimoptions(@fmincon, 'TolFun', 0.00000001, ...
                       'MaxIterations', 10000, ...
                       'MaxFunEvals', 1000000, ...
                       'Display', 'iter', 'Algorithm', 'sqp', ...
                       'StepTolerance', 1e-13, ...
                       'SpecifyConstraintGradient', true, ...
                       'SpecifyObjectiveGradient', true, ...
                       'ConstraintTolerance', 1e-8, ...
                       'FiniteDifferenceType', 'central');
% No linear inequality or equality constraints
A = [];
b = [];
Aeq = [];
Beq = [];
% Set up the bounds
[lb, ub] = bounds(sp);

tic

numVars = length(sp.phases)+sp.gridn*length(sp.phases)*10;
if RESET_X0
    x0 = rand(numVars, 1) * 2;
    fprintf('Generated new x0\n');
else
    x0 = optimal;
end
funparams = conj(sym('x', [1 numVars], 'real')');

if GEN_CONSTRAINTS
    [c, ceq] = constraints(funparams, sp);
    cjac = jacobian(c, funparams).';
    ceqjac = jacobian(ceq, funparams).';
    constraintsFun = matlabFunction(c, ceq, cjac, ceqjac, 'Vars', {funparams});
end

if GEN_COSTS
    cost = timecost(funparams, sp);
    costjac = jacobian(cost, funparams).';
    costFun = matlabFunction(cost, costjac, 'Vars', {funparams});
end

fprintf('Finished generating functions in %f seconds\n', toc);
tic

% First find any feasible trajectory
optimal = fmincon(@(x) call(costFun, x, 2), x0, A, b, Aeq, Beq, lb, ub, ...
                  @(x) call(constraintsFun, x, 4), options);

fprintf('Finished optimizing in %f seconds\n', toc);
visualize