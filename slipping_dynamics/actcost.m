function [ cost ] = actcost( funparams, sp )
    % Unpack the vector
    [~, ~, ~, ~, ~, ~, ~, ~, ~, raddot, hiptorque] = ...
        unpack(funparams, sp);
        
    cost = sum((hiptorque./10).^2) + sum(raddot.^2);
end

