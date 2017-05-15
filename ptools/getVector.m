%% This function returns the vector of a pTool from its structure
function [ pTool_vec ] = getVector(pTool)

pTool_grasp = [pTool.grasp.SQ(1:5) pTool.grasp.SQ(9:10)];
pTool_action = [pTool.action.SQ(1:5) pTool.action.SQ(9:10)];
% pTool_relations = [pTool.alpha pTool.beta pTool.dist];
% pTool_inertiaParams = [pTool.mass pTool.center_mass(1) pTool.center_mass(2) pTool.center_mass(3) pTool.inertia(1,1) pTool.inertia(2,2) pTool.inertia(3,3)];
% 
% pTool_vec = [pTool_grasp, pTool_action, pTool_relations, pTool_inertiaParams];

% new pTool vec
pTool_vec = [pTool_grasp, pTool_action, pTool.rot_centre pTool.action_eul_ang pTool.dist pTool.mass];

end