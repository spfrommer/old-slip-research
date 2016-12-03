function [ control ] = predict( sp )
    xtoei = sp.initialState(1);
    xi = sp.initialState(3);
    xdoti = sp.initialState(4);
    
    endX = sp.slipPatch(2) + 0.1;
    
    slideReleaseAngle = pi / 4;
    apexHeight = sp.maxlen;
    fallDist = 0.28;
    
    workForward = predictForward(xtoei, xi, xdoti, endX, ...
                            slideReleaseAngle, apexHeight, fallDist, sp);
    workBackward = predictBackward(xtoei, xi, xdoti, endX, ...
                            slideReleaseAngle, apexHeight, fallDist, sp);
                        
    control = sign(workBackward - workForward);
end