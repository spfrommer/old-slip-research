function [ work ] = predictForward( xtoei, xi, xdoti, xend, ...
                              sp, slideReleaseAngle, ...
                              flightFactor, puxcoef, puxdotcoef)
    f_n = sp.maxtorque / sp.maxlen - ...
          sp.gravity * (sp.masship + sp.masstoe) * sp.friction;
    a_t = f_n / sp.masstoe;
    
    % The max distance the toe can slide backwards behind the body
    dmaxback = min(sin(slideReleaseAngle)*sp.maxlen, xi - sp.slipPatch(1));
    % The max distance the toe can slide backwards
    dmax = xtoei - xi + dmaxback;
    
    t_slide = sqrt(2 * dmax / a_t);
    
    slideWork = dmax * sp.maxtorque / sp.maxlen;
    
    % final hip x after first stance phase
    xsf = xi + xdoti * t_slide + ...
        0.5 * (sp.maxtorque / sp.maxlen) * t_slide^2;
    
    %puWork = max((0.2/0.5) * (sp.finalProfileX - xi - 0.4) ...
    %                - (0.3/0.5) * xdoti, 0);
    puWork = max(puxcoef * (sp.finalProfileX - xi - 0.4) ...
                    - puxdotcoef * xdoti, 0);
    
    dxPu = sp.maxlen * ...
        sqrt(1 - (1 - puWork / (sp.masship * sp.gravity * sp.maxlen))^2);
    
    % Virtual cost assigned to falling
    flightWork = (xend - xsf - dxPu) * sp.gravity*sp.masship*flightFactor;
    
    work = slideWork + flightWork + puWork; 
end

