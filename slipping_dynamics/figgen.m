% Generates starting images for all runs
for i=1:217
   er = examineSim(i, true, strcat('start', num2str(i)));
   close all;
end