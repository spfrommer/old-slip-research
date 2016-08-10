global masship masstoe spring damp friction gravity
masship = 10;
masstoe = 2;
spring = 400;
damp = 0;
friction = 0;
gravity = 9.81;

options = odeset('AbsTol', 10e-9, 'RelTol', 10e-8, 'Stats', 'on', 'OutputFcn', @odeprint);
x0 = [0; 0; -0.5; 0; 1.4; 0; 1; 0];
[times, solution] = ode45(@dynamics, [0, 360], x0, options);
visualize;