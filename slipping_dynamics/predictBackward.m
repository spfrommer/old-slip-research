function [ work ] = predictBackward( xtoei, xi, xdoti, endX, ydoti, ...
                                  slideReleaseAngle, apexHeight, fallDist, sp )
    % Assumed angle of spring during left stance for projection
    projAngle = 1;
    springEnd = sp.maxlen * cos(projAngle);
    
    % Distance behind end of spring to not swipe backwards
    allForwardsSpringDist = 0.1;
    % Minimum amount spring must be compressed at start of spring phase
    mincomp = 0.1;
    
    allForwardsWork = Inf;
    if xi < springEnd - allForwardsSpringDist
        % Time to fall from apex height to minimum height (reflect ydoti to
        % account for spring rebound)
        tRoots = roots([-0.5 * sp.gravity, abs(ydoti), fallDist]);
        tFall = max(tRoots);

        % Slip phase calculations
        ff = sp.gravity * (sp.masship + sp.masstoe) * sp.friction;
        % The max distance the toe can slide backwards behind the body
        dmaxbehind = min(cos(slideReleaseAngle) * sp.maxlen, ...
                         xi - sp.slipPatch(1));
        % The max distance the toe can slide backwards
        dmax = xtoei - xi + dmaxbehind;
        
        % The velocity that will get you right to the spring start
        % point in the fall time
        exactXdot = ((springEnd - mincomp) - xi) / tFall;
        % The amount of work required to get you right to the end point
        exactWork = max((sp.masship / 2) * (exactXdot^2 - xdoti^2), 0);
        % The exact toe scrape distance necessary
        exactD = exactWork / ff;

        % The work done by the toe scrape
        if exactD >= dmax
            ws = ff * dmax;
        else
            ws = ff * exactD;
        end
        % The sliding mass velocity after release
        xdotfsr = sqrt(2 * ws / sp.masship + xdoti^2);
        
        % X start at spring phase
        xss = xi + xdotfsr * tFall;
        xprojspring = xss * cos(projAngle);
        maxSpringWork = 0.5 * sp.spring * (springEnd - xprojspring)^2;
        
        exactXdotf = (endX - xss) / tFall;
        exactWorkf = max((sp.masship / 2) * (exactXdotf^2 - xdotfsr^2), 0);
        
        if exactWorkf <= maxSpringWork
            allForwardsWork = exactWorkf + ws;
        else
            % Calculate velocity after spring phase
            keStart = 0.5 * sp.masship * xdotfsr^2 * sign(xdotfsr) + maxSpringWork;
            endKe = keStart * sign(xdotfsr) + exactWorkf;
            xdotend = sqrt(2 * endKe / sp.masship);
            
            % Stick phase calculations
            % X pos after flight phase
            xsticki = springEnd + xdotend * tFall;
            % Y pos after flight phase
            ysticki = apexHeight - 0.5 * (sp.gravity / sp.masship) * tFall^2;
            % Leg length at landing
            rsticki = sqrt((xsticki - endX)^2 + ysticki^2);

            if rsticki > sp.maxlen
                allForwardsWork = Inf;
            else
                %Work done by the lift
                wl = sp.masship * sp.gravity * (rsticki - ysticki);

                allForwardsWork = ws + maxSpringWork + wl;
            end
        end
    end
    
    backwardsWork = Inf;
    if allForwardsWork == Inf
        % Time to fall from apex height to minimum height (reflect ydoti to
        % account for spring rebound)
        tFall = max(roots([-0.5 * sp.gravity, abs(ydoti), fallDist]));
        
        % Slip phase calculations
        ff = sp.gravity * (sp.masship + sp.masstoe) * sp.friction;
        % The max distance the toe can slide forwards in front of the body
        dmaxfront = min(cos(slideReleaseAngle) * sp.maxlen, ...
                         sp.slipPatch(2) - xi);
        % The max distance the toe can slide forwards
        dmax = xi - xtoei + dmaxfront;
        
        ws = ff * dmax;
        
        % Signed kinetic energy after slide phase
        kf = 0.5 * sp.masship * xdoti^2 - ws;
        
        % The sliding mass velocity after release
        xdotfsr = sign(kf) * sqrt(2 * abs(kf) / sp.masship);
        
        % ydot at start of second stance phase
        ydotsp2i = ydoti - sp.gravity*tFall;
        % Flight time during second flight phase, assuming y velocity
        % rebound
        tFall = max(roots([-0.5 * sp.gravity, abs(ydotsp2i), 0]));
        
        % X start at spring phase
        xss = xi + xdotfsr * tFall;
        xprojspring = xss * cos(projAngle);
        maxSpringWork = 0.5 * sp.spring * (springEnd - xprojspring)^2;
        
        % no 0.5 factor because y rebound means multiply by two
        reflectWork = sp.masship * ydotsp2i^2 * (xss - sp.slipPatch(1) / sp.maxlen);
        
        exactXdotf = (endX - xss) / tFall;
        % Exact additional work beyond simply flipping the velocity
        % required to get the block to the endX (hency why xdotfsr's sign
        % does not matter)
        exactWorkf = max((sp.masship / 2) * (exactXdotf^2 - xdotfsr^2), 0);
        
        if exactWorkf <= maxSpringWork
            backwardsWork = ws + reflectWork + exactWorkf;
        else
            % Calculate velocity after spring phase
            endKe = 0.5 * sp.masship * xdotfsr^2 + maxSpringWork;
            xdotend = sqrt(2 * endKe / sp.masship);
            
            % Stick phase calculations
            % X pos after flight phase
            xsticki = springEnd + xdotend * tFall;
            % Y pos after flight phase
            ysticki = apexHeight - 0.5 * (sp.gravity / sp.masship) * tFall^2;
            % Leg length at landing
            rsticki = sqrt((endX - xsticki)^2 + ysticki^2);

            if rsticki > sp.maxlen
                backwardsWork = Inf;
            else
                %Work done by the lift
                wl = sp.masship * sp.gravity * (rsticki - ysticki);

                backwardsWork = ws + reflectWork + maxSpringWork + wl;
            end 
        end
    end
    
    work = min(backwardsWork, allForwardsWork);
end