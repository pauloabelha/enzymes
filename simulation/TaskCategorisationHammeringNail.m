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
        if simulation_score(i) < 0.0035
            category(i) = 1;
            continue;
        end
        if simulation_score(i) < 0.0064 
            category(i) = 2;
            continue;
        end
        if simulation_score(i) < 0.0074
            category(i) = 3;
            continue;
        end
        category(i) = 4;
    end
end

