function [ category, a, b, c, d ] = TaskCategorisationHammeringNail( simulation_score, eps )
    if ~exist('eps','var')
        eps = 0.001;
    end    
    a = 0.003;
    b = 0.004;
    c = 0.0044;
    d = 0.015;
    category = zeros(size(simulation_score));
    for i=1:length(simulation_score)
        if isnan(simulation_score(i))
            category(i) = -1;
            continue;
        end
        if simulation_score(i) < a
            category(i) = 1;
            continue;
        end
        if simulation_score(i) < b
            category(i) = 2;
            continue;
        end
        if simulation_score(i) < c
            category(i) = 3;
            continue;
        end
        category(i) = 4;
    end
end

