function [ c, ceq ] = slip_constraints( funparams, simparams )
    % Calculate the timestep
    sim_time = funparams(1);
    delta_time = sim_time / simparams.gridN;
    
    % Unpack the vector
    [xtoe, xtoedot, x, xdot, y, ydot, ra, radot, raddot, hiptorque] = ...
        unpack(funparams, simparams);
    
    % Preallocate the nonlinear inequality constraint vector
    c = zeros(2 * (simparams.gridN), 1);
    % Preallocate the nonlinear equality constraint vector
    ceq = zeros(8 * (simparams.gridN - 1), 1);
    
    state_n = [xtoe(1); xtoedot(1); x(1);  xdot(1); ...
           y(1);    ydot(1);    ra(1); radot(1)];
    [statedot_n, compvars_n] = dynamics(state_n, raddot(1), hiptorque(1), simparams);
    for i = 1 : simparams.gridN - 1
        % The state at the beginning of the time interval
        state_i = state_n;
        % What the state should be at the end of the time interval
        state_n = [xtoe(i+1); xtoedot(i+1); x(i+1);  xdot(i+1); ...
               y(i+1);    ydot(i+1);    ra(i+1); radot(i+1)];
        % The state derivative at the beginning of the time interval
        statedot_i = statedot_n;
        compvars_i = compvars_n;
        % The state derivative at the end of the time interval
        [statedot_n, compvars_n] = ...
            dynamics(state_n, raddot(i+1), hiptorque(i+1), simparams);

        % The end position of the time interval calculated using quadrature
        stateend = state_i + delta_time * (statedot_i + statedot_n) / 2;
        % Constrain the end state of the current time interval to be
        % equal to the starting state of the next time interval
        ceq((i-1)*8+1 : i*8) = state_n - stateend;
        % Constrain the length of the leg
        c((i-1)*2+1   : i*2) = [compvars_i.r - simparams.maxlen; ...
                                simparams.minlen - compvars_i.r];
    end
    % Constrain the length of the leg at the end position
    c((i-1)*2+1   : i*2) = [compvars_n.r - simparams.maxlen; ...
                            simparams.minlen - compvars_n.r];
    % Add initial constraints
    ceq = [ceq; x(1); xdot(1); y(1)-1; ydot(1); ...
           xtoe(1); xtoedot(1); ra(1)-1; radot(1)];
    % Add end constraints
    ceq = [ceq; x(end)-0.5; y(end)-1.5; xtoe(end); xtoedot(end)];
end