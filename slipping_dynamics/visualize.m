% Discretize the times
sim_time = optimal(1);
delta_time = sim_time / gridN;
times = 0 : delta_time : sim_time - delta_time;
% Unpack the vector
[length, lengthdot, actlength, actlengthdot, actlengthddot, phi, phidot, ...
    hiptorque] = unpack(optimal);
[c, ceq] = slip_constraints(optimal, true);

fig = figure(1);
set(fig, 'Position', [100, 200, 600, 550]);
toolbar = uitoolbar(fig);
% Prevent clf from clearing the toolbar
toolbar.HandleVisibility = 'off';
% Read an image
[img,map] = imread('rewind.gif');
p = uipushtool(toolbar, 'TooltipString', 'Replay animation', ...
               'ClickedCallback', 'animate_slip(sim_time, length, phi, draw_vectors)');
icon = ind2rgb(img, map);
p.CData = icon;

animate_slip(sim_time, length, phi, draw_vectors);
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