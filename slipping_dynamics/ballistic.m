function [ xtoedotland, xland, xdotland, yland, ydotland ] = ...
    ballistic( toState, flightTime, sp, curPhase )

stateCell = num2cell(toState');
[~, ~, x, xdot, y, ydot, ~, ~] = deal(stateCell{:});

if strcmp(curPhase, 'sli')
    xtoedotland = xdot;
else
    xtoedotland = 0;
end
xland = x + xdot * flightTime;
yland = y + ydot * flightTime - 0.5 * sp.gravity * flightTime^2;
xdotland = xdot;
ydotland = ydot - sp.gravity * flightTime;

end

