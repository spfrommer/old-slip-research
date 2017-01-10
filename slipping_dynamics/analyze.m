numCorrect = 0;
forwardCorrect = 0;
backwardCorrect = 0;
forwardIncorrect = 0;
backwardIncorrect = 0;

numSims = 200;

xFors = zeros(1, numSims);
xBacks = zeros(1, numSims);
xDots = zeros(1, numSims);
sizes = ones(1, numSims) * 50;
controls = zeros(1, numSims);

for i = 1 : numSims
    [control, predicted, spBack, spFor] = examineSim(i, false);
    
    xFor = spBack.finalProfileX - spBack.initialState(3);
    xBack = spBack.initialState(3);
    xDot = spBack.initialState(4);
    
    xFors(i) = xFor;
    xBacks(i) = xBack;
    xDots(i) = xDot;
    controls(i) = max(control, 0);
    
    if control == 1 && predicted == 1
        forwardCorrect = forwardCorrect + 1;
    elseif control == -1 && predicted == -1
        backwardCorrect = backwardCorrect + 1;
    elseif control == 1 && predicted == -1
        forwardIncorrect = forwardIncorrect + 1;
    elseif control == -1 && predicted == 1
        backwardIncorrect = backwardIncorrect + 1;
    end
end

colormap(copper);
scatter3(xFors, xBacks, xDots, sizes, controls);

fprintf('Backward correct percent: %f\n', backwardCorrect / ...
                                (backwardCorrect + backwardIncorrect));
fprintf('Forward correct percent: %f\n', forwardCorrect / ...
                                (forwardCorrect + forwardIncorrect));
fprintf('Total correct percent: %f\n', ...
                        (forwardCorrect + backwardCorrect) / numSims);
