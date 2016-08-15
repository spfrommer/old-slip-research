simparams = SimParams();

tic
% Minimize the square of the simulation time
time_min = @(x) x(1)^2;
% The initial parameter guess; 1 second/phase, gridN lengths, gridN lengthdots,
% gridN actuated lengths, gridN actlengthdots, gridN actlengthddots (input),
% gridN leg angles, gridN leg angle dots, gridN hip torques, gridN toe x,
% gridN toe xdot
if exist('optimal','var')
    disp('Using previous solution as starting guess...');
    x0 = optimal;
else
    x0 = ones(simparams.gridN*simparams.phases*10 + simparams.phases,1);
end
% No linear inequality or equality constraints
A = [];
b = [];
Aeq = [];
Beq = [];
% Set up the bounds
[lb, ub] = bounds(simparams); 
% Options for fmincon
options = optimoptions(@fmincon, 'TolFun', 0.00000001, 'MaxIter', 10000, ...
                       'MaxFunEvals', 1000000, 'Display', 'iter', ...
                       'DiffMinChange', 0.0001, 'Algorithm', 'sqp', ...
                       'StepTolerance', 1e-13);
% Solve the optimization problem
optimal = fmincon(time_min, x0, A, b, Aeq, Beq, lb, ub, ...
                  @(x) slip_constraints(x, simparams), options);
disp(sprintf('Finished in %f seconds', toc));
visualize