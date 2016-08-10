global masship masstoe spring damp friction gravity
masship = 10;
masstoe = 2;
spring = 600;
damp = 0;
friction = 1;
gravity = 9.81;

options = odeset('AbsTol', 10e-9, 'RelTol', 10e-8, 'Stats', 'on', 'OutputFcn', @odeprint);
x0 = [0; 0; cos(1.8); 0; sin(1.8); 0; 1; 0];
[times, solution] = ode45(@dynamics, [0, 5], x0, options);
visualize;