function [ max_tools, max_tools_ixs, max_ptool_ixs, max_scores ] = PlotBestPToolssInCalibration( calib_res_path )
    MAX_N_TOOLS_PLOT = 40;
    load(calib_res_path);
    ixs = best_ptool_scores > 0 & best_ptool_scores < 20;
%     [max_score,~] = max(best_ptool_scores(ixs));
%     ixs = ixs & best_ptool_scores >= (max_score-epislon);
    a_123 = 1:numel(tools);
    max_tools_ixs = a_123(ixs);
    max_tools = tools(ixs);
    max_ptool_ixs = zeros(1,numel(max_tools));
    max_scores = zeros(1,numel(max_tools));
    for i=1:numel(max_tools)
        if i > MAX_N_TOOLS_PLOT
            warning(['Max number of tools reached: ' num2str(MAX_N_TOOLS_PLOT)]);
            break;
        end
        [max_scores(i), max_ptool_ixs(i)] = max(max_tools{i}.ptool_median_scores);
        P = RotatePCLsWithPtoolsForTask( max_tools{i}.P, max_tools{i}.ptools(max_ptool_ixs(i),:), max_tools{i}.ptools_maps(max_ptool_ixs(i),:), task );
        PlotPCLSegments(P{1});
        title([max_tools{i}.name '-' num2str(max_tools_ixs(i)) '-' num2str(max_ptool_ixs(i)) '-' num2str(max_scores(i))]);
%         PlotPtools(max_tools{i}.ptools(max_ptool_ix,:),task);
    end
end

