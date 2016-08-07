function [] = animate_slip( sim_time, lengths, phis, draw_vector )
    time = 0;
    while time <= sim_time
        len = lengths(floor((time / sim_time) * length(lengths)) + 1);
        phi = phis(floor((time / sim_time) * length(phis)) + 1);
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
        
        % Specify the figure to draw to
        figure(1);
        % Clear the figure
        clf;
        % Make all the plots draw to the same figure
        hold on;
        % Draw ground
        patch([-2 2 2 -2], [0 0 -2 -2], [0 0.5 0]);
        % Draw spring
        plot(spring_x, spring_y, 'k');
        % Draw hip/pelvis
        [X,Y] = pol2cart(linspace(0, 2 * pi, 100), ones(1, 100) * 0.1);
        X = X + cos(pi-phi) * len;
        Y = Y + sin(pi-phi) * len;
        fill(X, Y, [1 .5 0]);
        
        for col = 1 : size(draw_vector, 2)
            page = floor((time / sim_time) * size(draw_vector, 3)) + 1;
            dv = draw_vector(:, col, page);
            line([dv(1) dv(1)+dv(3)], [dv(2) dv(2)+dv(4)]);
        end
        
        % Draw simulation time text
        text(0, 1.8, sprintf('Simulation time: %f', time), 'FontSize', 13);
        % Set the axis
        axis([-2, 2, -2, 2]);
        axis square;
        axis manual;
        pause(0.03);
        time = time + 0.05;
    end
end

