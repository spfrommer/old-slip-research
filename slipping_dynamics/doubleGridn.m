function [ inter ] = doubleGridn( funparams, sp )
    [ phaseT, xtoe, xtoedot, x, xdot, y, ydot, ...
           ra, radot, raddot, torque] = unpack(funparams, sp);
    inter = [phaseT; kron(xtoe', [1 1])';      kron(xtoedot', [1 1])';
                      kron(x', [1 1])';         kron(xdot', [1 1])';
                      kron(y', [1 1])';         kron(ydot', [1 1])';
                      kron(ra', [1 1])';        kron(radot', [1 1])';
                      kron(raddot', [1 1])';    kron(torque', [1 1])'];
end

