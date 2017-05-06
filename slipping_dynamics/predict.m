function [ control, workForward, workBackward ] = predict( sp, ...
            slideReleaseAngle, flightFactor, springZoneFactor, ...
            springZone, puxcoef, puxdotcoef)
    if nargin < 2
        slideReleaseAngle = 0.5672763;
        flightFactor = 0.157974;
        springZoneFactor = 0.715969;
        springZone = [0.117470 0.523059];
        puxcoef = 0.784252;
        puxdotcoef = 0.742854;
        %puxcoef = 0.2 / 0.5;
        %puxdotcoef = 0.3 / 0.5;
    end
    
    xtoei = sp.iss().xtoe;
    xi = sp.iss().x;
    xdoti = sp.iss().xdot;
    
    xend = sp.slipPatch(2) + 0.1;
    
    workForward = predictForward(xtoei, xi, xdoti, xend, ...
                            sp, slideReleaseAngle, ...
                            flightFactor, puxcoef, puxdotcoef);
    workBackward = predictBackward(xtoei, xi, xdoti, xend, ...
                            sp, slideReleaseAngle, springZoneFactor, ...
                            flightFactor, springZone);
                        
    control = sign(workBackward - workForward);
end