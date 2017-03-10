
function [ transf_list ] = PtoolsTaskTranfs( ptools, task )
    if ~exist('task','var')
        error('This function requires a task name as a second param');
    else
        if isempty(task)
            transf_list = {};
            return;
        end
    end
    % if ptools is a cell array, transform it to a N x 21 matrix
    ptools = PTool2Matrix( ptools );
    transf_list = cell(size(ptools,1),4);
    for i=1:size(ptools,1)
        [SQ_grasp, SQ_action] = GetPToolsSQs(ptools(i,:));
        transf_list(i,:) = GetTrasnfsSQsTask( SQ_grasp, SQ_action, task );
    end
end



