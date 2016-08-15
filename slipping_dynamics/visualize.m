% Discretize the times
sim_time = optimal(1);
delta_time = sim_time / simparams.gridN;
times = 0 : delta_time : sim_time - delta_time;
% Unpack the vector
[xtoe, xtoedot, x, xdot, y, ydot, ...
    ra, radot, raddot, hiptorque] = unpack(optimal, simparams);
[c, ceq] = slip_constraints(optimal, simparams);

fig = figure(1);
clf;
set(fig, 'Position', [100, 200, 600, 550]);
toolbar = uitoolbar(fig);
% Prevent clf from clearing the toolbar
toolbar.HandleVisibility = 'off';
% Read an image
[img,map] = imread('rewind.gif');
p = uipushtool(toolbar, 'TooltipString', 'Replay animation', ...
      'ClickedCallback', 'animate_slip(sim_time, xtoe, x, y, simparams)');
icon = ind2rgb(img, map);
p.CData = icon;

animate_slip(sim_time, xtoe, x, y, simparams);