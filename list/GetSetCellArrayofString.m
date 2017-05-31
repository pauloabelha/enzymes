function [ set_values ] = GetSetCellArrayofString( values )
    set_values = {};
    for i=1:numel(values)
        found_value = 0;
        for j=1:numel(set_values)
            if strcmp(values{i},set_values{j})
                found_value = 1;
                break;
            end
        end
        if ~found_value
            set_values{end+1} = values{i};
        end
    end

end

