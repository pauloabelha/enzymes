% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
% inspired by a Prolog-like programming style :)
function [ flat_list ] = flatten_cell_rmv_empty( list )
    if ~exist('list','var')
        error('This function needs an input');
    end
    if ~iscell(list)
        error('This function needs a cell array as input');
    end
    % call the accumulator version of the function
    flat_list = flatten_cell_accum( list, {} );
end

function [ accum_list ] = flatten_cell_accum( list, accum_list )
    % if we are at a non-empty leaf, accumulate it
    if isempty(list)
        return;
    end
    if ~iscell(list)
        accum_list{end+1} = list;
        return;
    end
    % else, for every child accumulate its leaves    
    for i=1:numel(list)
       accum_list = flatten_cell_accum(list{i},accum_list); 
    end
end