function [] = animate_slip( times, xtoes, lengths, phis )
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
    len_text = text(0, 1.6, sprintf('len: %f', lengths(1)), 'FontSize', 13);
    while time <= times(end)
        ti = 1;
        while times(ti) < time
            ti = ti + 1;
        end
        len = lengths(ti);
        phi = phis(ti);
        xtoe = xtoes(ti);
        ncoils = 10;
        coilres = 2;
        spring_y = linspace(0, len, (4*coilres)*ncoils+1);
        spring_x = sin(spring_y*2*pi*ncoils / len)*0.07;
        
        % Rotate spring_x and spring_y
        spring_mat = [spring_x; spring_y];
        center = repmat([0; 0], 1, length(spring_x));
        R = [cos(pi/2-phi) -sin(pi/2-phi); sin(pi/2-phi) cos(pi/2-phi)];
        rot_mat = R * (spring_mat - center) + center;
        spring_x = rot_mat(1,:);
        spring_y = rot_mat(2,:);
        
        % Shift spring_x by xtoe
        spring_x = spring_x + xtoe;
        
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
        X = X + cos(pi-phi) * len + xtoe;
        Y = Y + sin(pi-phi) * len;
        hip_circle = fill(X, Y, [1 .5 0]);
        
        time_text.String = sprintf('Simulation time: %f', time);
        len_text.String = sprintf('len: %f', len);
        
        xpos = cos(pi-phi) * len + xtoe;
        xpos = 0;
        % Set the axis
        axis([-3 + xpos, 3 + xpos, -3, 3]);
        axis square;
        axis manual;
        pause(0.03);
        time = time + 0.01;
    end
end

