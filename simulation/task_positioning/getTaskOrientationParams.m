    % Here you can put the vectors used to rotate SQs in order to get them ready for simulation.
function [ new_action_orientation_vector, new_centers_orientation_vector, isCorrect ] = getTaskOrientationParams( task )

% new_action_orientation_vector : 
%               The vector defining the direction the tool action part 
%               will be pointing at, at the beginning of the simulation.

% new_centers_orientation_vector : 
%               the vector representing the projection of the centers vector
%               on the plane whose normal is the new_action_orientation_vector

% /!\ isCorrect : Anonymous function which returns the good result for the
%               future comparison in rotateSQs function.
%               It will tell if the dot product between new_action_vec and
%               the vector between centers should whether be positive or
%               negative.
%               For example, it should be positive for hammering but
%               negative for lifting.

% /!\ if vectors are expected to be colinear (ex: rolling pin for its task)
%     just put any vector perpendicular to the action dir for the second 
%     vector. This will allow rotateSQs code to be running correctly. 
%     More explanations in rotateSQs.

% /!\ Before the reversing test in rotateSQs, if dot product between action
%     dir and vec_centers equals to 0, the tool does not need to be 
%     reversed, that's why there is a "equal" symbol in isCorrect 
%     comparison function.

% /!\ Vectors need to be unit vectors !

switch(task)
    case 'hammering_nail'
        new_action_orientation_vector = [1;0;0]; 
        new_centers_orientation_vector = [0;0;1];
        isCorrect = @(dot_prod) dot_prod>=0;
        
    case 'lifting_pancake'
        new_action_orientation_vector = [0;0;1];
        new_centers_orientation_vector = [1;0;0];
        isCorrect = @(dot_prod) dot_prod<=0;
        
    case 'rolling_dough'
        new_action_orientation_vector = [0;1;0];
        new_centers_orientation_vector = -[-1;0;1]/norm([-1;0;1]);
        isCorrect = @(dot_prod) 1 ;
    
    case 'cutting_lasagna'
        new_action_orientation_vector = [0;1;0];
        new_centers_orientation_vector = [0;0;-1];
        isCorrect = @(dot_prod) dot_prod>=0;
        
    case 'scooping_grains'
        new_action_orientation_vector = [0;0;1];
        new_centers_orientation_vector = [1;0;0];
        isCorrect = @(dot_prod) dot_prod<=0;
        
   otherwise
        error(['Task ''' task ''' does not exist']);
end

end

