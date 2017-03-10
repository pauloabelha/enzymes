function [ best_scores, best_pTools, all_pTools, all_pTools_struct, best_categ_scores, mode_categ_scores, categ_scores_gt, accuracy_best, accuracy_mode ] = TestVasPureGPR( root_folder, task_name, gpr, write_ptools )
    if ~exist('gpr','var')
        load([root_folder 'gpr_' task_name '.mat']);
    end
    if ~exist('write_ptools','var')
        write_ptools=0;
    end
    % load matlab data
    
    load([root_folder 'groundtruth.mat']);    
    if exist('table_gt','var')
        groundtruth=table_gt;
    end
    % find task index
    task_ix = 0;
    table_gt_cols = groundtruth.Properties.VariableNames;
    for j=1:size(table_gt_cols,2)
        if strcmp(task_name,table_gt_cols{j})
            task_ix=j;
            break;
        end
    end
    if task_ix < 1
        error(['Could not find task ' task_name ' in groundtruth file ' root_folder 'groundtruth.csv']);
    end    
    pcl_filenames = FindAllFilesOfType( {'ply'},root_folder);
    if isempty(pcl_filenames)
        error(['There are no *.ply files in root folder: ' root_folder]);
    end
    % get category score ground truth for the dataset
    categ_scores_gt = zeros(1,size(pcl_filenames,2));
    ix_categ_scores_gt = 0;
    masses_pcls = [];
    tot_toc = 0;
    for i=1:size(pcl_filenames,2)  
        tic;
        pcl_shortname = GetPCLShortName( pcl_filenames{i} );
        for j=1:size(groundtruth.tool,1)
            found_gt_pcl = 0;
            if isempty(strfind(groundtruth.tool{j},'.ply'))
                pcl_shortname_gt = groundtruth.tool{j};
            else
                pcl_shortname_gt = groundtruth.tool{j}(1:strfind(groundtruth.tool{j},'.ply')-1);
            end
            if strcmp(pcl_shortname,pcl_shortname_gt)
                ix_categ_scores_gt=ix_categ_scores_gt+1;
                found_gt_pcl = 1;
                categ_scores_gt(ix_categ_scores_gt) = groundtruth{j,task_ix};
                masses_pcls(end+1) = groundtruth.mass(j);
                break
            end  
        end
        if ~found_gt_pcl
           error(['Could not find groundtruth for ' pcl_shortname ' in the file ' root_folder 'groundtruth.csv']); 
        end
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(pcl_filenames,2));
    end
    best_scores = zeros(1,size(pcl_filenames,2));
    best_categ_scores = zeros(1,size(pcl_filenames,2));
    mode_categ_scores = zeros(1,size(pcl_filenames,2));
    best_pTools = {};
    all_pTools  ={};
    all_pTools_struct = {};
    tot_toc = 0;
    for i=1:size(pcl_filenames,2)  
        tic
        try
            [ best_pTool, pTools, pToolsStruct, ~, best_affordance_score, ~, best_categ_score, mode_categ_score] = VAS_PureGPR( root_folder, pcl_filenames{i}, masses_pcls(i), table_gt_cols{task_ix}, gpr, write_ptools);
            all_pTools{end+1} = pTools;
            all_pTools_struct{end+1} = pToolsStruct;
            best_pTools{end+1} = best_pTool;
            best_scores(i) = best_categ_score;
            mode_categ_scores(i) = mode_categ_score;
            disp(['Processed pointcloud ' pcl_filenames{i} '(' num2str(masses_pcls(i)) ' kg)']);
            disp(['    Predicted Mode Category: ' num2str(mode_categ_scores(i)) '; Predicted Best Category: ' num2str(best_categ_score) ' (' num2str(best_affordance_score)  '); Ground Truth Category: ' num2str(categ_scores_gt(i))]);
            tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(pcl_filenames,2) );
        catch E
            best_pTools{end+1} = zeros(1,24);
            warning(E.message); 
        end        
    end
    best_categ_scores = best_scores;
    disp('Finished processing');
    [accuracy_best, accuracy_mode] = PlotTestResults( best_categ_scores, mode_categ_scores, categ_scores_gt  );
end

