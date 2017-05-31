function [ output_args ] = naiveVsUnifSampling( eps1, eps2 )
    if ~exist('eps1','var')
        eps1 = .1;
    end
    if ~exist('eps2','var')
        eps2 = .1;
    end
    pcl_naive = naivesuperellipsoid([1 1 1 eps1 eps2 0 0 0 0 0 0 0 0 0 0]);
    pcl_unif = superellipsoid([1 1 1 eps1 eps2 0 0 0 0 0 0 0 0 0 0]);
    
    figure;
    set(gcf,'color','w');;
    ax1 = subplot(1,2,1);
    scatter3(pcl_naive(:,1),pcl_naive(:,2),pcl_naive(:,3),1,'.k');
    axis equal;
    title(ax1,'Naive');
    
    ax1 = subplot(1,2,2);
    scatter3(pcl_unif(:,1),pcl_unif(:,2),pcl_unif(:,3),1,'.k');
    axis equal;
    title(ax1,'Uniform');
end

