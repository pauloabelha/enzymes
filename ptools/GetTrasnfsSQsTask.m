function [ transf_list ] = GetTrasnfsSQsTask( SQ_grasp, SQ_action, task, grasp_centre )
        if ~exist('task','var') || isempty(task)
            transf_list = {};
            return;
        end
        if ~exist('grasp_centre','var')
            grasp_centre = [0 0 0];
        end
        %% initialise transformations list
        transf_list = cell(1,4);
        %% get task params
        [task_action_vec, task_centres_dir, isCorrect] = getTaskOrientationParams(task);
        % original direction is the action part zVector
        action_vec = GetSQVector( SQ_action );
        %% 1st Rotation : align the action part with the task action vector
        % Get rotation matrix between action part zVector and the new direction
        r = vrrotvec(action_vec,task_action_vec);
        rot_1 = vrrotvec2mat(r);
        transf_list{1} = rot_1;
         % rotate the vector between centres and get its unit vecto
        vec_centres = [SQ_action(end-2:end) - SQ_grasp(end-2:end)]';
        vec_centres_unit = UnitVector( vec_centres );
        vec_centres_unit = rot_1*vec_centres_unit;
        %% 2nd Rotation : align the object with the task plane               
        % Formula of the projection : proj_vec = orig_vec-(orig_vec.normal_vec)*normal_vec 
        % Where normal_vec is the vector normal to the plan, here the action vec.
        vec_centres_perp_proj = vec_centres_unit-dot(vec_centres_unit,task_action_vec)*task_action_vec;
        % /!\ 
        % Sometimes vectors are colinear. To get rid of this issue, we trick the
        % following part since it doesn't need to be rotated. We can also pu the
        % whole following code in the first condition and do nothing if they
        % actually are colinear.
        if norm(vec_centres_perp_proj)>0.005
            vec_centres_perp_proj = UnitVector( vec_centres_perp_proj );
        else
            vec_centres_perp_proj = task_centres_dir;
        end
        % Get rotation matrix in order to align this vector to the given vector,
        % so we get the vec_centers in the action plan :
        r = vrrotvec(vec_centres_perp_proj, task_centres_dir);
        rot_2 = vrrotvec2mat(r);
        transf_list{2} = rot_2;
        % update unit vector between centres
        vec_centres_unit = rot_2*vec_centres_unit;
        %% 3rd Rotation : align the object with the task plane
        % If the tool is reversed, rotate it by pi along the new_centers_dir axis
        % Test : if the dot product does not return the good value for the given task (positive or negative).
        % For further information see the getTaskOrientationParams function.
        % rotate the vector between centres and get its unit vector
        transf_list{3} = [];
        if ~isCorrect(dot(vec_centres_unit,task_action_vec))
            % Rotation matrix around any direction (unit vector) : 
            % defined in Graphics Gems (Glassner, Academic Press, 1990). Webpage 
            % referencing this matrix found at : 
            % https://www.fastgraph.com/makegames/3drotation/
            %
            %     [ tx^2+c  txy-sz  txz+sy ]
            % R = [ txy+sz  ty^2+c  tyz-sx ]
            %     [ txz-sy  tyz+sx  tz^2+c ]
            %
            % where c=cos(theta),s=sin(theta),t=1-cos(theta)
            % and [x;y;z] a unit vector on the axis of rotation.
            % 
            % We have theta = pi, and [x;y;z] = new_centers_dir :
            c = -1; 
            s = 0; 
            t = 2;
            x = task_centres_dir(1);
            y = task_centres_dir(2);
            z = task_centres_dir(3);
            rot_3 = [ t*x^2+c    t*x*y-s*z  t*x*z+s*y;...
                  t*x*y+s*z  t*y^2+c    t*y*z-s*x;...
                  t*x*z-s*y  t*y*z+s*x  t*z^2+c     ];

            % update SQs
            transf_list{3} = rot_3;
        end    
        %% Move tool base center (grasp center) to the origin in X,Y,Z
        centre_base = Apply3DTransformations( {grasp_centre}, transf_list );
        centre_base = centre_base{1};
        transf_list{4} = [[eye(3); 0 0 0] [-centre_base'; 1]];
end

