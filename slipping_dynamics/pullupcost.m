% Plots pullup cost

xdists = zeros(217, 1);
xdots = zeros(217, 1);
ydots = zeros(217, 1);
pus = zeros(217, 1);

for i=1:217
    er = examineSim(i);
    af = er.analyzeFor();
    if af.exists
        xdists(i) = er.spFor.finalProfileX - er.spFor.iss().x;
        xdots(i) = er.spFor.iss().xdot;
        ydots(i) = er.spFor.iss().xtoe - er.spFor.iss().x;
        % second phase cost
        pus(i) = sum(abs(af.workAng(10:18))) + sum(abs(af.workRa(10:18)));
    end
end

%pus = pus ./ max(pus);
%pus(pus > 0.3) = 0.3;
ydots = 80 .* abs(ydots) ./ max(abs(ydots));
ydots(ydots < 1) = 1;

colormap copper;
figure(1);
scatter(xdists, xdots, 80, pus .^ (0.25), 'filled');

figure(2);
plot(xdists, pus, 'o');
xlabel('xdists');
figure(3);
plot(xdots, pus, 'o');
xlabel('xdots');