function [ c, ceq ] = slip_constraints( funparams, sp )
    gridN = sp.gridN;
    
    % Preallocate the nonlinear inequality constraint vector
    phaseconstsineq = 4 * (gridN) * sp.phases;
    transconstsineq = 3 * (sp.phases - 1);
    c = zeros(phaseconstsineq + transconstsineq, 1);
    disp(sprintf('Length of c: %d', length(c)));
    
    phaseconstseq = 8 * (sp.gridN - 1) * sp.phases;
    transconstseq = 8 * (sp.phases - 1);
    % Preallocate the nonlinear equality constraint vector
    ceq = zeros(phaseconstseq + transconstseq, 1);    
    disp(sprintf('Length of ceq: %d', length(ceq)));
    
    % Unpack the vector
    [xtoe, xtoedot, x, xdot, y, ydot, ra, radot, raddot, hiptorque] = ...
        unpack(funparams, sp);
    
    % Iterate over all the phases
    for p = 1 : sp.phases
        phasestart = (p - 1) * sp.gridN + 1;
        
        % Calculate the timestep for that specific phase
        sim_time = funparams(p);
        delta_time = sim_time / gridN;
        
        % State at the end of the last phase
        if p > 1
            end_state = state_n;
        end
        
        state_n = [xtoe(phasestart); xtoedot(phasestart); x(phasestart);  xdot(phasestart); ...
                   y(phasestart);    ydot(phasestart);    ra(phasestart); radot(phasestart)];
        
        % Link balistic trajectory from end of last phase to this phase
        if p > 1
            raend = ra(phasestart);
            phiend = mod(atan2(y(phasestart), x(phasestart) - xtoe(phasestart)), 2 * pi);
            [endstate, disc, flight_time] = ballistic_traj(end_state, raend, phiend, sp);
            ceq(phaseconstseq+(p-2)*8+1 : phaseconstseq+(p-1)*8) = ...
                                         endstate - state_n;
            % Constrain ballistic trajectory time to be non complex
            c(phaseconstsineq + 3*(p-2) + 1) = disc * -1;
            % Constrain ballistic trajectory time to be nonnegative
            c(phaseconstsineq + 3*(p-2) + 2) = flight_time * -1;
            % Constrain spring force at tend of last phase to be negative
            c(phaseconstsineq + 3*(p-2) + 3) = compvars_n.fs;
        end
            
        % Offset in the equality parameter vector due to phase
        peqoffset = 8 * (gridN - 1) * (p - 1);
        % Offset in the inequality parameter vector due to phase
        pineqoffset = 4 * (gridN) * (p - 1);
        
        [statedot_n, compvars_n] = dynamics(state_n, raddot(phasestart), ...
                                        hiptorque(phasestart), sp);
        for i = phasestart : phasestart + gridN - 2
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
                dynamics(state_n, raddot(i+1), hiptorque(i+1), sp);

            % The end position of the time interval calculated using quadrature
            stateend = state_i + delta_time * (statedot_i + statedot_n) / 2;
            
            % Constrain the end state of the current time interval to be
            % equal to the starting state of the next time interval
            ceq(peqoffset+(i-1)*8+1 : peqoffset+i*8) = state_n - stateend;
            
            % Constrain the length of the leg & spring force
            c(pineqoffset+(i-1)*4+1 : pineqoffset+i*4) = ...
                [compvars_i.r-sp.maxlen; ...
                 sp.minlen-compvars_i.r; -compvars_i.fs; ...
                 -y(i)];
        end
        % Constrain the length of the leg at the end position
        % No spring force constraint at end
        c(pineqoffset+(gridN-1)*4+1 : pineqoffset+gridN*4) = ...
                                   [compvars_n.r - sp.maxlen; ...
                                    sp.minlen - compvars_n.r; ...
                                    -1; -y(phasestart+gridN-1)]; 
    end
    % Add first phase start constraints
    ceq = [ceq; x(1); xtoe(1); xtoedot(1); ra(1) - 1; radot(1)];
    % Add lastphase end constraints
    ceq = [ceq; xtoe(end)-2];
end