function [ category, a, b, c, d ] = TaskCategorisation( simulation_scores, task_name )
    eps = 0.0001; 
    simulation_scores(simulation_scores<0) = 0;
    switch task_name
        case 'hammering_nail'
            [category, a, b, c, d] = TaskCategorisationHammeringNail(simulation_scores,eps);
            return;
        case 'lifting_pancake'
            [category, a, b, c, d] = TaskCategorisationLiftingPancake(simulation_scores,eps);
            return;
        case 'rolling_dough'
            [category, a, b, c, d] = TaskCategorisationRollingDough(simulation_scores,eps);
            return;
        case 'cutting_lasagna'
            [category, a, b, c, d] = TaskCategorisationCuttingLasagna(simulation_scores,eps);
            return;
        case 'scooping_grains'
            [category, a, b, c, d] = TaskCategorisationScoopingGrains(simulation_scores,eps);
            return;
    end
    error(['Could not get category score of unknown task: ' task_name]);
end

