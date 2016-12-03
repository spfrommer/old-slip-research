function [ work ] = predictForward( xtoei, xi, xdoti, endX, ...
                              slideReleaseAngle, apexHeight, fallDist, sp)
    % ---------Two-phase step sequence (slip to right stick)---------
    
    % Time to fall from apex height to minimum height
    tFall = sqrt(2 * fallDist / sp.gravity);
    
    % Slip phase calculations
    ff = sp.gravity * (sp.masship + sp.masstoe) * sp.friction;
    % The max distance the toe can slide backwards behind the body
    dmaxbehind = min(cos(slideReleaseAngle) * sp.maxlen, ...
                     xi - sp.slipPatch(1));
    % The max distance the toe can slide backwards
    dmax = xtoei - xi + dmaxbehind;

    % The velocity that will get you right to the end point in the fall time
    exactXdot = (endX - xi) / tFall;
    % The amount of work required to get you right to the end point
    exactWork = max(0.5 * sp.masship * (exactXdot^2 - xdoti^2), 0);
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
    
    % Stick phase calculations
    % X pos after flight phase
    xsticki = xi + xdotfsr * tFall;
    % Y pos after flight phase
    ysticki = apexHeight - 0.5 * (sp.gravity / sp.masship) * tFall^2;
    % Leg length at landing
    rsticki = sqrt((xsticki - endX)^2 + ysticki^2);
    
    if rsticki > sp.maxlen
        work = Inf;
    else
        %Work done by the lift
        wl = sp.masship * sp.gravity * (rsticki - ysticki);

        work = ws + wl;
    end
end

