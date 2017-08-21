function [ accs, accuracy_categs_all, metrics1, max_accs, max_metrics1 ] = ReadProjectionAblations( root_folder, task, file_date )
    %% check params
    if ~exist('root_folder','var')
        error('Please define a root folder as first param');
    end
    CheckIsChar(root_folder);
    if ~exist('task','var')
        error('Please define a task name as second param');
    end
    CheckIsChar(task);
    if ~exist('file_date','var')
        file_date = date;
    end
    CheckIsChar(file_date);
    %% get files form folder according to prefix
    projection_file_prefix = ['projection_result_' task '_' file_date];
    projection_filenames = FindAllFilesOfPrefix(projection_file_prefix,root_folder);
    n_projs = numel(projection_filenames);
    accs = ReadProjectionAblation([root_folder projection_filenames{1}]);
    n_weights = size(accs,1);
    accs = zeros(n_projs,n_weights);
    metrics1 = accs;
    accuracy_categs_all = zeros(n_projs,n_weights,4);
    n_seeds = zeros(n_projs,1);
    plot_legend_nseeds = cell(n_projs,1);
    for i=1:n_projs
       [accs(i,:), accuracy_categs, metrics1(i,:)] = ReadProjectionAblation([root_folder projection_filenames{i}], task); 
       accuracy_categs_all(i,:,:) = accuracy_categs;
       accs(i,:) = fliplr(accs(i,:));
       metrics1(i,:) = fliplr(metrics1(i,:));
       a=strsplit(projection_filenames{i},'_'); 
       n_seeds(i) = str2double(a{end-1});
       plot_legend_nseeds{i} = a{end-1};
    end
    max_accs = max(accs,[],2);
    max_metrics1 = max(metrics1,[],2);
    % plot accs 1
    figure; for i=1:size(accs,1) plot(accs(i,:)); hold on; end; hold off;
    title('Accuracy accross weights');
    legend(plot_legend_nseeds);
    axes = gca;
    axes.YLim = [0 1];
    % plot accs per categ    
    % plot metrics 1
    figure; for i=1:size(metrics1,1) plot(metrics1(i,:)); hold on; end;
    title('Metric 1 accross weights');
    legend(plot_legend_nseeds);
    axes = gca;
    axes.YLim = [0 1];
end

