function [ category ] = TaskCategorisationScoopingGrains( simulation_scores, eps )
    if ~exist('eps','var')
        eps = 0.001;
    end    
    category = zeros(size(simulation_scores));
    for i=1:length(simulation_scores)
        if isnan(simulation_scores(i))
            category(i) = -1;
            continue;
        end
        if simulation_scores(i) < 4.875
            category(i) = 1;
            continue;
        end
        if simulation_scores(i) < 5.822
            category(i) = 2;
            continue;
        end
        if simulation_scores(i) < 6.413
            category(i) = 3;
            continue;
        end
        category(i) = 4;
    end
end
