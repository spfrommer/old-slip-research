global gridN mass spring damp gravity
gridN = 40;     % Number of grid points during stance phase
mass = 10;      % Mass of body in kilograms
spring = 50;    % Spring coefficient
damp = 1;       % Damping coefficient
gravity = 9.81; % Gravity (m/s^2)

tic
% Minimize the square of the simulation time
time_min = @(x) x(1)^2;
% The initial parameter guess; 1 second, gridN lengths, gridN lengthdots,
% gridN actuated lengths, gridN actlengthdots, gridN actlengthddots (input),
% gridN leg angles, gridN leg angle dots, gridN hip torques, gridN toe x,
% gridN toe xdot
if exist('optimal','var')
    disp('Using previous solution as starting guess...');
    x0 = optimal;
else
    x0 = ones(gridN * 10 + 1, 1);
end
% No linear inequality or equality constraints
A = [];
b = [];
Aeq = [];
Beq = [];
% Set up the bounds
[lb, ub] = bounds(gridN);
% Options for fmincon
options = optimoptions(@fmincon, 'TolFun', 0.00000001, 'MaxIter', 10000, ...
                       'MaxFunEvals', 1000000, 'Display', 'iter', ...
                       'DiffMinChange', 0.001, 'Algorithm', 'sqp', ...
                       'StepTolerance', 1e-13);
% Solve the optimization problem
optimal = fmincon(time_min, x0, A, b, Aeq, Beq, lb, ub, ...
              @slip_constraints, options);
disp(sprintf('Finished in %f seconds', toc));
visualize