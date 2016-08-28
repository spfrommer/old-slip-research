sp = SimParams();

tic
% The initial parameter guess; 1 second/phase, gridn lengths, gridn lengthdots,
% gridn actuated lengths, gridn actlengthdots, gridn actlengthddots (input),
% gridn leg angles, gridn leg angle dots, gridn hip torques, gridn toe x,
% gridn toe xdot
if exist('optimal','var')
    disp('Using previous solution as starting guess...');
    x0 = optimal;
else
    x0 = ones(length(sp.phases)+sp.gridn*length(sp.phases)*10,1);
end
% No linear inequality or equality constraints
A = [];
b = [];
Aeq = [];
Beq = [];
% Set up the bounds
[lb, ub] = bounds(sp); 
% Options for fmincon
options = optimoptions(@fmincon, 'TolFun', 0.00000001, ...
                       'MaxIterations', 10000, ...
                       'MaxFunEvals', 1000000, ...
                       'Display', 'iter', 'Algorithm', 'sqp', ...
                       'StepTolerance', 1e-13);

% Solve the optimization problem
optimal = fmincon(@(x) timecost(x, sp), x0, A, b, Aeq, Beq, lb, ub, ...
                  @(x) constraints(x, sp), options);
disp(sprintf('Finished in %f seconds', toc));
visualize