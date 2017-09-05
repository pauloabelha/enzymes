function [best_scores_mtx, best_categ_scores_mtx, best_ptools, best_ptool_maps, gpr_scores, tools_gt, test_pcls_filenames ] = Project( task, test_folder, gpr, gpr_dim_ixs, n_seeds )
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
    % sometimes the string for task comes transposed (don't ask me why...)
    if size(task,1) > 1
        task = task';
    end
    [ tool_names, tool_masses, tools_gt ] = ReadGroundTruth([test_folder 'groundtruth_' task '.csv']);
    tools_gt_new = [];
    for j=1:numel(test_pcls_filenames)    
        found_pcl_name = 0;
        for i=1:numel(tool_names)
            if strcmp(tool_names{i},GetPCLShortName(test_pcls_filenames{j}))
                tools_gt_new(end+1) = tools_gt(i);
                found_pcl_name  =1;
                break;
            end
        end
        if ~found_pcl_name
           error(['could not find groundtruth for tool: ' test_pcls_filenames{j}]);
        end
    end
    tools_gt = tools_gt_new';
    gpr_scores = zeros(1,numel(test_pcls_filenames));
    tot_toc = 0;
    [~, ~, weights ] = ProjectionHyperParams;
    n_weight_tries = size(weights,1);
    best_ix = round(n_weight_tries/2)+1;
    best_scores_mtx = zeros(numel(test_pcls_filenames),n_weight_tries);
    best_categ_scores_mtx = best_scores_mtx;
    best_ptools_cell =  cell(numel(test_pcls_filenames));
    best_ptool_maps_cell = cell(numel(test_pcls_filenames));
    %% get ideal ptool (from maximum of gpr prediction over its training data)
    [~,max_gpr_ix] = max(gpr.predict(gpr.ActiveSetVectors));
    ideal_ptool = gpr.ActiveSetVectors(max_gpr_ix,:);
    disp(['Projecting ' num2str(numel(test_pcls_filenames)) ' tools on ' test_folder ' using ' num2str(n_seeds) ' seeds']);
    disp(['Name' char(9) char(9) char(9) char(9) 'Raw score' char(9) 'Categ Score' char(9) 'Categ Groundtruth' char(9) 'Accuracy' char(9) 'Metric 1' char(9) 'Expected time']);
    seed_project_verbose = 1;
    backup_file_path = [test_folder 'projection_result_' task backup_suffix '.mat'];
    add_segms = 1;
    for i=1:numel(test_pcls_filenames)
        tic; 
        best_score = -1;
%         try
            P = ReadPointCloud([test_folder test_pcls_filenames{i}],100);
            [ best_scores_mtx(i,:), best_categ_scores_mtx(i,:), best_ptools, best_ptool_maps ] = SeedProjection( P, tool_masses(i), task, @TaskFunctionGPR, {gpr, gpr_dim_ixs}, n_seeds, add_segms, seed_project_verbose );             
            best_ptools_cell{i} = best_ptools;
            best_ptool_maps_cell{i} = best_ptool_maps;              
            best_score = best_scores_mtx(i,best_ix);            
            curr_best_categ = best_categ_scores_mtx(1:i,best_ix)';
            curr_tools_gt = tools_gt(1:i)';
            curr_metric1 = Metric1(curr_best_categ,curr_tools_gt,4);
            curr_acc = size(curr_best_categ(abs(curr_best_categ-curr_tools_gt)==0),2)/size(curr_best_categ,2);
            msg = [test_pcls_filenames{i}(1:end-4) char(9) char(9) num2str(best_score,2) char(9) char(9) num2str(curr_best_categ(i)) char(9) char(9) num2str(tools_gt(i)) char(9) char(9) char(9) num2str(curr_acc,2) char(9) char(9) num2str(curr_metric1,2) char(9) char(9)];
%         catch E
%            disp(['Error on tool ' test_pcls_filenames{i}]);
%            file_name = E.stack.file;
%            line_num = E.stack.line;
%            disp([E.message ' File: ' file_name ' - line: ' num2str(line_num)]); 
%            msg = 'Error';
%         end        
        [tot_toc, estimated_time_hours] = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,numel(test_pcls_filenames),'',1);
        disp([msg datestr(estimated_time_hours, 'HH:MM:SS')]);
        save(backup_file_path);
    end
%     [accuracy_best,accuracy_categs,metric_1,metric_2] = PlotTestResults( best_scores, best_categ_scores, tools_gt', test_pcls_filenames, 0, 0 );
%     disp(['Saving results to:' char(9) backup_file_path]);
%     save(backup_file_path);
end

