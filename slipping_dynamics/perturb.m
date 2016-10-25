function [ perturbed ] = perturb( funparams )
    perturbed = funparams + (rand(length(funparams), 1) - 0.5) * 0.2;
end

