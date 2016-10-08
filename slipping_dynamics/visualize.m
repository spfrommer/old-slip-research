% Unpack the vector
[phaseT, cTdAngle, sTdAngle, xtoe, x, xdot, y, ydot, ...
    ra, radot, raddot] = unpack(optimal, sp);
[c, ceq] = constraints(optimal, sp);

% Calculate leg lengths and angles
r = sqrt((x - xtoe).^2 + y.^2);

% Discretize the times for the first phase
times = 0 : phaseT(1)/sp.gridn : phaseT(1);
times = times(1:end-1);

i = sp.gridn + 1;
for p = 1 : size(sp.phases, 1) - 1
    % Interpolate ballistic flight
    disc = ydot(i-1)^2 - 2 * sp.gravity * (y(i) - y(i-1));
    flightTime = (-1/sp.gravity) * (-ydot(i-1) - real(sqrt(disc)));
    time = 0;
    while time < flightTime - sp.dt
        xtoe = [xtoe(1:i-1); xtoe(i-1); xtoe(i:end)];
        x = [x(1:i-1); (x(i-1)+xdot(i-1)*sp.dt); x(i:end)];
        xdot = [xdot(1:i-1); xdot(i-1); xdot(i:end)];
        y = [y(1:i-1); (y(i-1)+ydot(i-1)*sp.dt); y(i:end)];
        ydot = [ydot(1:i-1); (ydot(i-1)-sp.gravity*sp.dt); ydot(i:end)];

        r = [r(1:i-1); 0; r(i:end)];
        i = i + 1;
        time = time + sp.dt;
        times = [times times(end)+sp.dt];
    end
    times = [times times(end)+sp.dt];
    times = [times(1 : end-1) times(end) : phaseT(p+1) / sp.gridn ...
                                         : (times(end) + phaseT(p+1))];
    times = times(1:end-1);
    i = i + sp.gridn;
end


%xtoe  = interp1(times, xtoe, 0:sp.dt:times(end), 'linear');
%x     = interp1(times, x, 0:sp.dt:times(end), 'linear');
%y     = interp1(times, y, 0:sp.dt:times(end), 'linear');
%r     = interp1(times, r, 0:sp.dt:times(end), 'linear');
%times = 0:sp.dt:times(end);
phi   = atan2(y, x - xtoe);

fig = figure(1);
clf;
set(fig, 'Position', [100, 200, 600, 550]);
toolbar = uitoolbar(fig);
% Prevent clf from clearing the toolbar
toolbar.HandleVisibility = 'off';
% Read an image
[img,map] = imread('rewind.gif');
p = uipushtool(toolbar, 'TooltipString', 'Replay animation', ...
      'ClickedCallback', 'animate(times, x, y, phi, r, sp)');
icon = ind2rgb(img, map);
p.CData = icon;
animate(times, x, y, phi, r, sp);