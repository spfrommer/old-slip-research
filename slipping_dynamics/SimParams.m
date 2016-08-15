classdef SimParams < handle
    properties
        phases = 1;         % Number of phases (steps)
        gridN = 10;         % Number of grid points during stance phase
        camfollow = false;  % Whether camera should follow the hip
        masship = 10;       % Mass of body in kilograms
        masstoe = 2;        % Mass of the toe in kilograms
        spring = 400;       % Spring coefficient
        damp = 1;           % Damping coefficient
        gravity = 9.81;     % Gravity (m/s^2)
        friction = 0;       % Friction coefficient between toe and ground
        minlen = 0.1;       % Minimum length of the leg (m)
        maxlen = 2;         % Maximum length of the leg (m)
    end
end

