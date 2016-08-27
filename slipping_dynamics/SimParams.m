classdef SimParams < handle
    properties
        phases = ['sl'; 'st'; 'sl']; % Order of phases (sl=slip, st=stick)
        gridn = 10;         % Number of grid points during stance phase
        camFollow = true;   % Whether camera should follow the hip
        masship = 10;       % Mass of body in kilograms
        masstoe = 2;        % Mass of the toe in kilograms
        spring = 400;       % Spring coefficient
        damp = 1;           % Damping coefficient
        gravity = 9.81;     % Gravity (m/s^2)
        friction = 2;       % Friction coefficient between toe and ground
        ballisticdt = 0.03; % Time step during ballistic trajectory

        mintime = 0.1;      % Minimum stance phase time
        maxtime = 5;        % Maximum stance phase time
        minraddot = -100;   % Minimum second derivative of actuated length
        maxraddot = 100;    % Maximum second derivative of actuated length
        mintorque = -100;   % Minimum torque at hip
        maxtorque = 100;    % Maximum torque at hip

        minlen = 0.3;       % Minimum length of the leg (m)
        maxlen = 1;         % Maximum length of the leg (m)
    end
end

