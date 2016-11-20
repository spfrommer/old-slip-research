function [ time ] = calcTime( poly )
    %UNTITLED2 Summary of this function goes here
    %   Detailed explanation goes here
    r = roots(poly);
    % Remove negative roots
    r(r < 0) = [];
    % Take the smaller time root
    time = min(r);
end

