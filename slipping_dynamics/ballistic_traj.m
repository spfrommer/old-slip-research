function [ endstate, disc ] = ballistic_traj( startstate, raend, phiend, simparams )
% Calculates end state xend after flight with xstart state and a desired
% touchdown angle of phiend with desired touchdown length of raend
statecell = num2cell(startstate');
[xtoe, xtoedot, x, xdot, y, ydot, ra, radot] = deal(statecell{:});
yend = raend * sin(phiend);
disc = ydot^2 - 2 * simparams.gravity * (yend - y);
flight_time = (-1/simparams.gravity) * (-ydot - sqrt(disc));

xend = x + flight_time * xdot;
xdotend = xdot;
ydotend = ydot - simparams.gravity * flight_time;
xtoeend = xend - raend * cos(phiend);
xtoedotend = xdotend;
radotend = 0;
endstate = [xtoeend; xtoedotend; xend; xdotend; ...
            yend; ydotend; raend; radotend];
end

