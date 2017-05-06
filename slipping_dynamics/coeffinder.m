maxCorrect = 0;

for i = 1:10000
    slideReleaseAngle = rand() * pi / 3;
    flightFactor = rand();
    springZoneFactor = rand();
    springStart = rand() / 2;
    springZone = [springStart, springStart + rand() / 2];
    puxcoef = rand();
    puxdotcoef = rand();
    
    forwardCorrect = 0;
    backwardCorrect = 0;
    forwardIncorrect = 0;
    backwardIncorrect = 0;
    
    numSims = 217;
    for simNum = 1 : numSims
        er = ExamineResults();

        fid = fopen(strcat('datawork/sim', num2str(simNum), '.txt'), 'r');
        slipPatch = sscanf(fgetl(fid), '%f,')';
        stateI = sscanf(fgetl(fid), '%f,');
        finX = sscanf(fgetl(fid), '%f');

        er.optimalBack = sscanf(fgetl(fid), '%f,');
        er.costBack = sscanf(fgetl(fid), '%f');
        flagB = sscanf(fgetl(fid), '%f');

        er.optimalFor = sscanf(fgetl(fid), '%f,');
        er.costFor = sscanf(fgetl(fid), '%f');
        flagF = sscanf(fgetl(fid), '%f');

        er.spBack = SimParams(['sli'; 'stl'; 'str'], slipPatch, stateI, finX);
        er.spFor = SimParams(['sli'; 'str'], slipPatch, stateI, finX);

        if flagB >= 0 && flagF < 0
            er.control = -1;
        elseif flagF >= 0 && flagB < 0
            er.control = 1;
        else
            if er.costBack > er.costFor
                er.control = 1;
            else
                er.control = -1;
            end
        end

        [er.predicted, er.predFor, er.predBack] = predict(er.spFor, ...
            slideReleaseAngle, flightFactor, springZoneFactor, ...
            springZone, puxcoef, puxdotcoef);

        if er.control == 1 && er.predicted == 1
            forwardCorrect = forwardCorrect + 1;
        elseif er.control == -1 && er.predicted == -1
            backwardCorrect = backwardCorrect + 1;
        elseif er.control == 1 && er.predicted == -1
            forwardIncorrect = forwardIncorrect + 1;
        elseif er.control == -1 && er.predicted == 1
            backwardIncorrect = backwardIncorrect + 1;
        end
        
        fclose(fid);
    end
    
    fc = forwardCorrect / (forwardCorrect + forwardIncorrect);
    bc = backwardCorrect / (backwardCorrect + backwardIncorrect);
    
    % Just raw add percentages
    correct = fc + bc;
    
    if correct > maxCorrect
        fprintf('Found better: %f\n', correct);
        fprintf('Slide release: %f\n', slideReleaseAngle);
        fprintf('Flight factor: %f\n', flightFactor);
        fprintf('Spring zone factor: %f\n', springZoneFactor);
        fprintf('Spring zone start: %f\n', springZone(1));
        fprintf('Spring zone end: %f\n', springZone(2));
        fprintf('Puxcoef: %f\n', puxcoef);
        fprintf('Puxdotcoef: %f\n', puxdotcoef);
        maxCorrect = correct;
    end
end