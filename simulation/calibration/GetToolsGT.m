%% get groundtruth for existing tools
function [tools_gt, tool_names] = GetToolsGT(dataset_folder, task, tools)  
    tool_names = {};
    if ~exist('tools','var')
        tool_names = FindAllFilesOfType({'ply'},dataset_folder, 1);
    else
       for i=1:numel(tools)
           tool_names{end+1} = tools{i}.name;
       end        
    end
    [ tool_names, tool_masses ] = ReadGroundTruth([root_folder 'groundtruth_hammering_nail.csv']);
    GT = ReadCSVGeneric([dataset_folder 'groundtruth_' task '.csv']);
    gt_scores = cell2mat(GT(:,4));
    tools_gt = zeros(1,numel(tool_names));
    for i=1:numel(tool_names)
        found_gt = 0;
        for j=1:size(GT,1)            
            if strcmp(tool_names{i},GT{j,2})
                gt = str2double(GT{j,4});
                found_gt = 1;
                break;
            end
        end
        if found_gt
            tools_gt(i) = gt;
        else
           disp(['Could not find GT for tool ' tool_names{i}]); 
        end
    end  
end
