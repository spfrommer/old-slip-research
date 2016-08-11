function [] = animate_slip( sim_time, xtoes, xs, ys )
    global gridN camfollow
    time = 0;
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
    while time <= sim_time
        ti = floor((time / sim_time) * gridN) + 1;
        len = sqrt((xs(ti)-xtoes(ti))^2 + ys(ti)^2);
        phi = mod(atan2(ys(ti), xs(ti)-xtoes(ti)), 2 * pi);
        xtoe = xtoes(ti);
        ncoils = 10;
        coilres = 2;
        spring_y = linspace(0, len, (4*coilres)*ncoils+1);
        spring_x = sin(spring_y*2*pi*ncoils / len)*0.07;
        
        % Rotate spring_x and spring_y
        spring_mat = [spring_x; spring_y];
        center = repmat([0; 0], 1, length(spring_x));
        R = [cos(phi-pi/2) -sin(phi-pi/2); sin(phi-pi/2) cos(phi-pi/2)];
        rot_mat = R * (spring_mat - center) + center;
        spring_x = rot_mat(1,:) + xtoe;
        spring_y = rot_mat(2,:);
        
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
        X = X + cos(phi) * len + xtoe;
        Y = Y + sin(phi) * len;
        hip_circle = fill(X, Y, [1 .5 0]);
        
        time_text.String = sprintf('Simulation time: %f', time);
        len_text.String = sprintf('len: %f', len);
        
        % Set the axis
        if camfollow
            axis([-3 + xpos, 3 + xpos, -3, 3]);
        else
            axis([-3, 3, -3, 3]);
        end
        axis square;
        axis manual;
        pause(0.03);
        time = time + 0.03;
    end
end

