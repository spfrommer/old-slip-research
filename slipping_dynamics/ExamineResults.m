classdef ExamineResults < handle
    properties
        control
        predicted
        spFor
        spBack
        costFor
        costBack
        predFor
        predBack
        % The raw optimizer outputs
        optimalFor
        optimalBack
    end
    
    methods (Access = private)
        function [r, rdot, radotCombined, raddotCombined, fs, angleDeltas, torqueCombined, ...
                workAng, workRa] = process(~, optimal, sp)
            [stanceT, ~, xtoe, ~, x, xdot, y, ydot, ra, radot, raddot, torque] = ...
                unpack(optimal, sp);
           phaseN = size(sp.phases, 1);

           r = sqrt((x - xtoe).^2 + y.^2);
           rdot = ((x-xtoe).*(xdot)+y.*ydot)./(r);
           fs = sp.spring * (ra - r) + sp.damp * (radot - rdot);

           startRemInd = 1 : sp.gridn : sp.gridn * phaseN;
           endRemInd = sp.gridn : sp.gridn : sp.gridn * phaseN;

           [fsA, fsB] = deal(fs);
           fsA(startRemInd) = [];
           fsB(endRemInd) = [];
           fsCombined = (fsA + fsB) .* 0.5;

           [radotA, radotB] = deal(radot);
           radotA(startRemInd) = [];
           radotB(endRemInd) = [];
           radotCombined = (radotA + radotB) .* 0.5;
           
           [raddotA, raddotB] = deal(raddot);
           raddotA(startRemInd) = [];
           raddotB(endRemInd) = [];
           raddotCombined = (raddotA + raddotB) .* 0.5;
           
           angles = atan2(y, x - xtoe);
           angleShift = [angles(1); angles(1 : end-1)];
           angleDeltas = angles - angleShift;
           angleDeltas(startRemInd) = [];
           [torqueA,torqueB] = deal(torque);
           torqueA(startRemInd) = [];
           torqueB(endRemInd) = [];
           torqueCombined = (torqueA + torqueB) .* 0.5;

           workAng = torqueCombined .* angleDeltas;
           
           workRa = fsCombined .* radotCombined;
           workRa = workRa .* kron(stanceT./sp.gridn, ones(sp.gridn - 1, 1));
        end
    end
    
    methods
       function af = analyzeFor( obj )
           af = struct();
           
           if isempty(obj.optimalFor)
               af.exists = false;
               return
           else
               af.exists = true;
           end
           
           [ stanceT, flightT, xtoe, xtoedot, x, xdot, y, ydot, ...
             ra, radot, raddot, torque] = unpack(obj.optimalFor, obj.spFor);
           af.stanceT = stanceT;
           af.flightT = flightT;
           af.xtoe = xtoe;
           af.xtoedot = xtoedot;
           af.x = x;
           af.xdot = xdot;
           af.y = y;
           af.ydot = ydot;
           af.ra = ra;
           af.radot = radot;
           af.raddot = raddot;
           af.torque = torque;
           
           [af.r, af.rdot, af.radotCombined, af.raddotCombined, af.fs, ...
             af.angleDeltas, af.torqueCombined, af.workAng, af.workRa] ...
               = obj.process(obj.optimalFor, obj.spFor);
       end
       
       function ab = analyzeBack( obj )
           ab = struct();
           
           if isempty(obj.optimalBack)
               ab.exists = false;
               return
           else
               ab.exists = true;
           end
           
           [ stanceT, flightT, xtoe, xtoedot, x, xdot, y, ydot, ...
             ra, radot, raddot, torque] = unpack(obj.optimalBack, obj.spBack);
           ab.stanceT = stanceT;
           ab.flightT = flightT;
           ab.xtoe = xtoe;
           ab.xtoedot = xtoedot;
           ab.x = x;
           ab.xdot = xdot;
           ab.y = y;
           ab.ydot = ydot;
           ab.ra = ra;
           ab.radot = radot;
           ab.raddot = raddot;
           ab.torque = torque;
           
           [ab.r, ab.rdot, ab.radotCombined, ab.raddotCombined, ab.fs, ...
             ab.angleDeltas, ab.torqueCombined, ab.workAng, ab.workRa] ...
               = obj.process(obj.optimalBack, obj.spBack);
       end
    end
end

