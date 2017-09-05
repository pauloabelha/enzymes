function [ category, a, b, c ] = TaskCategorisation( simulation_scores, task_name )
    eps = 0.0001; 
    simulation_scores(simulation_scores<0) = 0;
    switch task_name
        case 'hammering_nail'
            [category, a, b, c] = TaskCategorisationHammeringNail(simulation_scores,eps);
            return;
        case 'lifting_pancake'
            [category, a, b, c] = TaskCategorisationLiftingPancake(simulation_scores,eps);
            return;
        case 'rolling_dough'
            [category, a, b, c] = TaskCategorisationRollingDough(simulation_scores,eps);
            return;
        case 'cutting_lasagna'
            [category, a, b, c] = TaskCategorisationCuttingLasagna(simulation_scores,eps);
            return;
        case 'scooping_grains'
            [category, a, b, c] = TaskCategorisationScoopingGrains(simulation_scores,eps);
            return;
    end
    error(['Could not get category score of unknown task: ' task_name]);
end

