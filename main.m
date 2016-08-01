global gridN mass hip_inertia spring damp gravity r0
gridN = 20;
mass = 10;
hip_inertia = 1;
spring = 50;
damp = 3;
gravity = 9.81;
r0 = 1;

tic

% Minimize time of trajectory
timemin = @(x) x(1);

% Simulation time
% Each state: r, rdot, ra, radot, phi, phidot, theta, thetadot
% Each input: acceleration of neutral leg length, hip torque
x0 = [1; ones(gridN * 10, 1)];
% No linear inequality or equality constraints
A = [];
b = [];
Aeq = [];
Beq = [];
% Lower bound the simulation time at zero seconds
lb = [0;   ones(gridN*2, 1) * 0 ;  ones(gridN*2, 1) * -Inf; ...
           ones(gridN, 1) * -1  ; ones(gridN, 1) * -Inf; ...
           ones(gridN, 1) * -1  ; ones(gridN, 1) * -Inf; ...
           ones(gridN, 1) * -100; ones(gridN, 1) * -100];
ub = [Inf; ones(gridN*2, 1) * r0;  ones(gridN*2, 1) * Inf; ...
           ones(gridN, 1) * 1   ; ones(gridN, 1) * Inf; ...
           ones(gridN, 1) * 1   ; ones(gridN, 1) * Inf; ...
           ones(gridN, 1) * 101; ones(gridN, 1) * 100];
% Options for fmincon
options = optimset('TolFun', 0.00000001, 'MaxIter', 100000, ...
                   'MaxFunEvals', 1000000);
% Solve for the best simulation time + control input
optimal = fmincon(time_min, x0, A, b, Aeq, Beq, lb, ub, ...
              @slip_constraints, options);

% Discretize the times
sim_time = optimal(1);
delta_time = sim_time / gridN;
times = 0 : delta_time : sim_time - delta_time;

r         = optimal(2             : 1 + gridN);
rdot      = optimal(2 + gridN     : 1 + gridN * 2);
ra        = optimal(2 + gridN * 2 : 1 + gridN * 3);
radot     = optimal(2 + gridN * 3 : 1 + gridN * 4);
phi       = optimal(2 + gridN * 4 : 1 + gridN * 5);
phidot    = optimal(2 + gridN * 5 : 1 + gridN * 6);
theta     = optimal(2 + gridN * 6 : 1 + gridN * 7);
thetadot  = optimal(2 + gridN * 7 : 1 + gridN * 8);
raddot    = optimal(2 + gridN * 8 : 1 + gridN * 9);
hiptorque = optimal(2 + gridN * 9 : 1 + gridN * 10);

% Make the plots
figure();
plot(times, r);
title('R');
xlabel('Time (s)');
ylabel('Length of leg');
figure();
plot(times, rdot);
title('Rdot');
xlabel('Time (s)');
ylabel('Time derivative of leg length');
figure();
plot(times, ra);
title('Ra');
xlabel('Time (s)');
ylabel('Actuated leg length');
figure();
plot(times, radot);
title('Radot');
xlabel('Time (s)');
ylabel('Time derivative of actuated leg length');
figure();
plot(times, phi);
title('Phi');
xlabel('Time (s)');
ylabel('Leg angle with ground');
figure();
plot(times, phidot);
title('Phidot');
xlabel('Time (s)');
ylabel('Time derivative of leg angle with ground');
figure();
plot(times, theta);
title('Theta');
xlabel('Time (s)');
ylabel('Hip displacement angle');
figure();
plot(times, thetadot);
title('Thetadot');
xlabel('Time (s)');
ylabel('Time derivative of hip displacement angle');
figure();
plot(times, raddot);
title('Raddot');
xlabel('Time (s)');
ylabel('Double time derivative of actuated leg length');
figure();
plot(times, hiptorque);
title('Hip torque');
xlabel('Time (s)');
ylabel('Hip torque');

disp(sprintf('Finished in %f seconds', toc));