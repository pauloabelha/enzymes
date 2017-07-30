close all;
%naive
figure;
naivesuperellipsoid( [1 1 1 0.1 0.1 0 0 0 0 0 0 0 0 0 0], 1, '.k' );
set(gcf,'color','w');
set(gca,'xtick',[]);
set(gca,'ytick',[]);
set(gca,'ztick',[]);
set(gca,'xcolor','None');
set(gca,'ycolor','None');
set(gca,'zcolor','None');
set(gca,'cameraposition',[1 2 1]);
%% uniform
figure;
superellipsoid( [1 1 1 0.1 0.1 0 0 0 0 0 0 0 0 0 0], 10^9, 1, '.k');
set(gcf,'color','w');
set(gca,'xtick',[]);
set(gca,'ytick',[]);
set(gca,'ztick',[]);
set(gca,'xcolor','None');
set(gca,'ycolor','None');
set(gca,'zcolor','None');
set(gca,'cameraposition',[1 2 1]);
set(gca,'ambientlightcolor','none');
