function [ endstate, disc, flight_time ] = ballistic_traj( startstate, raend, phiend, sp )
% Calculates end state xend after flight with xstart state and a desired
% touchdown angle of phiend with desired touchdown length of raend
statecell = num2cell(startstate');
[xtoe, xtoedot, x, xdot, y, ydot, ra, radot] = deal(statecell{:});
yend = raend * sin(phiend);
disc = ydot^2 - 2 * sp.gravity * (yend - y);
% Avoid returning complex results
if disc >= 0
    flight_time = (-1/sp.gravity) * (-ydot - sqrt(disc));
else
    flight_time = 0;
end
xend = x + flight_time * xdot;
xdotend = xdot;
ydotend = ydot - sp.gravity * flight_time;
xtoeend = xend - raend * cos(phiend);
xtoedotend = xdotend;
radotend = 0;
endstate = [xtoeend; xtoedotend; xend; xdotend; ...
            yend; ydotend; raend; radotend];
end

