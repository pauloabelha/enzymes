function [best_scores, best_categ_scores, best_ptools, best_ptool_maps, Ps, gpr_scores, tools_gt, test_pcls_filenames ] = Project( task, test_folder, gpr, gpr_dim_ixs, n_seeds )
    backup_suffix = ['_' date];
    if exist('n_seeds','var')
        backup_suffix = [backup_suffix '_' num2str(n_seeds) '_seeds'];
    else
        n_seeds = -1;
    end
    if ~exist('gpr_dim_ixs','var') || (numel(gpr_dim_ixs)==1 && gpr_dim_ixs == -1)
        gpr_dim_ixs = 1:size(gpr.ActiveSetVectors,2);
    end        
    %% get all test pcls
    test_pcls_filenames = FindAllFilesOfType( {'ply'}, test_folder );
    %% get groundtruth for existing tools
    [ tool_names, tool_masses, tools_gt ] = ReadGroundTruth([test_folder 'groundtruth_' task '.csv']);
    tools_gt_new = [];
    for i=1:numel(tool_names)
        found_pcl_name = 0;
        for j=1:numel(test_pcls_filenames)
            if strcmp(tool_names{i},GetPCLShortName(test_pcls_filenames{j}))
                tools_gt_new(end+1) = tools_gt(i);
                found_pcl_name  =1;
                break;
            end
        end
        if ~found_pcl_name
           error(['could not find groundtruth for tool: ' tool_names{i}]);
        end
    end
    tools_gt = tools_gt_new';
    gpr_scores = zeros(1,numel(test_pcls_filenames));
    tot_toc = 0;
    best_scores = zeros(1,numel(test_pcls_filenames));
    best_categ_scores = best_scores;
    best_ptools =  zeros(numel(test_pcls_filenames),25);
    best_ptool_maps = zeros(numel(test_pcls_filenames),6);
    Ps = cell(1,numel(test_pcls_filenames));
    %% get ideal ptool (from maximum of gpr prediction over its training data)
    [~,max_gpr_ix] = max(gpr.predict(gpr.ActiveSetVectors));
    ideal_ptool = gpr.ActiveSetVectors(max_gpr_ix,:);
    disp(['Projecting ' num2str(numel(test_pcls_filenames)) ' tools on ' test_folder ' using ' num2str(n_seeds) ' seeds']);
    disp(['Name' char(9) char(9) char(9) char(9) 'Raw score' char(9) 'Categ Score' char(9) 'Categ Groundtruth' char(9) 'Accuracy' char(9) 'Metric 1' char(9) 'Expected time']);
    seed_project_verbose = 0;
    backup_file_path = [test_folder 'projection_result_' task backup_suffix '.mat'];
    for i=1:numel(test_pcls_filenames)
        tic; 
        try
            P = ReadPointCloud([test_folder test_pcls_filenames{i}],100);
            [ best_scores(i), best_ptools(i,:), best_ptool_maps(i,:) ] = SeedProjection( ideal_ptool, P, tool_masses(i), task, @TaskFunctionGPR, {gpr, gpr_dim_ixs}, n_seeds, seed_project_verbose ); 
            best_categ_scores(i) = TaskCategorisation(best_scores(i),task);
        catch E
           disp(['Error on tool  ' test_pcls_filenames{i} ' (maybe memory?)']);
           disp(E.message);
        end
        curr_best_categ = best_categ_scores(1:i);
        curr_tools_gt = tools_gt(1:i)';
        curr_metric1 = Metric1(curr_best_categ,curr_tools_gt,4);
        curr_acc = size(curr_best_categ(abs(curr_best_categ-curr_tools_gt)==0),2)/size(curr_best_categ,2);
        msg = [test_pcls_filenames{i}(1:end-4) char(9) char(9) num2str(best_scores(i),2) char(9) char(9) num2str(best_categ_scores(i)) char(9) char(9) num2str(tools_gt(i)) char(9) char(9) char(9) num2str(curr_acc,2) char(9) char(9) num2str(curr_metric1,2) char(9) char(9)];
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,numel(test_pcls_filenames),msg);
        save(backup_file_path)
    end
%     [accuracy_best,accuracy_categs,metric_1,metric_2] = PlotTestResults( best_scores, best_categ_scores, tools_gt', test_pcls_filenames, 0, 0 );
%     disp(['Saving results to:' char(9) backup_file_path]);
%     save(backup_file_path);
end

