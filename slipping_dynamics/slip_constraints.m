function [ c, ceq ] = slip_constraints( x, animate )
    global gridN mass spring damp gravity
    
    % No nonlinear inequality constraint needed
    c = [];
    % Calculate the timestep
    sim_time = x(1);
    delta_time = sim_time / gridN;
    
    if ~exist('animate', 'var')
        animate = false;
    end
    
    if animate
        draw_vectors = zeros(4, 1, gridN - 1);
    end
        
    % Unpack the vector
    [length, lengthdot, actlength, actlengthdot, actlengthddot, phi, phidot, ...
        hiptorque, toex, toexdot] = unpack(x);
    
    % Preallocate the nonlinear equality constraint vector
    ceq = ones(6 * (gridN - 1), 1);
    for i = 1 : gridN-1
        toe_inertia_i = mass * length(i);
        % The state at the beginning of the time interval
        x_i = [length(i);    lengthdot(i); ...
               actlength(i); actlengthdot(i); ...
               phi(i);       phidot(i); ...
               toex(i);      toexdot(i)];
        % What the state should be at the end of the time interval
        x_n = [length(i+1);    lengthdot(i+1); ...
               actlength(i+1); actlengthdot(i+1); ...
               phi(i+1);       phidot(i+1); ...
               toex(i+1);      toexdot(i+1)];
        
        if animate
            mass_x = -cos(phi(i)) * length(i);
            mass_y = sin(phi(i)) * length(i);
            draw_vectors(:, 1, i) = [mass_x; mass_y; ...
                0; -1];
        end
        
        
        % The time derivative of the state at the beginning of the time
        % interval
        xdot_i = A * x_i + B_i;
        % The time derivative of the state at the end of the time interval
        xdot_n = A * x_n + B_n;
        % The end position of the time interval calculated using quadrature
        xend = x_i + delta_time * (xdot_i + xdot_n) / 2;
        % Constrain the end state of the current time interval to be
        % equal to the starting state of the next time interval
        ceq((i-1)*6+1 : i*6) = x_n - xend;
    end
    if animate
        assignin('base', 'draw_vectors', draw_vectors);
    end
    % Add initial constraints
    ceq = [ceq; length(1) - 1; lengthdot(1); actlength(1) - 1; ...
           actlengthdot(1); phi(1); phidot(1)];
    % Add end constraints
    ceq = [ceq; sin(phi(end)) - 1; length(end) - 0.1];
end