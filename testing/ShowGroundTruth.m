function [ tool_names, task_groundtruth, gt_per_categ, mu, sigma ] = ShowGroundTruth( dataset_folder, task )
    [ tool_names, tool_masses, task_groundtruth ] = ReadGroundTruth([dataset_folder 'groundtruth_' task '.csv']);
    figure; title('Groundtruth for each tool');
    plot(task_groundtruth);
    ax = gca;
    ax.XTickLabel = tool_names;
    ax.XTickLabelRotation = 90;
    ax.XTick = 1:size(tool_names,2);  
    legend(['Ground Truth: ' task ' n-tools: ' num2str(size(tool_names,2))]);    
    figure; 
    histogram(tool_masses);
    title('Histogram of mass');
    figure; 
    histogram(task_groundtruth);
    title('Histogram of groundtruth');
    gt_per_categ = zeros(1,4);
    for i=1:4
       gt_per_categ(i) = size(task_groundtruth(task_groundtruth==i),1);  
    end
    n_categs = 4;
    n_iter = 10^6;
    task_groundtruth = task_groundtruth';
    random_categ_scores = randi(n_categs,n_iter,size(task_groundtruth,2));
%     ratings = sum(n_categs-abs(bsxfun(@minus,random_categ_scores,categ_scores)),2)/size(categ_scores,2); hold on;
    ratings = zeros(n_iter,1);
    parfor i=1:n_iter
        ratings(i) = Metric1(random_categ_scores(i,:),task_groundtruth,n_categs);
    end
    figure;
    histogram(ratings);
    mu = mean(ratings);
    sigma = std(ratings);
    title_name = 'Random ratings: ';
    title_name = [title_name ' mu:' num2str(mu) ' sigma:' num2str(sigma)];
    title(title_name);
end

