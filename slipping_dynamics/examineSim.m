function [ control, predicted ] = examineSim( simNum, displayVisual )
    fid = fopen(strcat('data/sim', num2str(simNum), '.txt'), 'r');
    slipPatch = sscanf(fgetl(fid), '%f,')';
    stateI = sscanf(fgetl(fid), '%f,');
    finX = sscanf(fgetl(fid), '%f');
    
    optimalB = sscanf(fgetl(fid), '%f,');
    costB = sscanf(fgetl(fid), '%f');
    flagB = sscanf(fgetl(fid), '%f');

    optimalF = sscanf(fgetl(fid), '%f,');
    costF = sscanf(fgetl(fid), '%f');
    flagF = sscanf(fgetl(fid), '%f');
    
    spBack = SimParams(['sli'; 'stl'; 'str'], slipPatch, stateI, finX);
    spFor = SimParams(['sli'; 'str'], slipPatch, stateI, finX);
    
    if flagB >= 0 && flagF < 0
        if displayVisual
            disp('Only backwards step possible!');
        end
        control = -1;
    elseif flagF >= 0 && flagB < 0
        if displayVisual
            disp('Only forwards step possible!');
        end
         control = 1;
    else
        if costB > costF
            if displayVisual
                disp('Forwards step is better!');
            end
            control = 1;
        else
            if displayVisual
                disp('Backwards step is better!');
            end
            control = -1;
        end
    end
    
    predicted = predict(spFor);
    
    if displayVisual
        if predicted > 0
            disp('Forward step was predicted');
        else
            disp('Backward step was predicted');
        end
        
        if flagB >= 0
            optimal = optimalB;
            sp = spBack;
            visualize
        end

        if flagF >= 0
            optimal = optimalF;
            sp = spFor;
            visualize
        end
    end
    
    fclose(fid);
end