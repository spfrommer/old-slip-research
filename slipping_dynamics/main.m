sp = SimParams();

runTimes = [];
for run=1:20
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

    bestTime = Inf; 
    allTimes = [];

    for i = 1:20
        r = rand() * 2;
        x0 = ones(length(sp.phases)+sp.gridn*length(sp.phases)*10,1) * r;
        fprintf('Trying: %f\n', r);
        % First find any feasible trajectory
        [x,~,flag,~] = fmincon(@(x) constcost(x,sp),x0,A,b,Aeq,Beq,lb,ub, ...
                               @(x) constraints(x,sp), options);
        if flag > 0
            time = timecost(x, sp);
            fprintf('Found legal combo: %f, %f\n', r, time);
            allTimes = [allTimes; r, time];
            if time < bestTime
                bestTime = time;
                optimal = x;
            end
        end
    end

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
    runTimes(run) = lastTime;
    fprintf('Best time: %f\n', lastTime);
    fprintf('Finished in %f seconds\n', toc);
end
visualize