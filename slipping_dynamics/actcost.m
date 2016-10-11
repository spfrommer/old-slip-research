function [ cost ] = actcost( funparams, sp )
    % Unpack the vector
    [~, ~, ~, ~, ~, ~, ~, ~, ~, raddot] = ...
        unpack(funparams, sp);
        
    cost = sum(raddot.^2);
end

