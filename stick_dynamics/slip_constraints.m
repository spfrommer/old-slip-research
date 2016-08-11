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
        hiptorque] = unpack(x);
    
    % Preallocate the nonlinear equality constraint vector
    ceq = ones(6 * (gridN - 1), 1);
    % The dynamics matrix    
    A = [0 1 0 0 0 0;
        -spring/mass -damp/mass spring/mass damp/mass 0 0;
         0 0 0 1 0 0;
         0 0 0 0 0 0;
         0 0 0 0 0 1;
         0 0 0 0 0 0];
    % The state vector
    x_n = [length(1);    lengthdot(1); ...
           actlength(1); actlengthdot(1); ...
           phi(1);       phidot(1)];
    % Rotational inertia of the point mass around the toe
    toe_inertia_n = mass * length(1)^2;
    B_n = [0; -mass * gravity * sin(phi(1)); 0; actlengthddot(1); 0;
         (-mass * gravity * length(1) * cos(phi(1)) + hiptorque(1)) / (toe_inertia_n)];
    for i = 1 : gridN-1
        toe_inertia_n = mass * length(i+1)^2;
        % The state at the beginning of the time interval, equal to the end
        % state of the last interation
        x_i = x_n;
        % What the state should be at the end of the time interval
        x_n = [length(i+1);    lengthdot(i+1); ...
               actlength(i+1); actlengthdot(i+1); ...
               phi(i+1);       phidot(i+1)];
        B_i = B_n;
        if animate
            mass_x = -cos(phi(i)) * length(i);
            mass_y = sin(phi(i)) * length(i);
            draw_vectors(:, 1, i) = [mass_x; mass_y; ...
                0; -1];
        end
            
        B_n = [0; -mass * gravity * sin(phi(i+1)); 0; actlengthddot(i+1); 0;
            (-mass * gravity * length(i+1) * cos(phi(i+1)) + hiptorque(i+1)) / toe_inertia_n];
        
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