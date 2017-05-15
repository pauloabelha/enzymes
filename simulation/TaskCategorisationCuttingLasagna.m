function [ categories ] = TaskCategorisationCuttingLasagna( simulation_score, eps )
    if ~exist('eps','var')
        eps = 0.001;
    end    
    categories = zeros(size(simulation_score));
    for i=1:length(simulation_score)
        if isnan(simulation_score(i))
            categories(i) = -1;
            continue;
        end
        if simulation_score(i) < 0.7933 
            categories(i) = 1;
            continue;
        end
        if simulation_score(i) < 0.8306
            categories(i) = 2;
            continue;
        end
        if simulation_score(i) < 0.8911
            categories(i) = 3;
            continue;
        end
        categories(i) = 4;
    end


end

