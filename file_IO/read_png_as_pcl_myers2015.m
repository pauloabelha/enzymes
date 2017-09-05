function [ P, P_raw, centre, rgbd ] = read_png_as_pcl_myers2015( filepath, slash )
    rgbd = double(imread(filepath));
    if ~exist('slash','var')
        slash = '/';
    end
    a=strfind(filepath,slash);
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
    P = Apply3DTransfPCL(P,{GetRotMtx(pi/1.4,'y')});
    P.v = P.v(P.v(:,3)>=-625,:);
    P.segms{1}.v = P.segms{1}.v(P.segms{1}.v(:,3)>=-625,:);
    P = Apply3DTransfPCL(P,{inv(GetRotMtx(pi/1.4,'y'))});    
    P.v = P.v/1000;
    P.segms{1}.v = P.segms{1}.v/1000;
    centre = GetRotMtx(pi/1.4,'y')*[240.50 320.50 717.80]';
    centre = centre/1000;
end