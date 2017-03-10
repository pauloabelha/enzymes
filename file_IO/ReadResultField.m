function [ field_value ] = ReadResultField( str_split, field_value, line, field_name, field_type, ix_ignore )
    length_field_name = length(field_name);
    if strcmp(field_type,'whole_line')
        field_value = line;
    else
        if strcmp(field_name,'') || (length(line) > length_field_name && strcmp(line(1:length_field_name),field_name))
            if strcmp(field_type,'number')
                field_value = str2num( line(length_field_name+2:end) );
            end
            if strcmp(field_type,'string')
                field_value = line(length_field_name+2:end);
            end
            if strcmp(field_type,'number_array')
                if strcmp(field_name,'')        
                    if strcmp(str_split,'inv')
                        field_value = strsplit(line,' ');
                    else
                        field_value = strsplit(' ',line);
                    end
                else
                    field_value = line(length_field_name+2:end);
                    if strcmp(str_split,'inv')
                        field_value = strsplit(field_value,' ');
                    else
                        field_value = strsplit(' ',field_value);
                    end
                end
                size_field_value = size(field_value,2)-ix_ignore;
                field_value_array = zeros(1,size_field_value);
                for i=1:size_field_value
                    field_value_array(i) = str2num(field_value{i});
                end
                field_value = field_value_array;
            end
        end
    end
end

