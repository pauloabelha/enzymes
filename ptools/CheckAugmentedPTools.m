function [ KL_divs_over_data, KL_divs ] = CheckAugmentedPTools( pTool_vecs, sampled_pTools, plot_fig )    

    if ~exist('plot_fig','var')
        plot_fig = 0;
    end

    log_base = 2;
    
    n_tries = 1e1;
    max_sampling = size(sampled_pTools,1);
    n_dims = size(pTool_vecs,2);
    Hs_data = zeros(n_tries,n_dims);
    Hs_sample = zeros(n_tries,n_dims);
    KL_divs = zeros(n_tries,n_dims);
    KL_divs_over_data = zeros(n_tries,n_dims);
    tot_toc = 0;
    for i=1:n_tries 
        tic;
        for j=1:n_dims
            Hs_data(i,j) = EntropyExpResults( pTool_vecs(:,j)', log_base );
            sample_ixs = logical(randi(2,1,round(i*max_sampling/n_tries))-1);
            Hs_sample(i,j) = EntropyExpResults( sampled_pTools(sample_ixs,j)', log_base );            
            KL_divs(i,j) = KLDivergenceExpResults(sampled_pTools(sample_ixs,j)',pTool_vecs(:,j)', log_base);
            KL_divs_over_data(i,j) = KL_divs(i,j)./Hs_data(i,j);            
        end;
        tot_toc = DisplayEstimatedTimeOfLoop( tot_toc+toc, i, n_tries );
    end
    
    if plot_fig
    figure;
        for j=1:n_dims
            if j~=6 && j~=7 && j~=13 && j~=14
                plot(KL_divs_over_data(:,j));
                hold on;
            end;
        end;
        hold off;
    end
end

