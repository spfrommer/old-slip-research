function [ c, ceq ] = constraints( funparams, sp )
    % Phase inequality constraints
    phaseIC = sym('pic', [1, 3*sp.gridn*size(sp.phases, 1)])';
     
    % Phase equality constraints
    phaseEC = sym('pec', [1, 8*(sp.gridn-1)*size(sp.phases, 1)])';
    % Phase transition equality constraints
    transEC = sym('tec', [1, 8*(size(sp.phases, 1)-1)])';
    
    % Unpack the parameter vector
    [ stanceT, flightT, xtoe, xtoedot, x, xdot, y, ydot, ...
           ra, radot, raddot, torque] = unpack(funparams, sp);
    
    % Iterate over all the phases
    for p = 1 : size(sp.phases, 1)
        phaseStr = sp.phases(p, :);
        % The index of the first dynamics variable for the current phase
        ps = (p - 1) * sp.gridn + 1;
        
        % Calculate the timestep for that specific phase
        dt = stanceT(p) / sp.gridn;
        
        % Take off state at the end of the last phase
        if p > 1
            toState = stateN;
            toCompvars = compvarsN;
        end
        
        stateN = [xtoe(ps); xtoedot(ps); x(ps);  xdot(ps);   ...
                  y(ps);    ydot(ps);    ra(ps); radot(ps)];
        
        % Link ballistic trajectory from end of last phase to this phase
        if p > 1
            rland = sqrt((x(ps) - xtoe(ps))^2 + y(ps)^2);
            
            [xtoedotland, xland, xdotland, yland, ydotland] = ...
                ballistic(toState, flightT(p-1), sp, phaseStr);
            % Grf must equal zero at takeoff
            transEC((p-2)*8+1 : (p-1)*8) = ...
                    [xtoedotland-xtoedot(ps); xland-x(ps); ...
                    xdotland-xdot(ps); yland-y(ps); ydotland-ydot(ps); ...
                    ra(ps) - rland; radot(ps); toCompvars.grf];
        end
            
        % Offset in the equality parameter vector due to phase
        pecOffset = 8 * (sp.gridn - 1) * (p - 1);
        % Offset in the inequality parameter vector due to phase
        picOffset = 3 * (sp.gridn) * (p - 1);
        
        [statedotN, compvarsN] = dynamics(stateN, raddot(ps), ...
                                          torque(ps), sp, phaseStr);
        for i = 1 : sp.gridn - 1
            % The state at the beginning of the time interval
            stateI = stateN;
            % What the state should be at the end of the time interval
            stateN = [xtoe(ps+i); xtoedot(ps+i); x(ps+i);  xdot(ps+i); ...
                      y(ps+i);    ydot(ps+i);    ra(ps+i); radot(ps+i)];
            % The state derivative at the beginning of the time interval
            statedotI = statedotN;
            % Some calculated variables at the beginning of the interval
            compvarsI = compvarsN;
            % The state derivative at the end of the time interval
            [statedotN, compvarsN] = ...
                dynamics(stateN, raddot(ps+i), torque(ps+i), sp, phaseStr);

            % The end position of the time interval calculated using quadrature
            endState = stateI + dt * (statedotI + statedotN) / 2;
            %endState = stateI + dt * statedotN;
            
            % Constrain the end state of the current time interval to be
            % equal to the starting state of the next time interval
            phaseEC(pecOffset+(i-1)*8+1:pecOffset+i*8) = stateN - endState;
            % Constrain the length of the leg, grf, and body y pos
            phaseIC(picOffset+(i-1)*3+1 : picOffset+i*3) = ...
                    [compvarsI.r - sp.maxlen; sp.minlen - compvarsI.r; ...
                     -compvarsI.grf];
        end
        
        if p == size(sp.phases, 1)
            % Constrain the length of the leg at the end position
            % Since it's the end of the past phase, add grf constraint
            phaseIC(picOffset+(sp.gridn-1)*3+1:picOffset+sp.gridn*3) = ...
                [compvarsN.r - sp.maxlen; sp.minlen - compvarsN.r; -compvarsN.grf];
        else 
            % Constrain the length of the leg at the end position
            % No ground reaction force constraint (this will be handled in
            % transition equality constraints)
            phaseIC(picOffset+(sp.gridn-1)*3+1:picOffset+sp.gridn*3) = ...
                [compvarsN.r - sp.maxlen; sp.minlen - compvarsN.r; -1];
        end
    end
    
    c = phaseIC;
    ceq = [phaseEC; transEC];
    % Add first phase start constraints
    %ceq = [ceq; xtoe(1)-0.1; x(1)-0.1; xdot(1); y(1)-1; ...
    %            ydot(1); ra(1) - 1; radot(1)];
    r1 =  sqrt((x(1) - xtoe(1))^2 + y(1)^2);
    ceq = [ceq; x(1) - 0.5; xdot(1); ydot(1); ra(1) - r1; radot(1)];
    % Add lastphase end constraints
    ceq = [ceq; x(end) - 1.5; xtoe(end) - 1.5];
end