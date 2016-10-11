function [ perturbed ] = perturb( funparams, sp )
% Adds small random changes to the hip torques and actuated length ddots
[ stanceT, flightT, xtoe, x, xdot, y, ydot, ...
           ra, radot, raddot] = unpack(funparams, sp);
perturbed = [stanceT; flightT; xtoe; x; xdot; y; ydot; ra; radot;
             raddot + (rand(sp.gridn*length(sp.phases), 1) - 0.5) * 0.001];
end

