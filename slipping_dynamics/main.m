for i = 1:300
    slipPatch = [0, 1 + rand() * 1.5];
    stateI = randState(slipPatch);
    finX = slipPatch(2) + 0.1;
    
    spBack = SimParams(['sli'; 'stl'; 'str'], slipPatch, stateI, finX);
    [ optimalB, costB, flagB ] = runSim(spBack);
    
    spFor = SimParams(['sli'; 'str'], slipPatch, stateI, finX);
    [ optimalF, costF, flagF ] = runSim(spFor);
end