% Unpack the vector
[xtoe, xtoedot, x, xdot, y, ydot, ...
    ra, radot, raddot, hiptorque] = unpack(optimal, sp);
[c, ceq] = slip_constraints(optimal, sp);

% Calculate leg lengths and angles
r = sqrt((x - xtoe).^2 + y.^2);
phi = mod(atan2(y, x - xtoe), 2 * pi);

% Discretize the times for the first phase
times = 0 : optimal(1)/sp.gridN : optimal(1);
times = times(1:end-1);

i = sp.gridN + 1;
for p = 1 : sp.phases - 1
    % Interpolate ballistic flight
    disc = ydot(i-1)^2 - 2 * sp.gravity * (y(i) - y(i-1));
    flight_time = (-1/sp.gravity) * (-ydot(i-1) - real(sqrt(disc)));
    time = 0;
    dt = sp.ballisticdt;
    while time < flight_time-dt
        xtoe = [xtoe(1:i-1); (xtoe(i-1)+xtoedot(i-1)*dt); xtoe(i:end)];
        xtoedot = [xtoedot(1:i-1); xtoedot(i-1); xtoedot(i:end)];
        x = [x(1:i-1); (x(i-1)+xdot(i-1)*dt); x(i:end)];
        xdot = [xdot(1:i-1); xdot(i-1); xdot(i:end)];
        y = [y(1:i-1); (y(i-1)+ydot(i-1)*dt); y(i:end)];
        ydot = [ydot(1:i-1); (ydot(i-1)-sp.gravity*dt); ydot(i:end)];

        phi = [phi(1:i-1); mod(atan2(y(i), x(i) - xtoe(i)), 2 * pi); phi(i:end)];
        r = [r(1:i-1); 0; r(i:end)];
        i = i + 1;
        time = time + dt;
        times = [times times(end)+dt];
    end
    times = [times(1:end-1) times(end):optimal(p+1)/ ...
                            sp.gridN:times(end)+optimal(p+1)];
    i = i + sp.gridN;
end

fig = figure(1);
clf;
set(fig, 'Position', [100, 200, 600, 550]);
toolbar = uitoolbar(fig);
% Prevent clf from clearing the toolbar
toolbar.HandleVisibility = 'off';
% Read an image
[img,map] = imread('rewind.gif');
p = uipushtool(toolbar, 'TooltipString', 'Replay animation', ...
      'ClickedCallback', 'animate_slip(times, x, y, phi, r, sp)');
icon = ind2rgb(img, map);
p.CData = icon;
animate_slip(times, x, y, phi, r, sp);