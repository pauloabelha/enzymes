function [ categories, a, b, c, d ] = TaskCategorisationCuttingLasagna( simulation_score, eps )
    if ~exist('eps','var')
        eps = 0.001;
    end    
    a = 0.7933 ;
    b = 0.8306;
    c = 0.8911;
    d = 1;
    categories = zeros(size(simulation_score));
    for i=1:length(simulation_score)
        if isnan(simulation_score(i))
            categories(i) = -1;
            continue;
        end
        if simulation_score(i) < a
            categories(i) = 1;
            continue;
        end
        if simulation_score(i) < b
            categories(i) = 2;
            continue;
        end
        if simulation_score(i) < c
            categories(i) = 3;
            continue;
        end
        categories(i) = 4;
    end


end

