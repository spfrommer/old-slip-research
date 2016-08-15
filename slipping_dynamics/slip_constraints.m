function [ c, ceq ] = slip_constraints( funparams, simparams )
    % Preallocate the nonlinear inequality constraint vector
    phaseconstsineq = 2 * (simparams.gridN) * simparams.phases;
    transconstsineq = simparams.phases - 1;
    c = zeros(phaseconstsineq + transconstsineq, 1);
    
    phaseconstseq = 8 * (simparams.gridN - 1) * simparams.phases;
    transconstseq = 8 * (simparams.phases - 1);
    % Preallocate the nonlinear equality constraint vector
    ceq = zeros(phaseconstseq + transconstseq, 1);    

    % Unpack the vector
    [xtoe, xtoedot, x, xdot, y, ydot, ra, radot, raddot, hiptorque] = ...
        unpack(funparams, simparams);
    
    % Iterate over all the phases
    for p = 1 : simparams.phases
        % Calculate the timestep for that specific phase
        sim_time = funparams(p);
        delta_time = sim_time / simparams.gridN;
        
        % State at the end of the last phase
        if p > 1
            end_state = state_n;
        end
        
        state_n = [xtoe(1); xtoedot(1); x(1);  xdot(1); ...
                   y(1);    ydot(1);    ra(1); radot(1)];
        
        % Link balistic trajectory from end of last phase to this phase
        if p > 1
            raend = ra(1);
            phiend = mod(atan2(y(1), x(1) - xtoe(1)), 2 * pi);
            [endstate, disc] = ballistic_traj(end_state, raend, phiend, simparams);
            ceq(phaseconstseq+(p-2)*8+1 : phaseconstseq+(p-1)*8) = ...
                                         endstate - state_n;
            c(phaseconstsineq + p - 2) = disc * -1;
        end
            
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
            ceq(p*(i-1)*8+1 : p*i*8) = state_n - stateend;
            % Constrain the length of the leg & spring force
            c(p*(i-1)*3+1   : p*i*3) = [compvars_i.r-simparams.maxlen; ...
                                        simparams.minlen-compvars_i.r; ...
                                        -compvars_i.fs];
        end
        % Constrain the length of the leg at the end position
        c(p*(i-1)*3+1 : p*i*3) = [compvars_n.r - simparams.maxlen; ...
                                    simparams.minlen - compvars_n.r; ...
                                    -1]; % No spring force constraint at end
    end
    % Add first phase start constraints
    ceq = [ceq; x(1); y(1) - 1; xtoe(1); xtoedot(1); ra(1) - 1; radot(1)];
    % Add lastphase end constraints
    ceq = [ceq; x(end) - 0.5; y(end) - 1.5; xtoe(end); xtoedot(end)];
end