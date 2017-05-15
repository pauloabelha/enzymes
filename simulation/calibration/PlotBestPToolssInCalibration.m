function [ max_tools, max_tools_ixs, max_ptool_ixs, max_scores ] = PlotBestPToolssInCalibration( calib_res_path )
    MAX_N_TOOLS_PLOT = 40;
    load(calib_res_path);
    ixs = best_ptool_scores > 1 & best_ptool_scores < 50;
    a_123 = 1:numel(tools);
    max_tools_ixs = a_123(ixs);
    max_tools = tools(ixs);
    max_ptool_ixs = zeros(1,numel(max_tools));
    max_scores = zeros(1,numel(max_tools));
    Ps = cell(1,numel(max_tools));
    for i=1:numel(max_tools)
        [max_scores(i), max_ptool_ixs(i)] = max(max_tools{i}.ptool_median_scores);
        P = RotatePCLsWithPtoolsForTask( max_tools{i}.P, max_tools{i}.ptools(max_ptool_ixs(i),:), max_tools{i}.ptools_maps(max_ptool_ixs(i),:), task );
        Ps{i} = P{1};
    end
    [max_scores_sorted, sort_ixs] = sort(max_scores,'descend');
    max_tools_sorted = max_tools(sort_ixs);
    max_tools_ixs_sorted = max_tools_ixs(sort_ixs);
    max_ptool_ixs_sorted = max_ptool_ixs(sort_ixs);
    Ps = Ps(sort_ixs);
    for i=1:numel(max_tools)
       if i > MAX_N_TOOLS_PLOT
           break;
       end
       PlotPCLSegments(Ps{i});
       title([max_tools_sorted{i}.name '-' num2str(max_tools_ixs_sorted(i)) '-' num2str(max_ptool_ixs_sorted(i)) '-' num2str(max_scores_sorted(i))]);
    end
end

