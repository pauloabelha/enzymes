function S = SetDifference(cell1,cell2)
    S = {};
    for i=1:numel(cell1)
        if ~ismember(cell1{i},cell2)
            S{end+1} = cell1{i};
        end
    end
        
end