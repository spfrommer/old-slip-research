function [ work ] = predictBackward( xtoei, xi, xdoti, xend, ...
                                  sp, slideReleaseAngle, ...
                                  springZoneFactor, flightFactor, ...
                                  springZone)

    f_n = sp.maxtorque / sp.maxlen - ...
          sp.gravity * (sp.masship + sp.masstoe) * sp.friction;
    a_t = f_n / sp.masstoe;                  
    
    if xi > springZone(2)
        % The max distance the toe can slide forwards in front of the body
        dmaxfront = min(sin(slideReleaseAngle) * sp.maxlen, ...
                         sp.slipPatch(2) - xi);
        % The max distance the toe can slide forwards
        dmax = xi - xtoei + dmaxfront;
        
        t_slide = sqrt(2 * dmax / a_t);
    
        slideWork = dmax * sp.maxtorque / sp.maxlen;
        
        % final hip x after first stance phase
        xsf = xi + xdoti * t_slide ...
            - 0.5 * (sp.maxtorque / sp.maxlen) * t_slide^2;
    else
        slideWork = 0;
        xsf = xi;
    end
    
    springZoneWork = 2 * (springZone(2) - springZone(1))...
                       * sp.gravity * sp.masship * springZoneFactor;
    
    flightWork = (max(0, xsf - springZone(2)) + xend - springZone(2)) * ...
                    sp.gravity * sp.masship * flightFactor;
    
    work = slideWork + springZoneWork + flightWork;
end