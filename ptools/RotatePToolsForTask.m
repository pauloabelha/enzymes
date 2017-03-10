% rotate a list ptools for a task
% the function outputs the transformations used
function [ Ps, transf_list ] = RotatePToolsForTask( ptools, task )
    %% check ptool params
    % if ptools is a cell array, transform it to a N x 21 matrix
    if iscell(ptools)
       ptools = flatten_cell(ptools);
       new_ptools = zeros(numel(ptools),21);
       for i=1:numel(ptools)
           if numel(ptools{i}) ~= 21
               error(['One of the p-tools (#' num2str(i) ') is not a 1x21 array']);
           end
           new_ptools(i,:) = ptools{i};
       end   
       ptools = new_ptools;
    end 
    Ps = cell(size(ptools,1),1);
    ptools_map = zeros(size(ptools,1),6);
    for i=1:size(ptools,1)
        Ps{i} = PTool2PCL(ptools(i,:));
        ptools_map(i,:) = [0 0 0 0 0 1];
    end
    [Ps, transf_list ] = RotatePCLsWithPtoolsForTask( Ps, ptools, ptools_map, task );
end

