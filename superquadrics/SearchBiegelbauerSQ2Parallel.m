function [seed_pcls,lambda_o_initial,lambda_o_final,lambda_lowers,lambda_uppers,final_rank_values,seed_points] ...
                = SearchBiegelbauerSQ2Parallel(pcl,seed_points,lambda_f,lambda_default,lambda_lower_def,lambda_upper_def,tapering,bending,sorting_mode,gamma1,gamma2,display_mode)           
    %calculate seed points distribution based on part type    
    n_seeds=size(seed_points,1);    
    %initialize variables for calculatingneighborhood pcls
    seed_radius_factor = 1.2;
    min_n_surrouding_seed_points = 10;    
    %initialize lambdas        
    [lambda_o,lambda_lower,lambda_upper] = get_lambda_o_from_f_and_default(lambda_f,lambda_default,lambda_lower_def,lambda_upper_def); 
%     lambda_o(length(lambda_o)+1:length(lambda_o)+3) = zeros(3,1);
%     lambda_lower(length(lambda_lower)+1:length(lambda_lower)+3) = zeros(3,1);
%     lambda_upper(length(lambda_upper)+1:length(lambda_upper)+3) = zeros(3,1);   
%     lambda_lowers = zeros(n_seeds,length(lambda_lower)); 
%     lambda_uppers = zeros(n_seeds,length(lambda_upper)); 
%     lambda_o_initial = zeros(n_seeds,length(lambda_default)+3);
%     lambda_o_final = zeros(n_seeds,length(lambda_default)+3);
    
    %create accumulator of seed_pcls
    seed_pcls = cell(n_seeds,2);    
    %calculate rank voting and fit SQ for n seed points
    if strcmp(display_mode,'verbose')
        disp('Searching (Biegelbauer) for part:');
    end
    
    parfor i=1:n_seeds
        %get a random seed point from the point cloud
        seed_point = seed_points(i,:);
        %define default_lambda position as a random seed point from the point cloud
        %lambda_default(13:15) = seed_point;
        %construct seed point cloud
        scale_params = getScaleParamsLambdas(lambda_f,lambda_default);
        seed_radius = seed_radius_factor*max(scale_params);
        seed_pcl = pcl;%getPCLAroundAPoint(pcl,seed_point,seed_radius,min_n_surrouding_seed_points);
        %accumulate seed_pcls
        seed_pcls{i} = seed_pcl;
        %accumulate boundary lambdas to return
        lambda_lowers(i,:) = lambda_lower;
        lambda_uppers(i,:) = lambda_upper;
        %accumulate initial lambda   
        lambda_o_initial(i,:) = get_lambda_from_fixed_and_open2(lambda_f,lambda_o,seed_point);
        %fit SQ
        [lambda_o_res,~,~,~,~] = SolverRecoverySQ(seed_pcl,seed_point,lambda_lower(end-2:end),lambda_upper(end-2:end),lambda_f,lambda_o,lambda_lower,lambda_upper,0,0);
        if tapering
            for ix_tapering=1:size(lambda_f,2)
               if  lambda_f(1,ix_tapering) == 9
                   break;
               end
            end
            ix_tapering=3;
            lambda_f_ = zeros(2,size(lambda_f,2)-2);
            lambda_f_(:,1:ix_tapering-1) = lambda_f(:,1:ix_tapering-1);
            lambda_f_(:,ix_tapering:end) = lambda_f(:,ix_tapering+2:end);
            lambda_o_ = zeros(1,size(lambda_o,2)+2);
            lambda_o_(1:size(lambda_o,2)) = lambda_o;
            lambda_lower_ = zeros(1,size(lambda_lower,2)+2);
            lambda_lower_(1:size(lambda_lower,2)) = lambda_lower;
            lambda_upper_ = zeros(1,size(lambda_upper,2)+2);
            lambda_upper_(1:size(lambda_upper,2)) = lambda_upper;
            [lambda_o_res,~,~,~,~] = SolverRecoverySQ(seed_pcl,lambda_o_res(end-2:end),lambda_lower(end-2:end),lambda_upper(end-2:end),lambda_f_,lambda_o_,lambda_lower_,lambda_upper_,0,0);
        end
        %get ranking values        
%         lambda_o_final(i,:) = get_lambda_from_fixed_and_open(lambda_f,lambda_o_res);
%         ranks(i) = SortRanks(sorting_mode,pcl, lambda_o_final(i,:), gamma);
        %get ranking values
        lambda_res = get_lambda_from_fixed_and_open(lambda_f,lambda_o_res,15);
        [ M_vec(i), I_vec(i), S_vec(i), Sc_vec(i), lambda_o_final(i,:), ~ ] ...
                    = RankSQ(pcl, lambda_res, gamma1, gamma2 );
        if strcmp(display_mode,'verbose')
            progress_bar = '';
            n_vert_bars = round((i/n_seeds)*100);
            for k=1:n_vert_bars
                progress_bar = strcat(progress_bar,'%');            
            end
            for k=n_vert_bars+1:100
                progress_bar = strcat(progress_bar,'.');            
            end
            disp(strcat(progress_bar,strcat(num2str(round((i/n_seeds)*100)),'%')));
        end
    end
    [ final_rank_values, lambda_o_initial,lambda_o_final,lambda_lowers,lambda_uppers ] ...
                        = SortRanksSQ( M_vec, I_vec, S_vec, Sc_vec, lambda_o_initial,lambda_o_final,lambda_lowers,lambda_uppers );
%     [ final_rank_values, lambda_o_initial,lambda_o_final,lambda_lowers,lambda_uppers ] ...
%         = SortRanksSQ2( ranks, lambda_o_initial,lambda_o_final,lambda_lowers,lambda_uppers );
end