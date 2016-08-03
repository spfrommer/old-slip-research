global gridN mass spring damp gravity
gridN = 20;
mass = 10;
spring = 50;
damp = 1;
gravity = 9.81;

tic
% Minimize the simulation time
time_min = @(x) x(1)^2;
% The initial parameter guess; 1 second, fifty lengths, fifty lengthdirs,
% fifty actuated lengths, fifty actlengthdirs, fifty actlengthddirs,
% fifty leg angles, fifty leg angle dirs, fifty hip torques
if exist('optimal','var')
    disp('Using previous solution as starting guess...');
    x0 = optimal;
else
    x0 = [1; ones(gridN * 2, 1); ones(gridN * 3, 1); ones(gridN * 3, 1)];
end
% No linear inequality or equality constraints
A = [];
b = [];
Aeq = [];
Beq = [];
% Lower bound the simulation time at zero seconds, and bound the
% accelerations between -10 and 30
lb = [0;   ones(gridN, 1) * 0;    ones(gridN * 3, 1) * -Inf; ones(gridN, 1) * -5000;
           ones(gridN, 1) * -Inf; ones(gridN, 1) * -Inf;     ones(gridN, 1) * -250];
ub = [Inf; ones(gridN, 1) * 1;    ones(gridN * 3, 1) * Inf;  ones(gridN, 1) * 5000;
           ones(gridN, 1) * Inf;  ones(gridN, 1) * Inf;      ones(gridN, 1) * 250];
% Options for fmincon
options = optimoptions(@fmincon, 'TolFun', 0.00000001, 'MaxIter', 10000, ...
                       'MaxFunEvals', 1000000, 'Display', 'iter', ...
                       'DiffMinChange', 0.000001, 'Algorithm', 'sqp');
% Solve for the best simulation time + control input
optimal = fmincon(time_min, x0, A, b, Aeq, Beq, lb, ub, ...
              @spring_mass_constraints, options);

% Discretize the times
sim_time = optimal(1);
delta_time = sim_time / gridN;
times = 0 : delta_time : sim_time - delta_time;
% Get the state + accelerations (control inputs) out of the vector
lengths         = optimal(2             : 1 + gridN);
lengthdirs      = optimal(2 + gridN     : 1 + gridN * 2);
actlengths      = optimal(2 + gridN * 2 : 1 + gridN * 3);
actlengthdirs   = optimal(2 + gridN * 3 : 1 + gridN * 4);
actlengthddirs  = optimal(2 + gridN * 4 : 1 + gridN * 5);
phis            = optimal(2 + gridN * 5 : 1 + gridN * 6);
phidirs         = optimal(2 + gridN * 6 : 1 + gridN * 7);
hiptorques      = optimal(2 + gridN * 7 : end);

[c, ceq] = spring_mass_constraints(optimal);

fig = figure(1);
set(fig, 'Position', [100, 200, 600, 550]);
toolbar = uitoolbar(fig);
% Prevent clf from clearing the toolbar
toolbar.HandleVisibility = 'off';
% Read an image
[img,map] = imread('rewind.gif');
p = uipushtool(toolbar, 'TooltipString', 'Replay animation', ...
                               'ClickedCallback', 'render(sim_time, lengths, phis)');
icon = ind2rgb(img, map);
p.CData = icon;

render(sim_time, lengths, phis);
pause(3);
if true
    % Make the plots
    figure(2);
    plot(times, actlengths);
    title('Actuated Length vs Time');
    xlabel('Time (s)');
    ylabel('Actuated Length (m)');
    figure(3);
    plot(times, actlengthdirs);
    title('Actuated Length Derivatives vs Time');
    xlabel('Time (s)');
    ylabel('Actuated Length Derivative');
    figure(4);
    plot(times, actlengthddirs);
    title('Actuated Length Second Derivatives vs Time');
    xlabel('Time (s)');
    ylabel('Actuated Length Second Derivatives');
    figure(5);
    plot(times, lengthdirs);
    title('Length Derivatives vs Time');
    xlabel('Time (s)');
    ylabel('Length Derivative (m/s)');
    figure(6);
    plot(times, lengths);
    title('Length vs Time');
    xlabel('Time (s)');
    ylabel('Length (m)');
    figure(7);
    plot(times, phis);
    title('Phi');
    xlabel('Time (s)');
    ylabel('Leg angle with ground');
    figure(8);
    plot(times, phidirs);
    title('Phidot');
    xlabel('Time (s)');
    ylabel('Time derivative of leg angle with ground');
    figure(9);
    plot(times, hiptorques);
    title('Hip torques');
    xlabel('Time (s)');
    ylabel('Torques at the hip');
end

disp(sprintf('Finished in %f seconds', toc));