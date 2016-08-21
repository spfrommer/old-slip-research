function [ time ] = costfun( funparams, sp )
    % Integrate the time for each phase
    time = sum(funparams(1 : sp.phases));
    
    if sp.phases > 1
        % Unpack the vector
        [phase_t, xtoe, xtoedot, x, xdot, y, ydot, ra, radot, ~, ~] = ...
            unpack(funparams, sp);
        for p = 2 : sp.phases            
            phasestart = (p - 1) * sp.gridN + 1;
            end_state = [xtoe(phasestart-1); xtoedot(phasestart-1); x(phasestart-1);  xdot(phasestart-1); ...
                        y(phasestart-1);    ydot(phasestart-1);    ra(phasestart-1); radot(phasestart-1)];
            raend = ra(phasestart);
            phiend = mod(atan2(y(phasestart), ...
                         x(phasestart) - xtoe(phasestart)), 2 * pi);
            [~, ~, flight_time] = ballistic(end_state, raend, phiend, sp);
            time = time - flight_time;
        end
    end
    
    %time = time^2;
end

