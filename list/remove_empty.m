%REMOVE_EMPTY  returns the depth (max) of a nested list
%   list_depth = remove_empty(LIST) returns the depth (max) of a nested list

% By Paulo Abelha (p.abelha@abdn.ac.uk) 2017
% inspired by a Prolog-like programming style :)
function [ ret_list ] = remove_empty( list )
    if ~exist('list','var')
        error('This function needs an input');
    end
    if ~iscell(list)
        error('This function needs a cell array as input');
    end
    % call the accumulator version of the function
    ret_list = remove_empty_accum( list, {} );
end

function [ accum_list ] = remove_empty_accum( list, accum_list )
    % if we are at a leaf, accumulate it
    if ~iscell(list)
        if ~isempty(list)
            accum_list{end+1} = list;
        end
    % else, for every child accumulate its leaves
    else        
        for i=1:numel(list)
           accum_list = remove_empty_accum(list{i},accum_list); 
        end
    end
end