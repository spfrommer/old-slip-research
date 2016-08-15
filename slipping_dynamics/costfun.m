function [ time ] = costfun( funparams, simparams )
    % Integrate the time for each phase
    time = sum(funparams(1:simparams.phases));
    
    if simparams.phases > 1
        % Unpack the vector
        [xtoe, xtoedot, x, xdot, y, ydot, ra, radot, ~, ~] = ...
            unpack(funparams, simparams);
        for p = 2 : simparams.phases            
            phasestart = (p - 1) * simparams.gridN + 1;
            end_state = [xtoe(phasestart-1); xtoedot(phasestart-1); x(phasestart-1);  xdot(phasestart-1); ...
                        y(phasestart-1);    ydot(phasestart-1);    ra(phasestart-1); radot(phasestart-1)];
            raend = ra(phasestart);
            phiend = mod(atan2(y(phasestart), ...
                         x(phasestart) - xtoe(phasestart)), 2 * pi);
            [~, ~, flight_time] = ballistic_traj(end_state, raend, phiend, simparams);
            time = time + flight_time;
        end
    end
    
    time = time^2;
end

