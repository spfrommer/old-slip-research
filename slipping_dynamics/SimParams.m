classdef SimParams < handle
    properties
        % Order of phases (sli=slip, stl=stick left side of patch, str =
        % stick right side of patch
        phases = ['sli'; 'stl'; 'str']; 
        slipPatch = [0 2];     % The region of slippery terrain
        gridn = 10;            % Number of grid points during stance phase
        masship = 1;           % Mass of body in kilograms
        masstoe = 0.1;         % Mass of the toe in kilograms
        spring = 20;           % Spring coefficient
        damp = 0.5;            % Damping coefficient
        gravity = 1;           % Gravity
        % Friction coefficient between toe and ground on slippery surfaces
        friction = 0.05;     

        minStanceTime = 0.1;   % Minimum stance phase time
        maxStanceTime = 3;     % Maximum stance phase time
        minFlightTime = 0;     % Minimum flight phase time
        maxFlightTime = 3;     % Maximum flight phase time
        minraddot = -1;        % Minimum second deriv of actuated length
        maxraddot = 1;         % Maximum second deriv of actuated length
        mintorque = -1;        % Minimum torque at hip
        maxtorque = 1;         % Maximum torque at hip

        minlen = 0.5;          % Minimum length of the leg
        maxlen = 1;            % Maximum length of the leg
        
        maxgrf = 10;           % Maximum ground reaction force
    end
    
    methods
    end
end

