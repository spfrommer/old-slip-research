numCorrect = 0;
forwardCorrect = 0;
backwardCorrect = 0;
forwardIncorrect = 0;
backwardIncorrect = 0;

numSims = 200;

yDots = zeros(1, numSims);
xFors = zeros(1, numSims);
xBacks = zeros(1, numSims);
xDots = zeros(1, numSims);
sizes = ones(1, numSims) * 50;
controls = zeros(1, numSims);

workFors = zeros(1, numSims);
workBacks = zeros(1, numSims);
predictedFors = zeros(1, numSims);
predictedBacks = zeros(1, numSims);

for i = 1 : numSims
    er = examineSim(i, false);
    
    yDots(i) = er.spBack.iss().ydot;
    xFors(i) = er.spBack.finalProfileX - er.spBack.iss().x;
    xBacks(i) = er.spBack.iss().x;
    xDots(i) = er.spBack.iss().xdot;
    controls(i) = max(er.control, 0);
    
    workFors(i) = er.costFor;
    workBacks(i) = er.costBack;
    predictedFors(i) = er.predFor;
    predictedBacks(i) = er.predBack;
    
    if er.control == 1 && er.predicted == 1
        forwardCorrect = forwardCorrect + 1;
    elseif er.control == -1 && er.predicted == -1
        backwardCorrect = backwardCorrect + 1;
    elseif er.control == 1 && er.predicted == -1
        forwardIncorrect = forwardIncorrect + 1;
    elseif er.control == -1 && er.predicted == 1
        backwardIncorrect = backwardIncorrect + 1;
    end
end

colormap(copper);
scatter(yDots, controls);
%scatter3(xFors, xBacks, xDots, sizes, controls);

fprintf('Backward correct percent: %f\n', backwardCorrect / ...
                                (backwardCorrect + backwardIncorrect));
fprintf('Forward correct percent: %f\n', forwardCorrect / ...
                                (forwardCorrect + forwardIncorrect));
fprintf('Total correct percent: %f\n', ...
                        (forwardCorrect + backwardCorrect) / numSims);
