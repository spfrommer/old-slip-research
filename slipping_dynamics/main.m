sp = SimParams();

tic
% The initial parameter guess; 1 second/phase, gridn lengths, gridn lengthdots,
% gridn actuated lengths, gridn actlengthdots, gridn actlengthddots (input),
% gridn leg angles, gridn leg angle dots, gridn hip torques, gridn toe x,
% gridn toe xdot
x0 = ones(length(sp.phases)+sp.gridn*length(sp.phases)*10,1) * 1;

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

% First find any feasible trajectory
[optimal,~,flag,~] = fmincon(@(x) constcost(x,sp),x0,A,b,Aeq,Beq,lb,ub, ...
                             @(x) constraints(x,sp), options);
if flag ~= 1
    disp('No feasible trajectory found!');
else
    disp('Found feasible trajectory, optimizing...');
    lastTime = timecost(optimal, sp);
    fprintf('Starting trajectory has time of: %f\n', lastTime);
    lastOpt = optimal;
    while true
        % Optimize the trajectory with respect to time
        [optimal,time,flag,~] = fmincon(@(x) timecost(x,sp),optimal,A,b,...
                 Aeq, Beq, lb, ub, @(x) constraints(x, sp), options);
        if flag <= 0
            fprintf('Optimizer did not find local minimum, exiting with flag: %d\n', flag);
            break;
        end
        if lastTime - time < 1e-7
            disp('Optimizer returned no benefit, exiting');
            break;
        end
        lastTime = time;
        lastOpt = optimal;
        fprintf('Found better trajectory with time: %f\n', time);
    end
    optimal = lastOpt;
    fprintf('Best time: %f\n', lastTime);
end
fprintf('Finished in %f seconds\n', toc);
visualize