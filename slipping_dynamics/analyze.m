numCorrect = 0;
forwardCorrect = 0;
backwardCorrect = 0;
forwardIncorrect = 0;
backwardIncorrect = 0;

numSims = 100;

for i = 1 : numSims
    [control, predicted] = examineSim(i, false);
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

fprintf('Backward correct percent: %f\n', backwardCorrect / ...
                                (backwardCorrect + backwardIncorrect));
fprintf('Forward correct percent: %f\n', forwardCorrect / ...
                                (forwardCorrect + forwardIncorrect));
fprintf('Total correct percent: %f\n', ...
                        (forwardCorrect + backwardCorrect) / numSims);
