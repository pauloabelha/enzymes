function [ category, a, b, c, d ] = TaskCategorisationLiftingPancake( simulation_score, eps )
    if ~exist('eps','var')
        eps = 0.005;
    end
    a = 0.5650;
    b = 2;
    c = 2.6468;
    d = 3;
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


