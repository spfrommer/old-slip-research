function [ control ] = predict( sp )
    xtoei = sp.initialState(1);
    xi = sp.initialState(3);
    xdoti = sp.initialState(4);
    ydoti = sp.initialState(6);
    
    endX = sp.slipPatch(2) + 0.1;
    
    slideReleaseAngle = pi / 4;
    apexHeight = sp.maxlen;
    fallDist = 0.5;
    
    workForward = predictForward(xtoei, xi, xdoti, endX, ydoti, ...
                            slideReleaseAngle, apexHeight, fallDist, sp);
    workBackward = predictBackward(xtoei, xi, xdoti, endX, ydoti, ...
                            slideReleaseAngle, apexHeight, fallDist, sp);
                        
    control = sign(workBackward - workForward);
end