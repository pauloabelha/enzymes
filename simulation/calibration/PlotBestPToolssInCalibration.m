function [ best_tools_ixs, best_ptools_ixs ] = PlotBestPToolssInCalibration( dataset_folder, tools, best_ptool_scores, task )
    epsilon_ = 0.1;
    max_tool_score = max(best_ptool_scores);
    best_tools_ixs = [];
    best_ptools_ixs = [];
    for i=1:numel(best_ptool_scores)
        if best_ptool_scores(i) >= (max_tool_score - epsilon_)
            best_tools_ixs(end+1) = i;
            max_ptool_score = 1e-10;
            best_j = 0;
            for j=1:numel(tools{i}.tool_scores.ptool_median_scores)
                if tools{i}.tool_scores.ptool_median_scores(j) > max_ptool_score
                   max_ptool_score = tools{i}.tool_scores.ptool_median_scores(j);
                   best_j = j;
                end
            end
            best_ptools_ixs(end+1) = best_j;
        end
    end
    pcl_filenames = FindAllFilesOfType( {'ply'}, dataset_folder );
    Ps = {};
    for i=1:numel(best_tools_ixs)
        for j=1:numel(pcl_filenames)
            if strcmp(tools{best_tools_ixs(i)}.name,GetPCLShortName(pcl_filenames{j}))
                Ps{end+1} = ReadPointCloud([dataset_folder pcl_filenames{j}]);
            end
        end
    end
    ptools = [];
    ptools_maps = [];
    for i=1:numel(best_tools_ixs)
        ptools(end+1,:) = tools{best_tools_ixs(i)}.ptools(best_ptools_ixs(i),:);
        ptools_maps(end+1,:) = tools{best_tools_ixs(i)}.ptools_maps(best_ptools_ixs(i),:);
    end
    [ Ps, transf_list ] = RotatePCLsWithPtoolsForTask( Ps, ptools, ptools_maps, task );
    for i=1:numel(best_tools_ixs)
        PlotPCLSegments(Ps{i});
        PlotPtools(tools{best_tools_ixs(i)}.ptools(best_ptools_ixs(i),:),task,1);
    end
end

