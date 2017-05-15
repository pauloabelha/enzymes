%LIST_DEPTH  returns the depth (max) of a nested list
%   list_depth = list_depth(LIST) returns the depth (max) of a nested list

% By Paulo Abelha (p.abelha@abdn.ac.uk) 2017
% inspired by a Prolog-like programming style :)
function [ depth ] = list_depth( list )
    if ~exist('list','var')
        error('This function needs an input');
    end
    if ~iscell(list)
        error('This function needs a cell array as input');
    end
    % call the accumulator version of the function
    depth = list_depth_accum( list, 0 );
end

function [ depth ] = list_depth_accum( list, counter )
    % if we are at a leaf, accumulate it
    if ~iscell(list)
        depth = counter;
    % else, for every child accumulate its leaves
    else        
        max_depth = counter;
        for i=1:numel(list)
           sibling_depth = list_depth_accum(list{i},counter+1); 
           if sibling_depth > max_depth
               max_depth = sibling_depth;
           end
        end
        depth = max_depth;
    end    
end