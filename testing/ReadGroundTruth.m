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
function [ tool_names, tool_masses, task_groundtruth ] = ReadGroundTruth( filepath )    
    csv_groundtruth = ReadCSVGeneric(filepath);    
    tool_names = cell(1,size(csv_groundtruth,1));
    tool_masses = zeros(size(csv_groundtruth,1),1);
    task_groundtruth = zeros(size(csv_groundtruth,1),1);
    for i=1:size(csv_groundtruth,1)
        tool_names{i} = csv_groundtruth{i,1};
        tool_masses(i) = str2double(csv_groundtruth{i,2});
        task_groundtruth(i) = str2double(csv_groundtruth{i,3});
    end
end

