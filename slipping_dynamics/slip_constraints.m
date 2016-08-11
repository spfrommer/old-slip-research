function [ c, ceq ] = slip_constraints( params )
    global gridN masship masstoe spring damp gravity friction
    
    % No nonlinear inequality constraint needed
    c = [];
    % Calculate the timestep
    sim_time = params(1);
    delta_time = sim_time / gridN;
    
    % Unpack the vector
    [xtoe, xtoedot, x, xdot, y, ydot, ra, radot, raddot, hiptorque] = ...
        unpack(params);
    
    % Preallocate the nonlinear equality constraint vector
    ceq = zeros(8 * (gridN - 1), 1);
    
    x_n = [xtoe(1); xtoedot(1); x(1);  xdot(1); ...
           y(1);    ydot(1);    ra(1); radot(1)];
    xdot_n = dynamics(x_n, raddot(1), hiptorque(1));
    for i = 1 : gridN - 1
        % The state at the beginning of the time interval
        x_i = x_n;
        % What the state should be at the end of the time interval
        x_n = [xtoe(i+1); xtoedot(i+1); x(i+1);  xdot(i+1); ...
               y(i+1);    ydot(i+1);    ra(i+1); radot(i+1)];
        % The state derivative at the beginning of the time interval
        xdot_i = xdot_n;
        % The state derivative at the end of the time interval
        xdot_n = dynamics(x_n, raddot(i+1), hiptorque(i+1));

        % The end position of the time interval calculated using quadrature
        xend = x_i + delta_time * (xdot_i + xdot_n) / 2;
        % Constrain the end state of the current time interval to be
        % equal to the starting state of the next time interval
        ceq((i-1)*8+1 : i*8) = x_n - xend;
    end
    % Add initial constraints
    ceq = [ceq; x(1); xdot(1); y(1)-1; ydot(1); xtoe(1); xtoedot(1)];
    % Add end constraints
    ceq = [ceq; y(end)-2; xtoe(end); xtoedot(end)];
end