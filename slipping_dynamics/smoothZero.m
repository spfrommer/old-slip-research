function [ y ] = smoothZero( x )
    a = 100;
    if x > 1/a
        y = x;
    else
        b = (1-log(1/a)) / a;
        y = exp(1)^(a*x - a * b);
    end
end

