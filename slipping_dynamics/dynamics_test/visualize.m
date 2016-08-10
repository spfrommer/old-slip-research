xtoe        = solution(:, 1);
xtoedot     = solution(:, 2);
x           = solution(:, 3);
xdot        = solution(:, 4);
y           = solution(:, 5);
ydot        = solution(:, 6);
actlen      = solution(:, 7);
actlendot   = solution(:, 8);

fig = figure(1);
set(fig, 'Position', [100, 200, 600, 550]);
toolbar = uitoolbar(fig);
% Prevent clf from clearing the toolbar
toolbar.HandleVisibility = 'off';
% Read an image
[img,map] = imread('rewind.gif');
p = uipushtool(toolbar, 'TooltipString', 'Replay animation', ...
               'ClickedCallback', 'animate_slip(times, xtoe, x, y)');
icon = ind2rgb(img, map);
p.CData = icon;

animate_slip(times, xtoe, x, y);