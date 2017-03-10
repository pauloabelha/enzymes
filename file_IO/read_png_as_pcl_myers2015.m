function [ P, P_raw ] = read_png_as_pcl_myers2015( filepath )
    rgbd = double(imread(filepath));
    
    a=strfind(filepath,'/');
    img_filename = filepath(a(end)+1:end);
    tool_name= img_filename(1:end-10);
    label_path = [filepath(1:a(end)) tool_name '_label.mat'];
    load(label_path);    
    [ X, Y ] = GetPermGrid( size(rgbd,1), size(rgbd,2) );
    P_raw = PointCloud([X Y rgbd(:)] );
    new_rgbd = [];
    XYZ = [];
    new_labels = [];
    for i=1:size(rgbd,1)
        for j=1:size(rgbd,2)
            if gt_label(i,j) >=1e-3 && rgbd(i,j) >= 1e-3
%                 new_rgbd(i,j) = rgbd(i,j);
                XYZ = [XYZ; i j rgbd(i,j)];
                new_labels = [new_labels; gt_label(i,j)];
            end
        end
    end    
%     rgbd = new_rgbd;
%     [ X, Y ] = GetPermGrid( size(rgbd,1), size(rgbd,2) );
%     P = PointCloud([X Y rgbd(:)] );
%     P = PointCloud(P.v(P.v(:,3)>=1,:));
    P = PointCloud(XYZ);
    P.v = P.v/1000;
end