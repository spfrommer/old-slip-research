function [  ] = render(sim_time, lengths, phis )
    time = 0;
    while time < sim_time
        len = lengths(floor((time / sim_time) * length(lengths)) + 1);
        phi = phis(floor((time / sim_time) * length(phis)) + 1);
        clf;
        hold on;
        ncoils = 10;
        coilres = 2;
        spring_y = linspace(0, len, (4*coilres)*ncoils+1);
        spring_x = sin(spring_y*2*pi*ncoils / len)*0.05;
        
        % Rotate spring_yx and spring_y
        spring_mat = [spring_x; spring_y];
        center = repmat([0; 0], 1, length(spring_x));
        R = [cos(pi/2-phi) -sin(pi/2-phi); sin(pi/2-phi) cos(pi/2-phi)];
        rot_mat = R * (spring_mat - center) + center;
        spring_x = rot_mat(1,:);
        spring_y = rot_mat(2,:);
        
        plot(spring_x, spring_y, 'k');
        
        plot(cos(pi-phi) * len, sin(pi-phi) * len, '.g', 'MarkerSize', 50);
        
        axis([-2, 2, -2, 2]);
        pause(0.01);
        time = time + 0.01;
    end
end

