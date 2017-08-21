function [ all_prop_values, set_all_prop_values, prop_values_incidence ] = HistogramProperty( litreview_path, property )
    if ~exist('property','var') || isempty(property)
       error('Please provide a property'); 
    end
    litreview = ReadCSVGeneric(litreview_path);
    %% find property index
    found_prop = 0;
    for i=1:size(litreview,1)
        for j=1:size(litreview,2)
            if strcmp(litreview{i,j},property)
                found_prop = 1;
                break;
            end
        end
        if found_prop
            break;
        end
    end
    if ~found_prop
       error(['Could not find property: ' property]); 
    end
    %% get all values
    start_ix = i + 1;
    prop_ix = j;
    all_prop_values = {};
    for i=start_ix:size(litreview,1)
        values = ParseField(litreview{i,prop_ix});
        disp(values);
        for j=1:numel(values)
            all_prop_values{end+1} = values{1};
        end
    end
    %% get set of unique values
    [prop_values_incidence,set_all_prop_values] = CountIncidenceCellArrayofStr( all_prop_values );
    %% plot incidences
    plot(prop_values_incidence);
    ax = gca;
    ax.XTickLabel = set_all_prop_values;
    ax.XTickLabelRotation = 90;
    ax.XTick = 1:size(set_all_prop_values,2);
end

