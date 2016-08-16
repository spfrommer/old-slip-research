function [ c, ceq ] = slip_constraints( funparams, sp )
    % Phase inequality constraints
    phase_ic = zeros(4 * sp.gridN * sp.phases, 1);
    % Phase transition inequality constraints
    trans_ic = zeros(3 * (sp.phases - 1), 1);
    
    % Phase equality constraints
    phase_ec = zeros(8 * (sp.gridN - 1) * sp.phases, 1);
    % Phase inequality constraints
    trans_ec = zeros(8 * (sp.phases - 1), 1);
    
    % Unpack the parameter vector
    [xtoe, xtoedot, x, xdot, y, ydot, ra, radot, raddot, hiptorque] = ...
        unpack(funparams, sp);
    
    % Iterate over all the phases
    for p = 1 : sp.phases
        % The index of the first dynamics variable for the current phase
        ps = (p - 1) * sp.gridN + 1;
        
        % Calculate the timestep for that specific phase
        sim_time = funparams(p);
        delta_time = sim_time / sp.gridN;
        
        % Take off state at the end of the last phase
        if p > 1
            to_state = state_n;
            to_compvars = compvars_n;
        end
        
        state_n = [xtoe(ps); xtoedot(ps); x(ps);  xdot(ps); ...
                   y(ps);    ydot(ps);    ra(ps); radot(ps)];
        
        % Link ballistic trajectory from end of last phase to this phase
        if p > 1
            % The leg angle and length at the end of the transition
            raend = ra(ps);
            phiend = mod(atan2(y(ps), x(ps) - xtoe(ps)), 2 * pi);
            
            [land_state, disc, flight_t] = ballistic_traj(to_state, raend, phiend, sp);
            trans_ec((p-2)*8+1:(p-1)*8) = land_state - state_n;
            % Constrain discriminant to be positive, flight time to be
            % nonnegative, and spring to be noncompressed at takeoff
            %trans_ic((p-2)*3+1:(p-1)*3) = [-disc, -flight_t, to_compvars.fs];
            trans_ic((p-2)*3+1:(p-1)*3) = [-disc, -flight_t, -1];
        end
            
        % Offset in the equality parameter vector due to phase
        pec_offset = 8 * (sp.gridN - 1) * (p - 1);
        % Offset in the inequality parameter vector due to phase
        pic_offset = 4 * (sp.gridN) * (p - 1);
        
        [statedot_n, compvars_n] = dynamics(state_n, raddot(ps), ...
                                        hiptorque(ps), sp);
        for i = 1 : sp.gridN - 1
            % The state at the beginning of the time interval
            state_i = state_n;
            % What the state should be at the end of the time interval
            state_n = [xtoe(ps+i); xtoedot(ps+i); x(ps+i);  xdot(ps+i); ...
                       y(ps+i);    ydot(ps+i);    ra(ps+i); radot(ps+i)];
            % The state derivative at the beginning of the time interval
            statedot_i = statedot_n;
            compvars_i = compvars_n;
            % The state derivative at the end of the time interval
            [statedot_n, compvars_n] = ...
                dynamics(state_n, raddot(ps+i), hiptorque(ps+i), sp);

            % The end position of the time interval calculated using quadrature
            stateend = state_i + delta_time * (statedot_i + statedot_n) / 2;
            
            % Constrain the end state of the current time interval to be
            % equal to the starting state of the next time interval
            phase_ec(pec_offset+(i-1)*8+1:pec_offset+i*8) = state_n - stateend;
            
            % Constrain the length of the leg, spring force, and head y pos
            phase_ic(pic_offset+(i-1)*4+1:pic_offset+i*4) = ...
                [compvars_i.r - sp.maxlen; sp.minlen - compvars_i.r; ...
                 -compvars_i.fs; -state_n(5)];
        end
        % Constrain the length of the leg at the end position
        % No spring force constraint at end
        phase_ic(pic_offset+(sp.gridN-1)*4+1:pic_offset+sp.gridN*4) = ...
            [compvars_n.r - sp.maxlen; sp.minlen - compvars_n.r; ...
             -1; -y(ps+sp.gridN-1)];
    end
    
    c = [phase_ic; trans_ic];
    ceq = [phase_ec; trans_ec];
    % Add first phase start constraints
    ceq = [ceq; xtoe(1); xtoedot(1); x(1); y(1)-1; ra(1) - 1; radot(1)];
    % Add lastphase end constraints
    ceq = [ceq; xtoe(end); xtoedot(end); x(end)+0.5; y(end)-0.5];
end