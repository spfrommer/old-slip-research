function [ control ] = predict( sp )
    xi = sp.initialState(3);
    xdoti = sp.initialState(4);
    % Can be any arbitrary values, doesn't matter
    f = 1;
    m = 1;
    freeZone = [sp.slipPatch(1) + 0.2, sp.slipPatch(1) + 0.35];

    % Forward step time calculation
    forwardTime = calcTime([f/(2*m), xdoti, xi - sp.slipPatch(2)]);
    
    if xi > freeZone(2)
        % Case where SLIP starts in front of "free zone"
        % Assume max acceleration through free zone and rebound
        xi = -xi + 2 * freeZone(1);
        freeZone = [(2 * freeZone(1) - freeZone(2)), freeZone(2)];
    end
        
    % Backwards step time calculation
    if xi < freeZone(1) 
        % Case where "free" zone starts in front of SLIP
        timeToFreeStart = calcTime([f/(2*m), xdoti, xi - freeZone(1)]);
        timeToFreeEnd = calcTime([f/(2*m), xdoti, xi - freeZone(2)]);
        timeToIceEnd = calcTime([f/(2*m), xdoti, xi - sp.slipPatch(2)]);
        backwardTime = timeToIceEnd - (timeToFreeEnd - timeToFreeStart);
    elseif xi < freeZone(2)
        % Case where SLIP starts in "free zone"
        timeToFreeEnd = calcTime([f/(2*m), xdoti, xi - freeZone(2)]);
        timeToIceEnd = calcTime([f/(2*m), xdoti, xi - sp.slipPatch(2)]);
        backwardTime = timeToIceEnd - timeToFreeEnd;
    else
        disp('Error!! Prediction should never have reached here');
    end
    
    control = sign(backwardTime - forwardTime);
end