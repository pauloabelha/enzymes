function [ pcls, cut_point_slices, cut_belief ] = CutPCLDemocritus2( pcl, slice_size, run_pca )
%     if PCLBoundingBoxVolume(pcl) < slice_size/200
%         pcls = {pcl};
%         cut_point_slices = {};
%         cut_belief = Inf;        
%         return;
%     end
    if ~exist('run_pca','var')
        run_pca = 1;
    end
    pca_pcl = eye(3);
    if run_pca
       pca_pcl = pca(pcl);
    end
    pcl = pcl*pca_pcl;
    % define the min range
    min_range = slice_size*0.8;
    dim = 1;
    [slices, ranges] = SlicePointCloud(pcl, dim, slice_size);
    % if there is less than two slices, return
    if numel(slices) < 2
        pcls = {pcl};
        cut_point_slices = {};
        cut_belief = Inf;
        return;
    end
    % in case last slice is too small, merge it with penultimate one
    if ranges(end,1) < min_range
        slices{end-1} = concatcellarrayofmatrices({slices{end-1}, slices{end}},1);
        slices = slices(1:end-1);
        ranges = ranges(1:end-1,:);
    end
    % chec if there are empty slices;
    % if so, segm pcl at those points
    cut_ixs = [];
    cut_ixs_belief = [];
    found_empty_slice = 0;
    for i=1:numel(slices)
        if isempty(slices{i}) || size(slices{i},1) < 5
            found_empty_slice = 1;
            cut_ixs(end+1) = i;
            cut_ixs_belief(end+1) = Inf;
        end
    end
    diffs = ones(size(diff(ranges,2),1),1);
    for i=1:3
        if i ~= dim
            diffs = diffs.* abs(diff(ranges(:,i),2));
        end
    end
    % spread the prob of the first clie through all the rest
    P_diff_ranges = diffs(2:end)/sum(diffs(2:end)); 
    [a, b] = sort(P_diff_ranges,'descend');
    %% walk in the prob dist until the desired vol is achieved
    tot_vol = trapz(a);
    desired_prob_vol_prop = 0.8;
    desired_prob_vol = tot_vol*desired_prob_vol_prop;
    curr_vol = 0;
    i = 0;
    b_ixs = [];
    while curr_vol < desired_prob_vol
        i = i +1;
        curr_vol = trapz(a(1:i));
        b_ixs(end+1) = i;        
    end    
    
    [cut_ixs,c] = sort(b(b_ixs));
    num_peaks = 0;
    l = -2;
    for i=1:numel(cut_ixs)
        if cut_ixs(i) > l + 2
            num_peaks = num_peaks + 1;            
        end
        l = cut_ixs(i);
    end
    num_peaks = sum(mod(cut_ixs,2));
    cut_ixs_belief = P_diff_ranges(b(b_ixs));
    cut_ixs_belief = cut_ixs_belief(c);
    final_ixs = cut_ixs_belief >= max(0.2,0.5/(num_peaks+1));
    cut_ixs = cut_ixs(final_ixs);
    %cut_ixs = cut_ixs(cut_ixs ~= 1 & cut_ixs ~= numel(diffs));
    cut_ixs_belief = cut_ixs_belief(final_ixs);
    prev_cut_ixs = -2;
    cut_ixs = sort(cut_ixs,'ascend');
    new_cut_ixs = [];
    cut_ixs = cut_ixs(cut_ixs ~= 1);
    for i=1:numel(cut_ixs)
        if cut_ixs(i) > prev_cut_ixs + 2
            stds = zeros(1,3);
            for j=1:3
                stds(j) = std(ranges(cut_ixs(i):cut_ixs(i)+2,j));
            end
            [~,j] = max(stds);
            triad_ranges = ranges(cut_ixs(i):cut_ixs(i)+2,j);
            sum_lines = zeros(1,3);
            for j=1:3       
                sum_line = 0;
                for k=1:3
                   sum_line = sum_line + abs(triad_ranges(j) - triad_ranges(k));
                end
                sum_lines(j) = sum_line;
            end
            [~,add] = max(sum_lines);
            add = max(0, add - 2);
            new_cut_ixs(end+1) = min(numel(slices)-1,cut_ixs(i) + add);
            prev_cut_ixs = cut_ixs(i);
        end
    end
    cut_ixs = new_cut_ixs;
    if isempty(cut_ixs)
        new_cut_ixs = [];
        new_cut_ixs_belief = [];
    else
        new_cut_ixs = cut_ixs(1);
        new_cut_ixs_belief = cut_ixs_belief(1);
    end
    for i=1:numel(cut_ixs)
        if cut_ixs(i) > new_cut_ixs(end) + 3
            new_cut_ixs(end+1) = cut_ixs(i);
            new_cut_ixs_belief(end+1) = cut_ixs_belief(i);
        end
    end
    cut_belief = sum(new_cut_ixs_belief);
    new_cut_ixs = [0 new_cut_ixs];
    pcls = {};
    for i=2:numel(new_cut_ixs)
        pcls{end+1} = concatcellarrayofmatrices(slices(new_cut_ixs(i-1)+1:new_cut_ixs(i)),1);
    end
    if isempty(new_cut_ixs)
        new_cut_ixs = 0;
    end
    if new_cut_ixs(end) < numel(slices)
        pcls{end+1} = concatcellarrayofmatrices(slices(new_cut_ixs(end)+1:end),1);
    end    
    cut_point_slices = {};
    for i=2:numel(new_cut_ixs)
        cut_point_slices{end+1} = slices{new_cut_ixs(i)};
    end
    for i=1:numel(pcls)
        pcls{i} = pcls{i}/pca_pcl;
    end
    
    for i=1:numel(pcls)
        [slices, ranges] = SlicePointCloud(pcls{i}, 2, slice_size);
        found_empty_slicing = 0;
        stack = [];
        prev_non_empty = 1;
        for j=1:numel(slices)
            stack = [stack; slices{j}];
            if isempty(slices{j})
                if prev_non_empty
                    pcls{end+1} = stack;
                    stack = [];
                    prev_non_empty = 0;
                    found_empty_slicing = 1;
                end
            else
                prev_non_empty = 1;
            end
        end
        pcls{end+1} = stack;
        pcls{i} = [];
    end
    pcls = remove_empty(pcls);   
end