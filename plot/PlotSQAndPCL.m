function PlotSQAndPCL( pcl,SQ)
figure;
hold on
grid off
axis equal

xlabel('x') % x-axis label
ylabel('y') % y-axis label
zlabel('z') % z-axis label

[SQ_mtx,~] = getSQPlotMatrix(SQ,4000,15);
plot3(SQ_mtx(:,1),SQ_mtx(:,2),SQ_mtx(:,3),'.b');

scatter3(pcl(:,1),pcl(:,2),pcl(:,3),10,'.g');
end

