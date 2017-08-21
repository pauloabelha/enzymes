% By Paulo Abelha
% This demo plots all typical SQs
% if plot_fig is 0, the function only gives back the typical SQs and types
function [ SQs, SQ_types ] = GetAllDemoSQs( plot_fig )
    if ~exist('plot_fig','var')
        plot_fig = 1;
    end
    SQ_types = GetDemoSQ;
    SQs = cell(1,numel(SQ_types));
    for i=1:numel(SQ_types)
        disp(SQ_types{i});
        SQs{i} = GetDemoSQ(SQ_types{i});
        if plot_fig
            figure;
        end
        SQ2PCL( SQs{i}, 10000, plot_fig );
        if plot_fig
            title(SQ_types{i});
        end
    end
end

