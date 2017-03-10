%FLATTEN_CELL  flatten a nested cell array of any depth
%   flat_list = flatten_cell(LIST) returns a 1-level cell array in depth-first order (left to right)

% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
% inspired by a Prolog-like programming style :)
function [ flat_list ] = flatten_cell( list )
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
    % if we are at a leaf, accumulate it
    if ~iscell(list)
        accum_list{end+1} = list;
    % else, for every child accumulate its leaves
    else        
        for i=1:numel(list)
           accum_list = flatten_cell_accum(list{i},accum_list); 
        end
    end
end



