%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
%
%% This function will read tool names and ground truth from a CSV file
% Inputs:
%   filepath - full path to CSV file
% Outputs:
%   tool_names - call array with names of the tools
%   task_groundtruth - array with the ground truth values for each tool
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ tool_names, task_groundtruth ] = ReadGroundTruth( filepath )    
    csv_groundtruth = ReadCSVGeneric(filepath);
    task_groundtruth = zeros(size(csv_groundtruth,1),1);
    task_groundtruth = task_groundtruth -1;
    tool_names = {};
    for i=1:size(csv_groundtruth,1)
        if ~strcmp(csv_groundtruth{i,4},'')
            task_groundtruth(i) = str2double(csv_groundtruth{i,4});
        end
        tool_names{end+1} = csv_groundtruth{i,1};
    end
end

