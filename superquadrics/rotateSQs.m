%% Rotates all SQs to align Tool's action part along X, and get the tool in XZ plan
function [SQs,transf_list] = rotateSQs(SQs, grasp_ix, action_ix, task)

if ~iscell(SQs)
    temp = {};
    for i=1:size(SQs,1)
        temp{end+1} = SQs(i,:);
    end
    SQs = temp;
end


transf_list = {};
% new direction vectors for action and centers vec - grasp in the action plan
[new_action_dir, new_centers_dir, isCorrect] = getTaskOrientationParams(task);

% original direction is the action part zVector
orig_direction_vec = eul2rotm_(SQs{action_ix}(6:8),'ZYZ')*[0;0;1];

%% 1st Rotation : align action zVector with new given direction
% Get rotation matrix between action part zVector and the new direction
r = vrrotvec(orig_direction_vec,new_action_dir);
rm = vrrotvec2mat(r);

for i=1:size(SQs,2)
    SQs{i}(6:8) = rotm2eul_(rm*eul2rotm_(SQs{i}(6:8),'ZYZ'),'ZYZ');
    SQs{i}(end-2:end) = SQs{i}(end-2:end)*rm';
end

transf_list{end+1} = rm;

%% Get the object in the action plan : Align tool grasp
% Get the current vector Btween action and grasp centers,
% normalized, proj on the plan perpendicular to the (brand new) action dir
vec_centers = SQs{action_ix}(end-2:end)-SQs{grasp_ix}(end-2:end);

% Formula of the projection : proj_vec = orig_vec-(orig_vec.normal_vec)*normal_vec 
% Where normal_vec is the vector normal to the plan, here the action vec.
vec_centers_perp_proj = vec_centers'-dot(vec_centers,new_action_dir)*new_action_dir;

% /!\ 
% Sometimes vectors are colinear. to get rid of this issue, we trick the
% following part since it doesn't need to be rotated. We can also pu the
% whole following code in the first condition and do nothing if they
% actually are colinear.
if norm(vec_centers_perp_proj)~=0
    vec_centers_perp_proj = vec_centers_perp_proj/norm(vec_centers_perp_proj);
else
    vec_centers_perp_proj = new_centers_dir;
end

% OLD version with classical hammering plan : action plan is xz
% vec_centers_yz = [0;vec_centers(2);vec_centers(3)];
% vec_centers_yz = vec_centers_yz/norm(vec_centers_yz);

% Get rotation matrix in order to align this vector to the given vector,
% so we get the vec_centers in the action plan :
r = vrrotvec(vec_centers_perp_proj, new_centers_dir);
rm = vrrotvec2mat(r);

% update SQs
for i=1:size(SQs,2)
    SQs{i}(6:8) = rotm2eul_(rm*eul2rotm_(SQs{i}(6:8),'ZYZ'),'ZYZ');
    SQs{i}(end-2:end) = SQs{i}(end-2:end)*rm';
end

transf_list{end+1} = rm;

% Update vec_centers :
vec_centers = SQs{action_ix}(end-2:end)-SQs{grasp_ix}(end-2:end);
vec_centers = vec_centers/norm(vec_centers);


%% If the tool is reversed, rotate it by pi along the new_centers_dir axis

% Test : if the dot product does not return the good value for the given task (positive or negative).
% For further information see the getTaskOrientationParams function.
if ~isCorrect(dot(vec_centers',new_action_dir))
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
    x = new_centers_dir(1);
    y = new_centers_dir(2);
    z = new_centers_dir(3);
    R = [ t*x^2+c    t*x*y-s*z  t*x*z+s*y;...
          t*x*y+s*z  t*y^2+c    t*y*z-s*x;...
          t*x*z-s*y  t*y*z+s*x  t*z^2+c     ];
        
    % update SQs
    for i=1:size(SQs,2)
        SQs{i}(6:8) = rotm2eul_(R*eul2rotm_(SQs{i}(6:8),'ZYZ'),'ZYZ');
        SQs{i}(end-2:end) = SQs{i}(end-2:end)*R';
    end
    transf_list{end+1} = R;
end

%% Move tool base center (grasp center) to the origin in X,Y,Z
center_base = SQs{grasp_ix}(end-2:end);
% update SQs
for i=1:size(SQs,2)
    SQs{i}(end-2:end) = SQs{i}(end-2:end) - center_base;
end

transf_list{end+1} = [[eye(3); 0 0 0] [-center_base'; 1]];

end