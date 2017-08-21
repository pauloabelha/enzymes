function [ pretty_str ] = PrettyCellArrayString( cell_str )
    length_cell_str = numel(cell_str);
    pretty_str = [];
    for i=1:length_cell_str-2
        pretty_str = [pretty_str cell_str{i} ', '];
    end
    pretty_str = [pretty_str cell_str{length_cell_str-1} ' and ' cell_str{length_cell_str}];
end

