function [ category ] = TaskCategorisationLiftingPancake( simulation_score, eps )
    if ~exist('eps','var')
        eps = 0.005;
    end
    category = zeros(size(simulation_score));
    for i=1:length(simulation_score)
        if isnan(simulation_score(i))
            category(i) = -1;
            continue;
        end
        if simulation_score(i) < 0.5650
            category(i) = 1;
            continue;
        end
        if simulation_score(i) < 2
            category(i) = 2;
            continue;
        end
        if simulation_score(i) < 2.6468
            category(i) = 3;
            continue;
        end
        category(i) = 4;
    end
end


