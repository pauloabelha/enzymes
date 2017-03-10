function [ task_functions ] = GetTaskFunctions( task )
    n_parts=2;
    for part=1:n_parts          
        for dim=1:3
            task_functions.size{part,dim} = 'linear';
            task_functions.size_score{part,dim} = 'model';
            task_functions.shape_proportion{part,dim}= 'linear';
            task_functions.shape_proportion_score{part,dim} = 'model';
        end
    end
    task_functions.distance = 'linear';
    task_functions.distance_score = 'model';
    task_functions.angle_z = 'linear';
    task_functions.angle_z_score = 'model';
    task_functions.angle_center = 'linear';
    task_functions.angle_center_score = 'model';
    switch(task)
        case 'hammering_nail'
            task_functions.size{2,1} = 'quadratic_linear';
            task_functions.size{2,2} = 'quadratic_linear';
            task_functions.angle_z_score = pi/2;
        case 'tenderising_meat'
            task_functions.size{2,1} = 'quadratic_linear_linear';
            task_functions.size{2,2} = 'quadratic_linear_linear';
            task_functions.size{2,3} = 'quadratic_linear_linear';
            task_functions.size_score{2,1} = 0.1;
            task_functions.size_score{2,2} = 0.1;
            task_functions.size_score{2,3} = 0.05;
        case 'cutting_lasagne'
            task_functions.angle_z_score = pi/2;
            task_functions.angle_center_score = 0;
            task_functions.size{2,3} = 'linear_quadratic';
            task_functions.size_score{2,3} = 0.0025;
        case 'piercing_food'
            task_functions.angle_z = 'constant';
            task_functions.angle_center = 'constant';
            task_functions.size{2,1} = 'linear_quadratic';
            task_functions.size{2,2} = 'linear_quadratic';
            task_functions.size{2,3} = 'constant';
            task_functions.distance = 'constant';
            for dim=2:3
                task_functions.shape_proportion{2,dim}= 'constant';
                task_functions.shape_proportion_score{2,dim} = 'model';
            end
        case 'scooping_sugar'
            task_functions.size{2,1} = 'linear_quadratic';
            task_functions.size{2,2} = 'linear_quadratic';
            task_functions.size{2,3} = 'linear_quadratic';
       case 'retrieving_from_gap'
            task_functions.size{2,3} = 'linear_quadratic';
    end
end

