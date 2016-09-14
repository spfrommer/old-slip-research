function [ landState, disc, flightTime ] = ...
    ballistic( toState, raend, cphiend, sphiend, sp, curPhase )
% Calculates end state xend after flight with xstart state and a desired
% touchdown angle cos of phiend and touchdown angle sin of phiend
% with desired touchdown length of raend
stateCell = num2cell(toState');
[~, ~, x, xdot, y, ydot, ~, ~] = deal(stateCell{:});
yend = raend * sphiend;
disc = ydot^2 - 2 * sp.gravity * (yend - y);
% Avoid returning complex results
flightTime = (-1/sp.gravity) * (-ydot - sqrt(disc));

xend = x + flightTime * xdot;
xdotend = xdot;
ydotend = ydot - sp.gravity * flightTime;
xtoeend = xend - raend * cphiend;
if strcmp(curPhase, 'sli')
    xtoedotend = xdotend;
else
    xtoedotend = 0;
end
radotend = 0;
landState = [xtoeend; xtoedotend; xend; xdotend; ...
            yend; ydotend; raend; radotend];
end

