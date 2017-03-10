% get paraboloid faces by running convex hull and then eliminating 
% closing ("lid"/"top") faces
function [ pcl, faces ] = ParaboloidFaces( lambda )
    %% get paraboloid pcl in "canonical" positions (upwards - no rotation)
    pcl = Paraboloid2PCL(lambda);
    r = vrrotvec(GetSQVector(lambda),[0;0;1]);
    rot_pcl = vrrotvec2mat(r);
    pcl = pcl*rot_pcl';
    %% get faces from convhull
    all_faces = convhull(pcl);
    %% check if it is a "blade" SQ/Parboloid
    MIN_PROP_SCALE_FOR_3D = 0.05;
    [sorted_scale,sorted_scale_ixs] = sort(lambda(1:3));
    if sorted_scale(1)/sorted_scale(2) < MIN_PROP_SCALE_FOR_3D || sorted_scale(1)/sorted_scale(3) < MIN_PROP_SCALE_FOR_3D        
        ixs_rmv = logical(zeros(1,size(all_faces,1)));
    else
        ixs_rmv = pcl(:,3) >= (max(pcl(:,3)) - 0.001);
    end
    pts = 1:size(pcl,1);
    pts_rmv = pts(ixs_rmv);
    
    faces = [];
    for i=1:size(all_faces,1)
        rmv_face = 1;
        for j=1:3
            if ~ismember(all_faces(i,j),pts_rmv)
                rmv_face = 0;
                break;
            end
        end
        if ~rmv_face
            faces(end+1,:) = all_faces(i,:);
        else
            a=0;
        end
    end
    pcl = pcl*inv(rot_pcl');
end

