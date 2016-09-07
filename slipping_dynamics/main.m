sp = SimParams();

% Options for fmincon
options = optimoptions(@fmincon, 'TolFun', 0.00000001, ...
                       'MaxIterations', 10000, ...
                       'MaxFunEvals', 1000000, ...
                       'Display', 'iter', 'Algorithm', 'sqp', ...
                       'StepTolerance', 1e-13);
% No linear inequality or equality constraints
A = [];
b = [];
Aeq = [];
Beq = [];
% Set up the bounds
[lb, ub] = bounds(sp);

tic

numVars = length(sp.phases)+sp.gridn*length(sp.phases)*10;
r = rand() * 2;
r = 0.45;
x0 = ones(numVars,1) * r;
funparams = sym('x', [1 numVars]);

[c, ceq] = constraints(funparams, sp);
constraintsFun = matlabFunction(c, ceq);

[cost] = constcost(funparams, sp);
constcostFun = matlabFunction(cost);

fprintf('Trying: %f\n', r);

% First find any feasible trajectory
optimal = fmincon(@(x) callExpand(constcostFun,x,false,1), x0,A,b,Aeq,Beq,lb,ub, ...
                  @(x) callExpand(constraintsFun,x,true,2), options);

disp('Found feasible trajectory, optimizing...');
lastTime = timecost(optimal, sp);
fprintf('Starting trajectory has time of: %f\n', lastTime);

% Optimize the trajectory with respect to time
[optimal,time,flag,~] = fmincon(@(x) timecost(x,sp),optimal,A,b,...
         Aeq, Beq, lb, ub, @(x) constraints(x, sp), options);
fprintf('Best time: %f\n', lastTime);
fprintf('Finished in %f seconds\n', toc);
visualize