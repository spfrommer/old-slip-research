function [ c, ceq ] = spring_mass_constraints( x )
    global gridN mass spring damp gravity
    % No nonlinear inequality constraint needed
    c = [];
    % Calculate the timestep
    sim_time = x(1);
    delta_time = sim_time / gridN;
    % Get the states / inputs out of the vector
    lengths         = x(2             : 1 + gridN);
    lengthdirs      = x(2 + gridN     : 1 + gridN * 2);
    actlengths      = x(2 + gridN * 2 : 1 + gridN * 3);
    actlengthdirs   = x(2 + gridN * 3 : 1 + gridN * 4);
    actlengthddirs  = x(2 + gridN * 4 : 1 + gridN * 5);
    phis            = x(2 + gridN * 5 : 1 + gridN * 6);
    phidirs         = x(2 + gridN * 6 : 1 + gridN * 7);
    hiptorques      = x(2 + gridN * 7 : end);
    
    ceq = ones(6 * (gridN - 1), 1);
    for i = 1 : gridN-1
        % The inertia of the mass around the toe, assuming a point mass
        toe_inertia = mass * lengths(i);
        toe_inertia_n = mass * lengths(i+1);
        % The state at the beginning of the time interval
        x_i = [lengths(i); lengthdirs(i); actlengths(i); ...
               actlengthdirs(i); phis(i); phidirs(i)];
        % What the state should be at the end of the time interval
        x_n = [lengths(i+1);    lengthdirs(i+1); ...
               actlengths(i+1); actlengthdirs(i+1); ...
               phis(i+1);       phidirs(i+1)];
        
        A = [0 1 0 0 0 0;
            -spring/mass -damp/mass spring/mass damp/mass 0 0;
             0 0 0 1 0 0;
             0 0 0 0 0 0;
             0 0 0 0 0 1;
             0 0 0 0 0 0];
        Bi = [0; -mass * gravity * sin(phis(i)); 0; actlengthddirs(i); 0;
            (-mass * gravity * cos(phis(i)) + hiptorques(i)) / toe_inertia];
        Bn = [0; -mass * gravity * sin(phis(i+1)); 0; actlengthddirs(i+1); 0;
            (-mass * gravity * cos(phis(i+1)) + hiptorques(i+1)) / toe_inertia_n];
        
        % The time derivative of the state at the beginning of the time
        % interval
        xdot_i = A * x_i + Bi;
        % The time derivative of the state at the end of the time interval
        xdot_n = A * x_n + Bn;
        % The end position of the time interval calculated using quadrature
        xend = x_i + delta_time * (xdot_i + xdot_n) / 2;
        % Constrain the end state of the current time interval to be
        % equal to the starting state of the next time interval
        ceq((i-1)*6+1 : i*6) = x_n - xend;
    end
    % Constrain initial position to be one and velocity to be zero
    ceq = [ceq; lengths(1) - 1; lengthdirs(1); actlengths(1) - 1; actlengthdirs(1); phis(1); phidirs(1)];
    % Constrain end position to 1 and end velocity to 0
    ceq = [ceq; lengths(end) - 0.5; lengthdirs(end); phis(end)-pi/2; phidirs(end)];
end