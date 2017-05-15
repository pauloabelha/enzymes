function [best_scores, best_categ_scores, best_ptools, best_ptool_maps, Ps, gpr_scores, gpr_categ_scores, tools_gt, test_pcls_filenames, accuracy_best,accuracy_categs,metric_1,metric_2] = Project( task, test_folder, gpr )
    %% get all test pcls
    test_pcls_filenames = FindAllFilesOfType( {'ply'}, test_folder );
    %% get groundtruth for existing tools
    GT = ReadCSVGeneric([test_folder 'groundtruth_' task '.csv']);
    for i=1:numel(test_pcls_filenames)
        found_gt = 0;
        for j=1:size(GT,1)            
            if strcmp(GetPCLShortName(test_pcls_filenames{i}),GT{j,2})
               gt = str2double(GT{j,4});
               mass = str2double(GT{j,3});
               found_gt = 1;
               break;
            end
        end
        if found_gt
            tools_gt(i) = gt;
            tools_mass(i) = mass;
        else
           disp(['Could not find GT for tool ' test_pcls_filenames{i}]); 
        end
    end  
    gpr_scores = zeros(1,numel(test_pcls_filenames));
    tot_toc = 0;
    best_scores = zeros(1,numel(test_pcls_filenames));
    best_ptools =  zeros(numel(test_pcls_filenames),21);
    best_ptool_maps = zeros(numel(test_pcls_filenames),6);
    Ps = cell(1,numel(test_pcls_filenames));
    %% get ideal ptool (from maximum of gpr prediction over its training data)
    [~,max_gpr_ix] = max(gpr.predict(gpr.ActiveSetVectors));
    ideal_ptool = [.01 .01 .1 .1 1 0 0 gpr.ActiveSetVectors(max_gpr_ix,:)];
    disp(['Projecting ' num2str(numel(test_pcls_filenames)) ' tools on ' test_folder]);
    for i=1:numel(test_pcls_filenames)
        tic; 
        try
            Ps{i} = ReadPointCloud([test_folder test_pcls_filenames{i}],100);
            [ ptools, ~, Ps{i}, ] = ExtractPToolRawPCL( Ps{i}, tools_mass(i) );
            %[ best_scores(i), best_ptools(i,:), best_ptool_maps(i,:) ] = ProjectionSimple( Ps{i}, tools_mass(i), @TaskFunctionGPR, gpr );
            [ best_scores(i), best_ptools(i,:), best_ptool_maps(i,:) ] = SeedProjection( ideal_ptool, Ps{i}, tools_mass(i), task, @TaskFunctionGPR, gpr, 1 ); 
            gpr_ptool_scores = gpr.predict(ptools(:,8:end));
            gpr_scores(i) = max(gpr_ptool_scores);
        catch E
           disp(['Error on tool  ' test_pcls_filenames{i} ' - probably memory :(']);
           disp(E.message);
        end
        msg = ['Projected ' test_pcls_filenames{i} char(9) char(9) num2str(best_scores(i)) char(9) char(9) num2str(TaskCategorisation(best_scores(i),task)) char(9) char(9) num2str(tools_gt(i)) char(9)];
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,numel(test_pcls_filenames),msg);
        save([test_folder 'projection_result_' task '.mat'])
    end
    gpr_categ_scores = TaskCategorisation(gpr_scores,task);
    best_categ_scores = TaskCategorisation(best_scores,task);
    [accuracy_best,accuracy_categs,metric_1,metric_2] = PlotTestResults( best_scores, best_categ_scores, tools_gt, test_pcls_filenames );
    save([test_folder 'projection_result_' task '.mat']);
end

