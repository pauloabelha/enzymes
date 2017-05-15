function [ ptools ] = PTool2Matrix( ptools )
    %% check ptool params
    % if ptools is a cell array, transform it to a N x 21 matrix
    if iscell(ptools)
       ptools = flatten_cell(ptools);
       new_ptools = [];
       for i=1:numel(ptools)
           for j=1:size(ptools{i},1)
               if numel(ptools{i}(j,:)) ~= 21
                   error(['One of the p-tools (#' num2str(i) ') is not a 1x21 array']);
               end
               new_ptools(end+1,:) = ptools{i}(j,:);
           end
       end   
       ptools = new_ptools;
    end
    % check if the ptools matrix is Nx25
    if size(ptools,2) ~= 25
       error('The p-tool(s) should have 21 elements'); 
    end

end

