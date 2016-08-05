function [ length, lengthdot, actlength, actlengthdot, ...
           actlengthddot, phi, phidot, hiptorque] = unpack( x )
    global gridN
    length          = x(2             : 1 + gridN);
    lengthdot       = x(2 + gridN     : 1 + gridN * 2);
    actlength       = x(2 + gridN * 2 : 1 + gridN * 3);
    actlengthdot    = x(2 + gridN * 3 : 1 + gridN * 4);
    actlengthddot   = x(2 + gridN * 4 : 1 + gridN * 5);
    phi             = x(2 + gridN * 5 : 1 + gridN * 6);
    phidot          = x(2 + gridN * 6 : 1 + gridN * 7);
    hiptorque       = x(2 + gridN * 7 : end);
end

