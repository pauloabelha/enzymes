function [ pcl, P ] = superegg( color )
    if ~exist('color','var')
        color = '.k';
    end
    [pcl, normals] = superellipsoid( [1 1 1.2 0.8 0.8 0 0 0 0 0 0 0 0 0 0], 10^7, 1, color);
    P = PointCloud(pcl,normals);
    set(gcf,'color','w');
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    set(gca,'ztick',[]);
    set(gca,'xcolor','None');
    set(gca,'ycolor','None');
    set(gca,'zcolor','None');
    set(gca,'cameraposition',[1 2 1]);
    set(gca,'ambientlightcolor','none');
end

