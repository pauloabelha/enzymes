function [ ratings, hist, p, mu, sigma ] = GetRandomRatings( categ_scores, n_categs, n_iter, comparison_values, comparison_names, title_name, plot_fig )
    if ~exist('n_categs','var')
       n_categs = max(categ_scores); 
    end
    if ~exist('n_iter','var')
       n_iter = 1e5; 
    end
    if ~exist('title_name','var')
       title_name = ''; 
    end
    random_categ_scores = randi(n_categs,n_iter,size(categ_scores,2));
%     ratings = sum(n_categs-abs(bsxfun(@minus,random_categ_scores,categ_scores)),2)/size(categ_scores,2); hold on;
    ratings = zeros(n_iter,1);
    parfor i=1:n_iter
        ratings(i) = Metric1(random_categ_scores(i,:),categ_scores,n_categs);
    end
    hold on;
    hist = histogram(ratings); legend_add = '';
    ps = zeros(1,size(comparison_values,2));
    legend_add = cell(1,size(comparison_values,2)+1);
    legend_add{1} = 'Random ratings';
    for i=1:size(comparison_values,2)
        ps(i) = size(ratings(ratings>=comparison_values(i)),1)/size(ratings,1);
        plot([comparison_values(i) comparison_values(i)],[0 max(hist.Values)*1.2]);
        legend_add{i+1} = [comparison_names{i} ' ' num2str(comparison_values(i)) ' (p(>=) = ' num2str(ps(i)) ')'];
    end    
    p = ps(1);
    legend(legend_add,'Location','best');
    hold off;
    mu = mean(ratings);
    sigma = std(ratings);
    title_name = [title_name ' mu:' num2str(mu) ' sigma:' num2str(sigma)];
    title(title_name);
end

