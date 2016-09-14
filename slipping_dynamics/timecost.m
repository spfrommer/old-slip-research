function [ time ] = timecost( funparams, sp )
    % Unpack the vector
    [phaseT, cTdAngle, sTdAngle, xtoe, xtoedot, x, xdot, y, ydot, ra, radot, ~, ~] = ...
        unpack(funparams, sp);
        
    % Integrate the time for each phase
    time = sum(phaseT);
    
    if length(sp.phases) > 1
        for p = 2 : length(sp.phases)         
            phaseStr = sp.phases(p, :);
            ps = (p - 1) * sp.gridn + 1;
            endState = [xtoe(ps-1); xtoedot(ps-1); x(ps-1);  xdot(ps-1); ...
                        y(ps-1);    ydot(ps-1);    ra(ps-1); radot(ps-1)];
            raend = ra(ps);
            [~, ~, flightT] = ballistic(endState, raend, cTdAngle(p-1), sTdAngle(p-1), sp, phaseStr);
            time = time + flightT;
        end
    end
    
    % Add small regularization term to force unique solution
    time = time + norm(funparams)^2 * 1e-11;
end

