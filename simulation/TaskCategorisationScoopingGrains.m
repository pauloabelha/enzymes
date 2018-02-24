function [ category, a, b, c, d ] = TaskCategorisationScoopingGrains( simulation_scores, eps )
    if ~exist('eps','var')
        eps = 0.001;
    end    
    a = 1;
    b = 3;
    c = 4;
    d = 5;
    category = zeros(size(simulation_scores));
    for i=1:length(simulation_scores)
        if isnan(simulation_scores(i))
            category(i) = -1;
            continue;
        end
        if simulation_scores(i) < a
            category(i) = 1;
            continue;
        end
        if simulation_scores(i) < b
            category(i) = 2;
            continue;
        end
        if simulation_scores(i) < c
            category(i) = 3;
            continue;
        end
        category(i) = 4;
    end
end
