function [ category ] = TaskCategorisationHammeringNail( simulation_score, eps )
    if ~exist('eps','var')
        eps = 0.001;
    end    
    category = zeros(size(simulation_score));
    for i=1:length(simulation_score)
        if isnan(simulation_score(i))
            category(i) = -1;
            continue;
        end
        if simulation_score(i) < 0.003
            category(i) = 1;
            continue;
        end
        if simulation_score(i) < 0.004 
            category(i) = 2;
            continue;
        end
        if simulation_score(i) < 0.005
            category(i) = 3;
            continue;
        end
        category(i) = 4;
    end
end

