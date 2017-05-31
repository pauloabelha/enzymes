function [ incidences, set_values ] = CountIncidenceCellArrayofStr( values )
    [ set_values ] = GetSetCellArrayofString( values );
    incidences = zeros(numel(set_values),1);
    for i=1:numel(set_values)
       for j=1:numel(values)
           if strcmp(set_values{i},values{j})
               incidences(i) = incidences(i) + 1;
           end
       end
    end
end

