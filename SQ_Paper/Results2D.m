%% clear all
close all;
clear;
%% test variables
N_TRIALS = 10;
a_1 = 1;
a_2 = 1;
EPS_BEG = 0.01;
EPS_STEP = 0.05;
EPS_END = 2;
N_EPS = size(EPS_BEG:EPS_STEP:EPS_END,2);
D_BEG = 0.001;
D_STEP = 0.001;
D_END = 0.1;
N_DS = size(D_BEG:D_STEP:D_END,2);
times = zeros(N_EPS,N_DS);
n_points = times;
i=0;
%% get average times
for eps=EPS_BEG:EPS_STEP:EPS_END
    i=i+1;
    j = 0;
    for D=D_BEG:D_STEP:D_END
        j=j+1;
        curr_times = zeros(1,N_TRIALS);
        for k=1:N_TRIALS
            tic;
            s = superellipse( a_1, a_2, eps, D );
            curr_times(k) = toc;            
        end
        times(i,j) = mean(curr_times);
        n_points(i,j) = size(s,1);
    end
end
%% replace first peak time
curr_times = zeros(1,N_TRIALS);
for i=1:2
    for k=1:N_TRIALS
        tic;
        superellipse( a_1, a_2, EPS_BEG, D_BEG );
        curr_times(k) = toc;            
    end
end
times(1,1) = mean(curr_times);
%% get time in ms
times = times.*1000;
%% plot variables
DS = D_BEG:D_STEP:D_END;
EPSS = EPS_BEG:EPS_STEP:EPS_END;
FONT_SIZE = 20;
D_AXIS_LABEL = ['D=' num2str(D_BEG) ':' num2str(D_STEP) ':' num2str(D_END)];
EPS_AXIS_LABEL = ['\epsilon=' num2str(EPS_BEG) ':' num2str(EPS_STEP) ':' num2str(EPS_END)];
TIME_TARGET_AXIS_LABEL = 'Sampling time t (ms)';
NPTS_TARGET_AXIS_LABEL = 'Number of sampled points';
MAX_TIME_TARGET_AXIS = max(times(:))+0.05;
MAX_NPTS_TARGET_AXIS = max(n_points(:))+10;
%% plot sampling time surface
PlotResSurf( [D_BEG D_END EPS_BEG EPS_END 0 MAX_TIME_TARGET_AXIS ], {D_AXIS_LABEL, EPS_AXIS_LABEL, TIME_TARGET_AXIS_LABEL}, DS, EPSS, times, FONT_SIZE);
%% plot sampling time surface
PlotResSurf( [D_BEG D_END EPS_BEG EPS_END 0 MAX_NPTS_TARGET_AXIS ], {D_AXIS_LABEL, EPS_AXIS_LABEL, NPTS_TARGET_AXIS_LABEL}, DS, EPSS, n_points, FONT_SIZE);
%% plot epsilon cut
PlotResLine( [EPS_BEG EPS_END 0 MAX_TIME_TARGET_AXIS], {EPS_AXIS_LABEL, TIME_TARGET_AXIS_LABEL}, EPSS, times(:,1), FONT_SIZE );
%% plot D cut
PlotResLine( [D_BEG D_END 0 MAX_TIME_TARGET_AXIS], {D_AXIS_LABEL, TIME_TARGET_AXIS_LABEL}, DS, times(1,:), FONT_SIZE );


