%% clear all
close all;
clear;
%% test variables
N_TRIALS = 10;
a_1 = 1;
a_2 = 1;
a_3 = 1;
EPS_BEG = 0.1;
EPS_STEP = 0.1;
EPS_END = 2;
N_EPS = size(EPS_BEG:EPS_STEP:EPS_END,2);
D_BEG = 0.01;
D_STEP = 0.01;
D_END = 0.1;
N_DS = size(D_BEG:D_STEP:D_END,2);
times = zeros(N_EPS,N_DS);
n_points = times;
i=0;
%% get average times
for eps=EPS_BEG:EPS_STEP:EPS_END
    for eps2=EPS_BEG:EPS_STEP:EPS_END
        i=i+1;
        j = 0;
        for D=D_BEG:D_STEP:D_END
            j=j+1;
            curr_times = zeros(1,N_TRIALS);
            for k=1:N_TRIALS
                tic;
                s = superellipsoid( [a_1, a_2, a_3, eps, eps2 0 0 0 0 0 0 0 0 0 0], 1e6, 0, '.k', D );
                curr_times(k) = toc;            
            end
            times(i,j) = mean(curr_times);
            n_points(i,j) = size(s,1);
        end
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
figure;
[mgx, mgy] = meshgrid(DS,EPSS);
axes = gca;
axes.XLim = [D_BEG D_END];
res_surface = surf(mgx,mgy,times);
xlhand = get(gca,'xlabel');
set(xlhand,'string',D_AXIS_LABEL,'fontsize',FONT_SIZE);
ylhand = get(gca,'ylabel');
set(ylhand,'string',EPS_AXIS_LABEL,'fontsize',FONT_SIZE); 
axes.YLim = [EPS_BEG EPS_END];
zlhand = get(gca,'zlabel');
set(zlhand,'string',TIME_TARGET_AXIS_LABEL,'fontsize',FONT_SIZE); 
res_surface.EdgeColor = 'none';
axes.ZLim = [0 MAX_TIME_TARGET_AXIS];
%% plot sampling time surface
figure;
axes = gca;
axes.XLim = [D_BEG D_END];
res_surface = surf(mgx,mgy,n_points);
xlhand = get(gca,'xlabel');
set(xlhand,'string',D_AXIS_LABEL,'fontsize',FONT_SIZE);
ylhand = get(gca,'ylabel');
set(ylhand,'string',EPS_AXIS_LABEL,'fontsize',FONT_SIZE); 
axes.YLim = [EPS_BEG EPS_END];
zlhand = get(gca,'zlabel');
set(zlhand,'string',NPTS_TARGET_AXIS_LABEL,'fontsize',FONT_SIZE); 
res_surface.EdgeColor = 'none';
axes.ZLim = [0 MAX_NPTS_TARGET_AXIS];
%% plot epsilon cut
figure;
axes = gca;
plot(EPSS,times(:,1));
axes.XLim = [EPS_BEG EPS_END];
xlhand = get(gca,'xlabel');
set(xlhand,'string',EPS_AXIS_LABEL,'fontsize',FONT_SIZE);
axes.YLim = [0 MAX_TIME_TARGET_AXIS];
ylhand = get(gca,'ylabel');
set(ylhand,'string',TIME_TARGET_AXIS_LABEL,'fontsize',FONT_SIZE); 
%% plot D cut
figure;
axes = gca;
plot(DS,times(1,:));
axes.XLim = [D_BEG D_END];
xlhand = get(gca,'xlabel');
set(xlhand,'string',D_AXIS_LABEL,'fontsize',FONT_SIZE) ;
axes.YLim = [0 MAX_TIME_TARGET_AXIS];
ylhand = get(gca,'ylabel');
set(ylhand,'string',TIME_TARGET_AXIS_LABEL,'fontsize',FONT_SIZE); 

