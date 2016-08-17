function [] = animate_slip( times, xs, ys, phis, lens, simparams )
    dt = 0.01;
    time = -dt;
    % Initialize the figure
    figure(1);
    clf;
    % Make all the plots draw to the same figure
    hold on;
    % Draw ground
    patch([-100 100 100 -100], [0 0 -2 -2], [0 0.5 0]);
    % Initialize the spring plot
    spring_plot = plot(0, 0);
    % Initialize the hip circle fill
    hip_circle = [];
    
    % Draw debug text
    time_text = text(0, 1.8, sprintf('Simulation time: %f', time), 'FontSize', 13);
    len_text = text(0, 1.6, sprintf('len: %f', 0), 'FontSize', 13);
    
    while time <= times(end)
        time = time + dt;
        tgreater = find(times >= time);
        if ~isempty(tgreater)
            ti = tgreater(1);
        else
            ti = length(lens);
        end
        
        ncoils = 10;
        coilres = 2;
        spring_y = linspace(0, -lens(ti), (4*coilres)*ncoils+1);
        spring_x = sin(spring_y*2*pi*ncoils / lens(ti))*0.07;

        % Rotate spring_x and spring_y
        spring_mat = [spring_x; spring_y];
        center = repmat([0; 0], 1, length(spring_x));
        R = [cos(phis(ti)-pi/2) -sin(phis(ti)-pi/2); sin(phis(ti)-pi/2) cos(phis(ti)-pi/2)];
        rot_mat = R * (spring_mat - center) + center;
        spring_x = rot_mat(1,:) + xs(ti);
        spring_y = rot_mat(2,:) + ys(ti);

         % Clear the hip circle
        if ~isempty(hip_circle)
            delete(hip_circle);
        end

        % Draw spring
        spring_plot.XData = spring_x;
        spring_plot.YData = spring_y;
        spring_plot.Color = 'k';

        % Draw hip/pelvis
        [X,Y] = pol2cart(linspace(0, 2 * pi, 100), ones(1, 100) * 0.1);
        X = X + xs(ti);
        Y = Y + ys(ti);
        hip_circle = fill(X, Y, [1 .5 0]);

        time_text.String = sprintf('Simulation time: %f', time);
        len_text.String = sprintf('len: %f', lens(ti));

        % Set the axis
        if simparams.camfollow
            axis([-3 + xs(ti), 3 + xs(ti), -3, 3]);
        else
            axis([-3, 3, -3, 3]);
        end
        axis square;
        axis manual;
        pause(0.03);
    end
end

