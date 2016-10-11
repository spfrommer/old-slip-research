function [ xland, xdotland, yland, ydotland ] = ...
    ballistic( toState, flightTime, sp )

stateCell = num2cell(toState');
[~, x, xdot, y, ydot, ~, ~] = deal(stateCell{:});

xland = x + xdot * flightTime;
yland = y + ydot * flightTime - 0.5 * sp.gravity * flightTime^2;
xdotland = xdot;
ydotland = ydot - sp.gravity * flightTime;

end

