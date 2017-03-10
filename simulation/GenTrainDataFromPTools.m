%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
%
%% Generate Gazebo-ready tools for a given task from a list of p-tools
% Inputs:
%   root_path - folder where the Gazebo tool models will be written
%   pTools - N * 24 (or 18) matrix of N p-tools
%       if pTools is N * 18 matrix, then the function will get the
%       remaining dims (centre of mass, inertia) and write it to a file
%   task - name of the task (currently working only for 'hammering_nail'
% Outputs:
%   pTools_24dims - N * 24 matrix with every pTool used to create tools
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ pTools_24dims ] = GenTrainDataFromPTools( root_path, pTools, task )
    pTools_24dims = [];
    switch task
        case 'hammering_nail'
            pTools_24dims = zeros(size(pTools,1),24);
            parfor i=1:size(pTools,1)
                [ ~, pTools_24dims(i,:) ] = pToolVec2Sim( root_path, num2str(i), pTools(i,:), 0.07, 0.325, 0.3 );
            end
            dlmwrite([root_path 'pTools_24dims.txt'],pTools_24dims);  
    end
end