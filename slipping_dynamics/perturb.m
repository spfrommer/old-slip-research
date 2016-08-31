function [ perturbed ] = perturb( funparams, sp )
% Adds small random changes to the hip torques and actuated length ddots
[ phaseT, xtoe, xtoedot, x, xdot, y, ydot, ...
           ra, radot, raddot, torque] = unpack(funparams, sp);
perturbed = [phaseT; xtoe; xtoedot; x; xdot; y; ydot; ra; radot;
             raddot + (rand(sp.gridn*length(sp.phases), 1) - 0.5) * 0.001;
             torque + (rand(sp.gridn*length(sp.phases), 1) - 0.5) * 0.001];
end

