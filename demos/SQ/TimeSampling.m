function [ se_res, sp_res ] = TimeSampling( D, eps1_D_loop )
    if ~exist('D','var')
        D = 0.05;
    end
    if ~exist('eps1_D_loop','var')
        eps1_D_loop = .2;
    end
    %% loop vars
    D_start = 0.001;
    D_step = 0.001;
    D_end = 0.01;
    eps1_start = .1;
    eps1_step = .01;
    eps1_end = 2;
    tot_avg_loops = 100;
    N_eps = floor((eps1_end-eps1_start)/eps1_step) + 1;
    %% function of eps1
    avg_times1 = zeros(1,N_eps);
    avg_times2 = avg_times1;
    ix = 0;
    for eps1=eps1_start:eps1_step:eps1_end
        ix = ix + 1;
        avg_time1 = zeros(1,tot_avg_loops);
        avg_time2 = avg_time1;
        for j=1:tot_avg_loops
            tic;
            superellipse( 1, 1, eps1, D );
            avg_time1(j) = toc;
            tic;
            superparabola( 1, 1, eps1, D );
            avg_time2(j) = toc;
        end
        avg_times1(ix) = median(avg_time1);     
        avg_times2(ix) = median(avg_time2); 
    end
    se_res.eps_avg_times = avg_times1;
    sp_res.eps_avg_times = avg_times2;
    %% function of D
    N_D = floor((D_end-D_start)/D_step) + 1;
    avg_times1 = zeros(1,N_D);
    avg_times2 = avg_times1;
    ix = 0;
    for D=D_start:D_step:D_end
        ix = ix + 1;
        avg_time1 = zeros(1,tot_avg_loops);
        avg_time2 = avg_time1;
        for j=1:tot_avg_loops
            tic;
            superellipse( 1, 1, eps1_D_loop, D );
            avg_time1(j) = toc;
            tic;
            superparabola( 1, 1, eps1_D_loop, D );
            avg_time2(j) = toc;
        end
        avg_times1(ix) = median(avg_time1);     
        avg_times2(ix) = median(avg_time2); 
    end
    se_res.D_avg_times = avg_times1*1e3;
    plot(se_res.D_avg_times);
    xlabel({'D','(approximate arclength)'});
    ylabel({'t','(ms)'});
    sp_res.D_avg_times = avg_times2;
    
end

