function [ c, ceq ] = constraints( funparams, sp )
    % Phase inequality constraints
    phaseIC = zeros(4 * sp.gridn * sp.phases, 1);
    % Phase transition inequality constraints
    transIC = zeros(3 * (sp.phases - 1), 1);
    
    % Phase equality constraints
    phaseEC = zeros(8 * (sp.gridn - 1) * sp.phases, 1);
    % Phase inequality constraints
    transEC = zeros(8 * (sp.phases - 1), 1);
    
    % Unpack the parameter vector
    [phaseT, xtoe, xtoedot, x, xdot, y, ydot, ...
        ra, radot, raddot, torque] = unpack(funparams, sp);
    
    % Iterate over all the phases
    for p = 1 : sp.phases
        % The index of the first dynamics variable for the current phase
        ps = (p - 1) * sp.gridn + 1;
        
        % Calculate the timestep for that specific phase
        dt = phaseT(p) / sp.gridn;
        
        % Take off state at the end of the last phase
        if p > 1
            toState = stateN;
            toCompvars = compvarsN;
        end
        
        stateN = [xtoe(ps); xtoedot(ps); x(ps);  xdot(ps); ...
                  y(ps);    ydot(ps);    ra(ps); radot(ps)];
        
        % Link ballistic trajectory from end of last phase to this phase
        if p > 1
            % The leg angle and length at the end of the transition
            raend = ra(ps);
            phiend = mod(atan2(y(ps), x(ps) - xtoe(ps)), 2 * pi);
            
            [landState, disc, flightT] = ballistic(toState, raend, phiend, sp);
            transEC((p-2)*8+1:(p-1)*8) = landState - stateN;
            % Constrain discriminant to be positive, flight time to be
            % nonnegative, and spring to be noncompressed at takeoff
            transIC((p-2)*3+1:(p-1)*3) = [-disc, -flightT, toCompvars.fs];
            %transIC((p-2)*3+1:(p-1)*3) = [-disc, -flightT, -1];
        end
            
        % Offset in the equality parameter vector due to phase
        pecOffset = 8 * (sp.gridn - 1) * (p - 1);
        % Offset in the inequality parameter vector due to phase
        picOffset = 4 * (sp.gridn) * (p - 1);
        
        [statedotN, compvarsN] = dynamics(stateN, raddot(ps), ...
                                        torque(ps), sp);
        for i = 1 : sp.gridn - 1
            % The state at the beginning of the time interval
            stateI = stateN;
            % What the state should be at the end of the time interval
            stateN = [xtoe(ps+i); xtoedot(ps+i); x(ps+i);  xdot(ps+i); ...
                      y(ps+i);    ydot(ps+i);    ra(ps+i); radot(ps+i)];
            % The state derivative at the beginning of the time interval
            statedotI = statedotN;
            compvarsI = compvarsN;
            % The state derivative at the end of the time interval
            [statedotN, compvarsN] = ...
                dynamics(stateN, raddot(ps+i), torque(ps+i), sp);

            % The end position of the time interval calculated using quadrature
            endState = stateI + dt * (statedotI + statedotN) / 2;
            
            % Constrain the end state of the current time interval to be
            % equal to the starting state of the next time interval
            phaseEC(pecOffset+(i-1)*8+1:pecOffset+i*8) = stateN - endState;
            % Constrain the length of the leg, spring force, and head y pos
            phaseIC(picOffset+(i-1)*4+1 : picOffset+i*4) = ...
                    [compvarsI.r - sp.maxlen; sp.minlen - compvarsI.r; ...
                     -compvarsI.fs; -stateI(5)];
        end
        % Constrain the length of the leg at the end position
        % No spring force constraint at end
        phaseIC(picOffset+(sp.gridn-1)*4+1:picOffset+sp.gridn*4) = ...
                [compvarsN.r - sp.maxlen; sp.minlen - compvarsN.r; ...
                 -1; -stateN(5)];
    end
    
    c = [phaseIC; transIC];
    ceq = [phaseEC; transEC];
    % Add first phase start constraints
    ceq = [ceq; xtoe(1); xtoedot(1); x(1); xdot(1); ydot(1); ra(1) - 1; radot(1)];
    % Add lastphase end constraints
    ceq = [ceq; xtoe(end)-8; x(end)-8];
end