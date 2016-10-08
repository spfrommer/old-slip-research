classdef SimParams < handle
    properties
        % Order of phases (sli=slip, stl=stick left side of patch, str =
        % stick right side of patch
        phases = ['str'; 'str'; 'str']; 
        slipPatch = [0 0];  % The region of slippery terrain
        gridn = 10;         % Number of grid points during stance phase
        camFollow = true;   % Whether camera should follow the hip
        masship = 1;        % Mass of body in kilograms
        masstoe = 0.1;      % Mass of the toe in kilograms
        spring = 20;        % Spring coefficient
        damp = 0.5;         % Damping coefficient
        gravity = 9.81;     % Gravity (m/s^2)
        % Friction coefficient between toe and ground on slippery surfaces
        friction = 0.05;     
        dt = 0.01;          % Time step for visualization

        mintime = 0.1;      % Minimum stance phase time
        maxtime = 5;        % Maximum stance phase time
        minraddot = -100;   % Minimum second derivative of actuated length
        maxraddot = 100;    % Maximum second derivative of actuated length
        mintorque = -100;   % Minimum torque at hip
        maxtorque = 100;    % Maximum torque at hip

        minlen = 0.5;       % Minimum length of the leg (m)
        maxlen = 1;         % Maximum length of the leg (m)
    end
end

