function [ category ] = TaskCategorisation( simulation_scores, task_name )
    eps = 0.0001; 
    simulation_scores(simulation_scores<0) = 0;
    switch task_name
        case 'hammering_nail'
            category = TaskCategorisationHammeringNail(simulation_scores,eps);
            return;
        case 'lifting_pancake'
            category = TaskCategorisationLiftingPancake(simulation_scores,eps);
            return;
        case 'rolling_dough'
            category = TaskCategorisationRollingDough(simulation_scores,eps);
            return;
        case 'cutting_lasagna'
            category = TaskCategorisationCuttingLasagna(simulation_scores,eps);
            return;
    end
    error(['Could not get category score of unknown task: ' task_name]);
end

