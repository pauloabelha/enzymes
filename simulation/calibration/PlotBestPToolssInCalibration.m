function [ max_names, Ps, max_ptools, max_ptools_ixs, max_ptools_maps, max_tools_ixs ] = PlotBestPToolssInCalibration( calib_res_path )
    load(calib_res_path);
    max_tool_score = max(best_ptool_scores(best_ptool_scores > 0 & best_ptool_scores < 80));
    max_tools = tools(best_ptool_scores >= max_tool_score);
    max_names = cell(numel(max_tools),1);
    max_ptools = zeros(numel(max_tools),21);
    a_123 = 1:numel(best_ptool_scores);
    max_tools_ixs = a_123(best_ptool_scores >= max_tool_score);
    max_ptools_ixs = zeros(numel(max_tools),1);
    max_ptools_maps = zeros(numel(max_tools),6);
    Ps = cell(numel(max_tools),1);
    parfor i=1:numel(max_tools)
        max_score = -10;
        max_score_ix = -1;
        for j=1:size(max_tools{i}.ptool_median_scores,2)
            if max_tools{i}.ptool_median_scores(j) > max_score
                max_score = max_tools{i}.ptool_median_scores(j);
                max_score_ix = j;
            end
        end
        max_ptools_ixs(i) = max_score_ix;
        max_ptools(i,:) = max_tools{i}.ptools(max_score_ix,:);
        max_ptools_maps(i,:) = max_tools{i}.ptools_maps(max_score_ix,:);
        Ps{i} = max_tools{i}.P;
        max_names{i} =  max_tools{i}.name;
    end
    Ps = RotatePCLsWithPtoolsForTask( Ps, max_ptools, max_ptools_maps, task );
    for i=1:numel(max_tools)
        PlotPCLSegments(Ps{i});
        %PlotPtools(max_ptools(i,:),task);
    end
end

