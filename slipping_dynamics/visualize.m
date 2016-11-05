% Unpack the vector
[ stanceT, flightT, xtoe, xtoedot, x, xdot, y, ydot, ...
           ra, radot, raddot, torque] = unpack(optimal, sp);
[c, ceq] = constraints(optimal, sp);

vp = VisParams();

% Calculate leg lengths
r = sqrt((x - xtoe).^2 + y.^2);

% Discretize the times for the first phase
times = 0 : stanceT(1) / sp.gridn : stanceT(1);
times = times(1 : end-1);

i = sp.gridn + 1;
for p = 1 : size(sp.phases, 1) - 1
    % Interpolate ballistic flight
    time = 0;
    while time < flightT(p) - vp.dt
        xtoe = [xtoe(1:i-1); xtoe(i-1); xtoe(i:end)];
        x = [x(1:i-1); (x(i-1)+xdot(i-1)*vp.dt); x(i:end)];
        xdot = [xdot(1:i-1); xdot(i-1); xdot(i:end)];
        y = [y(1:i-1); (y(i-1)+ydot(i-1)*vp.dt); y(i:end)];
        ydot = [ydot(1:i-1); (ydot(i-1)-sp.gravity*vp.dt); ydot(i:end)];

        r = [r(1:i-1); 0; r(i:end)];
        i = i + 1;
        time = time + vp.dt;
        times = [times times(end)+vp.dt];
    end
    times = [times times(end)+vp.dt];
    times = [times(1 : end-1) times(end) : stanceT(p+1) / sp.gridn ...
                                         : (times(end) + stanceT(p+1))];
    times = times(1:end-1);
    i = i + sp.gridn;
end


if vp.interpolate
    xtoe  = interp1(times, xtoe, 0:vp.dt:times(end), 'linear');
    x     = interp1(times, x,    0:vp.dt:times(end), 'linear');
    y     = interp1(times, y,    0:vp.dt:times(end), 'linear');
    r     = interp1(times, r,    0:vp.dt:times(end), 'linear');
    times = 0:vp.dt:times(end);
end
phi = atan2(y, x - xtoe);

fig = figure(1);

clf;
set(fig, 'Position', [100, 200, 600, 550]);
toolbar = uitoolbar(fig);
% Prevent clf from clearing the toolbar
toolbar.HandleVisibility = 'off';
% Read an image
[img,map] = imread('rewind.gif');
p = uipushtool(toolbar, 'TooltipString', 'Replay animation', ...
      'ClickedCallback', 'animate(times, x, y, phi, r, sp, vp)');
icon = ind2rgb(img, map);
p.CData = icon;
animate(times, x, y, phi, r, sp, vp);