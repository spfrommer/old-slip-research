function [ c, ceq ] = slip_constraints( x )
    global gridN mass hip_inertia spring damp gravity
    sim_time = x(1);
    delta_time = sim_time / gridN;
    r         = x(2             : 1 + gridN);
    rdot      = x(2 + gridN     : 1 + gridN * 2);
    ra        = x(2 + gridN * 2 : 1 + gridN * 3);
    radot     = x(2 + gridN * 3 : 1 + gridN * 4);
    phi       = x(2 + gridN * 4 : 1 + gridN * 5);
    phidot    = x(2 + gridN * 5 : 1 + gridN * 6);
    theta     = x(2 + gridN * 6 : 1 + gridN * 7);
    thetadot  = x(2 + gridN * 7 : 1 + gridN * 8);
    raddot    = x(2 + gridN * 8 : 1 + gridN * 9);
    hiptorque = x(2 + gridN * 9 : 1 + gridN * 10);
    
    c = zeros(gridN - 1, 1);
    ceq = zeros((gridN - 1) * 8, 1);
    for i = 1 : gridN - 1
        %c(i) = (pi / 2 - phi(i)) * hiptorque(i);
        ceq(8*(i-1)+1) = r(i + 1) - (r(i) + rdot(i) * delta_time);
        ceq(8*(i-1)+2) = ra(i + 1) - (ra(i) + radot(i) * delta_time);
        ceq(8*(i-1)+3) = phi(i + 1) - (phi(i) + phidot(i) * delta_time);
        ceq(8*(i-1)+4) = theta(i + 1) - (theta(i)+thetadot(i)*delta_time);
        
        % The inertia of the mass around the toe, assuming a point mass
        toe_inertia = mass * r(i);
        
        rddot = (spring * (ra(i) - r(i)) + damp * (radot(i) - rdot(i)) ...
                 - mass * gravity * sin(phi(i))) / mass;
        phiddot = (mass*gravity*cos(phi(i)) - hiptorque(i)) / hip_inertia;
        thetaddot = -hiptorque(i) / toe_inertia;
        
        ceq(8*(i-1)+5) = rdot(i+1) - (rdot(i) + rddot * delta_time);
        ceq(8*(i-1)+6) = radot(i+1) - (radot(i) + raddot(i) * delta_time);
        ceq(8*(i-1)+7) = phidot(i+1) - (phidot(i) + phiddot * delta_time);
        ceq(8*(i-1)+8) = thetadot(i+1)-(thetadot(i)+thetaddot*delta_time);
    end
    
    %ceq=[ceq; r(1) - 1        ; rdot(1)     ; ra(1) - 1  ; radot(1); ...
    %          phi(1) - pi/2   ; phidot(1)   ; theta(1)   ; thetadot(1); ...
    %          r(end) - 0.8    ; rdot(end)   ; ...
    %          phi(end) - pi/2 ; phidot(end) ; theta(end) ; thetadot(end)];
    ceq = [ceq; r(1) - 1; r(end) - 0.8];
end

