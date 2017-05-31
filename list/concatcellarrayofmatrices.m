function [ m ] = concatcellarrayofmatrices( array, row )
    array = flatten_cell(array);
    m = [];
    for i=1:numel(array)
        if row
            m = [m; array{i}];
        else
            m = [m array{i}];
        end
        if i > 88
           a=0; 
        end
    end
end


