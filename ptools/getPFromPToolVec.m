% This function allows to get the P structure from a PTool vector.
% P contains the vertices (points), the normals and the faces of the tool.
% Allows to plot it too
function [P,list_SQs,transf_list] = getPFromPToolVec(ptool, task, n_points_per_segm, plot_it, no_faces)

if ~exist('n_points_per_segm','var')
    n_points_per_segm = 2500;
end

if ~exist('plot_it','var')
    plot_it = 0;
end

if ~exist('no_faces','var')
    no_faces = 0;
end

%% Recreate the SQs
% Put grasp SQ at the origin with no orientation ("pointing up")
grasp_SQ = [ptool(1:5) 0 0 0 ptool(6:7) 0 0 0 0 0];
grasp_vec = [0;0;1];

% get centre point of action from ptool relationship
rm = vrrotvec2mat(ptool(15:18));
vec_centres = rm*grasp_vec;
dist_centres = ptool(22);
vec_centres = (vec_centres*dist_centres)';

action_SQ = [ptool(8:12) ptool(19:21) ptool(13:14) 0 0 vec_centres];

% % Calc position for action SQ
% % In x : dist*sin(beta)
% action_posX = pTool_vec(17)*sin(pTool_vec(16));
% % In Y : no offset
% action_posY = 0;
% % In z : dist*cos(beta)
% action_posZ = pTool_vec(17)*cos(pTool_vec(16));
% 
% % Note : alpha is theta Euler angle (ZYZ), and Rho & Phi are at 0
% action_SQ = [pTool_vec(8:12) 0 pTool_vec(15) 0 pTool_vec(13:14) 0 0 action_posX action_posY action_posZ];

% rotate SQs to get the good tool orientation for simulation
list_SQs = {grasp_SQ, action_SQ};

if exist('task','var') && ~strcmp(task,'')
    [list_SQs,transf_list] = rotateSQs(list_SQs, 1, 2, task);
else
    transf_list = {};
end

%% Get Point clouds, normals and faces
[grasp_pcl, grasp_normals] = UniformSQSampling3D(list_SQs{1}, 1, n_points_per_segm);

[action_pcl, action_normals] = UniformSQSampling3D(list_SQs{2}, 1, n_points_per_segm);
if no_faces
    P = 0;
else
    %grasp_faces = delaunay(grasp_pcl(:,1), grasp_pcl(:,2), grasp_pcl(:,3));
    %action_faces = delaunay(action_pcl(:,1), action_pcl(:,2), action_pcl(:,3));
    
    grasp_faces = convhull(grasp_pcl);
    action_faces = convhull(action_pcl);    
    
    %% Concatenate in P struct
    P.f = [grasp_faces ; action_faces+size(grasp_pcl,1)];
    P.f = P.f - 1;
    %P.f = P.f-1; % so that indexes begin at 0 and not 1 (as Matlab does)
    P.n = [grasp_normals ; action_normals];
    P.v = [grasp_pcl ; action_pcl];
    P.segms = {};
    P.segms{end+1}.v = grasp_pcl;
    P.segms{end}.n = grasp_normals;
    P.segms{end+1}.v = action_pcl;
    P.segms{end}.n = action_normals;
end

P.u = zeros(size(P.v,1),1);
P.u(size(grasp_pcl,1)+1:end) = 1;

P = AddColourToSegms(P);





%% To plot or not to plot? That is the question...
if plot_it == 1
    PlotPCLSegments(P);
end

end