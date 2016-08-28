function [ endState, disc, flightTime ] = ...
    ballistic( startState, raend, phiend, sp, curPhase )
% Calculates end state xend after flight with xstart state and a desired
% touchdown angle of phiend with desired touchdown length of raend
stateCell = num2cell(startState');
[~, ~, x, xdot, y, ydot, ~, ~] = deal(stateCell{:});
yend = raend * sin(phiend);
disc = ydot^2 - 2 * sp.gravity * (yend - y);
% Avoid returning complex results
flightTime = (-1/sp.gravity) * (-ydot - real(sqrt(disc)));

xend = x + flightTime * xdot;
xdotend = xdot;
ydotend = ydot - sp.gravity * flightTime;
xtoeend = xend - raend * cos(phiend);
if strcmp(curPhase, 'sli')
    xtoedotend = xdotend;
else
    xtoedotend = 0;
end
radotend = 0;
endState = [xtoeend; xtoedotend; xend; xdotend; ...
            yend; ydotend; raend; radotend];
end

