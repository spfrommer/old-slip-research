function [] = animate( times, xs, ys, phis, lens, sp )
    dt = 0.03;
    time = -dt;
    % Initialize the figure
    figure(1);
    clf;
    % Make all the plots draw to the same figure
    hold on;
    % Draw ground
    patch([-100 100 100 -100], [0 0 -5 -5], [0 0.5 0]);
    % Draw ice patch
    patch([sp.slipPatch, fliplr(sp.slipPatch)], [0 0 -0.5 -0.5], [0 0 0.5]);
    % Initialize the spring plot
    springPlot = plot(0, 0);
    % Initialize the hip circle fill
    hipCircle = [];
    
    % Draw debug text
    timeText = text(0, 1.8, sprintf('Simulation time: %f', time), 'FontSize', 13);
    lenText = text(0, 1.6, sprintf('len: %f', 0), 'FontSize', 13);
    
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
        springY = linspace(0, -lens(ti), (4*coilres)*ncoils+1);
        springX = sin(springY*2*pi*ncoils / lens(ti))*0.07;

        % Rotate springX and springY
        springMat = [springX; springY];
        center = repmat([0; 0], 1, length(springX));
        R = [cos(phis(ti)-pi/2) -sin(phis(ti)-pi/2); sin(phis(ti)-pi/2) cos(phis(ti)-pi/2)];
        rotMat = R * (springMat - center) + center;
        springX = rotMat(1,:) + xs(ti);
        springY = rotMat(2,:) + ys(ti);

         % Clear the hip circle
        if ~isempty(hipCircle)
            delete(hipCircle);
        end

        % Draw spring
        springPlot.XData = springX;
        springPlot.YData = springY;
        springPlot.Color = 'k';

        % Draw hip/pelvis
        [X,Y] = pol2cart(linspace(0, 2 * pi, 100), ones(1, 100) * 0.1);
        X = X + xs(ti);
        Y = Y + ys(ti);
        hipCircle = fill(X, Y, [1 .5 0]);

        timeText.String = sprintf('Simulation time: %f', time);
        lenText.String = sprintf('len: %f', lens(ti));

        % Set the axis
        if sp.camFollow
            axis([-3 + xs(ti), 3 + xs(ti), -3, 3]);
            timeText.Position(1) = xs(ti);
            lenText.Position(1) = xs(ti);
        else
            axis([-3, 3, -3, 3]);
        end
        axis square;
        axis manual;
        pause(sp.dt * 2);
    end
end

