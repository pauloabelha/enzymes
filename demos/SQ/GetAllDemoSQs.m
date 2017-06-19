function [ SQs, SQ_types ] = GetAllDemoSQs( plot_fig )
    if ~exist('plot_fig','var')
        plot_fig = 1;
    end
    SQ_types = GetDemoSQ;
    SQs = cell(1,numel(SQ_types));
    for i=1:numel(SQ_types)
        disp(SQ_types{i});
        figure;        
        SQs{i} = GetDemoSQ(SQ_types{i});
        superellipsoid(SQs{i},plot_fig);
        title(SQ_types{i});
    end
end

