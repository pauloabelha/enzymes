function [ P ] = CGALIxs2PCL( pcl_name )
    P = ReadPointCloud(['~/CGAL/segmentation/data/' pcl_name '.ply']);
    face_segm_ixs = dlmread(['~/CGAL/segmentation/data/' pcl_name '.txt'],' ');
    face_segm_ixs = face_segm_ixs(1:end-1);
    if ischar(P)
        P = ReadPointCloud(P);
    end
    segm_ixs_set = unique(face_segm_ixs);
    votes_per_pt = zeros(size(P.v,1),size(segm_ixs_set,2));
    face_0_indexed = 0;
    if min(min(P.f)) < 1
        P.f = P.f + 1;
        face_0_indexed = 1;
    end
    for i=1:size(face_segm_ixs,2)
        for j=1:3
            votes_per_pt(P.f(i,j),face_segm_ixs(i)+1) = votes_per_pt(P.f(i,j),face_segm_ixs(i)+1) + 1;
        end
    end
    [~,P.u] = max(votes_per_pt,[],2);
    segms = cell(1,size(segm_ixs_set,2));
    for i=1:numel(segms)
        segms{i}.v = [];
    end
    P.c = zeros(size(P.u,1),3);    
    for pt=1:size(P.u,1)
        segms{P.u(pt)}.v(end+1,:) = P.v(pt,:);
    end
    P.segms = segms;
    P = AddColourToSegms( P );    
    for i=1:numel(segms)
        if size(segms{i}.v,1)/size(P.v,1) < 0.05
            P = FuseSegmIntoOthers(P,i,1);
            break;
        end
    end      
    if face_0_indexed
        P.f = P.f - 1;
    end
    WritePly(P, ['~/CGAL/segmentation/data/' pcl_name '_out.ply'])
end

