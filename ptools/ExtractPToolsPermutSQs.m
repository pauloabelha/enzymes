function [ pTools_up, SQs_up, transfs_lists_up, recur_ix] = ExtractPToolsPermutSQs(SQs, mass, SQs_down, SQs_up, recur_ix, task)
    if ~exist('task','var')
        task='';
    end
    ix_segm = size(SQs_down,1)+1;
    if ix_segm == size(SQs,1) + 1
        recur_ix = recur_ix + 1;
        [pTools_up, transfs_lists_up] = ExtractPTools(SQs_down, mass, task);
        for i=1:size(pTools_up,2)
            pTools_up{i}.name = [pTools_up{i}.name '-' num2str(recur_ix)]; 
        end
        SQs_up{end+1} = SQs_down;       
       return;
    end
    pTools_up = {};   
    transfs_lists_up = {};
    for ix_SQ_fit=1:size(SQs{ix_segm},2)
        [pTools_up{end+1}, SQs_up, transfs_lists_up{end+1}, recur_ix] = ExtractPToolsPermutSQs(SQs, mass, [SQs_down; SQs{ix_segm}{ix_SQ_fit}], SQs_up, recur_ix, task);
    end
    % flatten the return cell arrays (otherwise they'd be a nested tree) 
    pTools = {};
    transfs_lists = {};
    for i=1:size(pTools_up,2)
        for j=1:size(pTools_up{i},2)
            pTools{end+1} = pTools_up{i}{j};
            transfs_lists{end+1} = transfs_lists_up{i}{j};    
        end
    end
    pTools_up = pTools; 
    transfs_lists_up = transfs_lists;
end