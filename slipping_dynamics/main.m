for i = 1:300
    slipPatch = [0, 0.8 + rand() * 1];
    stateI = randState(slipPatch);
    finX = slipPatch(2) + 0.1;
    
    disp('-------------NEW SIMULATION-----------------');
    disp('--------OPTIMIZING BACKWARDS STEP-----------');
    
    spBack = SimParams(['sli'; 'stl'; 'str'], slipPatch, stateI, finX);
    [ optimalB, costB, flagB ] = runSim(spBack);
    
    disp('--------OPTIMIZING FORWARDS STEP------------');
    
    spFor = SimParams(['sli'; 'str'], slipPatch, stateI, finX);
    [ optimalF, costF, flagF ] = runSim(spFor);
    
    fid = fopen(strcat('datawork/sim', num2str(i), '.txt'), 'w');
    fprintf(fid, '%.12f,', slipPatch);
    fprintf(fid, '\n');
    fprintf(fid, '%.12f,', stateI);
    fprintf(fid, '\n');
    fprintf(fid, '%.12f\n', finX);
    
    fprintf(fid, '%.12f,', optimalB);
    fprintf(fid, '\n');
    fprintf(fid, '%.12f\n', costB);
    fprintf(fid, '%d\n', flagB);
    
    fprintf(fid, '%.12f,', optimalF);
    fprintf(fid, '\n');
    fprintf(fid, '%.12f\n', costF);
    fprintf(fid, '%d\n', flagF);
    fclose(fid);
end