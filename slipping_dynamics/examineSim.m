function [ er ] = examineSim( simNum, displayVisual, picBaseName )
    if nargin < 2
        [displayVisual, picBaseName] = deal(false, 'none');
    elseif nargin < 3
        picBaseName = 'none';
    end
    
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
        if displayVisual
            disp('Only backwards step possible!');
        end
        er.control = -1;
    elseif flagF >= 0 && flagB < 0
        if displayVisual
            disp('Only forwards step possible!');
        end
        er.control = 1;
    else
        if er.costBack > er.costFor
            if displayVisual
                disp('Forwards step is better!');
            end
            er.control = 1;
        else
            if displayVisual
                disp('Backwards step is better!');
            end
            er.control = -1;
        end
    end
    
    [er.predicted, er.predFor, er.predBack] = predict(er.spFor);
    
    if displayVisual
        if er.predicted > 0
            disp('Forward step was predicted');
        else
            disp('Backward step was predicted');
        end
        
        vp = VisParams();
        if ~strcmp(picBaseName, 'none')
            vp.picName = strcat(picBaseName, 'b');
        end
        
        if flagB >= 0
            [optimal, sp] = deal(er.optimalBack, er.spBack); %#ok<ASGLU>
            visualize
        end
        
        if ~strcmp(picBaseName, 'none')
            vp.picName = strcat(picBaseName, 'f');
        end
        if flagF >= 0
            [optimal, sp] = deal(er.optimalFor, er.spFor); %#ok<ASGLU>
            visualize
        end
    end
    
    fclose(fid);
end