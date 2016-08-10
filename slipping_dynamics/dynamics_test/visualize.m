xtoe        = x(:, 1);
xtoedot     = x(:, 2);
len         = x(:, 3);
lendot      = x(:, 4);
actlen      = x(:, 5);
actlendot   = x(:, 6);
phi         = x(:, 7);
phidot      = x(:, 8);

fig = figure(1);
set(fig, 'Position', [100, 200, 600, 550]);
toolbar = uitoolbar(fig);
% Prevent clf from clearing the toolbar
toolbar.HandleVisibility = 'off';
% Read an image
[img,map] = imread('rewind.gif');
p = uipushtool(toolbar, 'TooltipString', 'Replay animation', ...
               'ClickedCallback', 'animate_slip(times, xtoe, len, phi)');
icon = ind2rgb(img, map);
p.CData = icon;

animate_slip(times, xtoe, len, phi);
pause(2);
if false
    % Make the plots
    figure(2);
    plot(times, actlength);
    title('Actuated Length vs Time');
    xlabel('Time (s)');
    ylabel('Actuated Length (m)');
    figure(3);
    plot(times, actlengthdot);
    title('Actuated Length Derivatives vs Time');
    xlabel('Time (s)');
    ylabel('Actuated Length Derivative');
    figure(4);
    plot(times, actlengthddot);
    title('Actuated Length Second Derivatives vs Time');
    xlabel('Time (s)');
    ylabel('Actuated Length Second Derivatives');
    figure(5);
    plot(times, lengthdot);
    title('Length Derivatives vs Time');
    xlabel('Time (s)');
    ylabel('Length Derivative (m/s)');
    figure(6);
    plot(times, length);
    title('Length vs Time');
    xlabel('Time (s)');
    ylabel('Length (m)');
    figure(7);
    plot(times, phi);
    title('Leg angle with ground');
    xlabel('Time (s)');
    ylabel('Leg angle with ground');
    figure(8);
    plot(times, phidot);
    title('Time derivative of leg angle with ground');
    xlabel('Time (s)');
    ylabel('Time derivative of leg angle with ground');
    figure(9);
    plot(times, hiptorque);
    title('Hip torques');
    xlabel('Time (s)');
    ylabel('Torques at the hip');
end