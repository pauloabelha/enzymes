function [ pcl,normals,faces ] = SQsToPCL( SQs,segms,use_SQs  )
    %get the pointcloud for every segm
    %if only the action part is being changed, then all other segms remain the same
    %also, get the faces using Delaunay Triangulation (for PLY, triangles are 0-indexed)ix_segm
    n_segms = min(size(SQs,2),size(segms,2));    
    for i=1:n_segms
        if use_SQs
            [new_segms{i}, new_normals{i}] = UniformSQSampling3D( SQs{i}, 0, 2000 );
        else
            [new_segms{i}, ixs] = DownsamplePCL(segms{i}.v,2000);
            if ~isempty(segms{i}.n)
                new_normals{i} = segms{i}.n(ixs,:);
            else
                new_normals{i} = segms{i}.n;
            end
        end    
        %new_segms{i} = DownsamplePCL(new_segms{i},2000);
        new_faces{i} = delaunay(new_segms{i}(:,1),new_segms{i}(:,2),new_segms{i}(:,3));
        new_faces{i} = new_faces{i};
    end
    
    %put segms and faces in one single structure
    pcl = [new_segms{1}];
    normals = [new_normals{1}];
    faces = [new_faces{1}];
    for i=2:n_segms
        size_previous_pcl = size(pcl,1);
        pcl = [pcl; new_segms{i}]; 
        normals = [normals; new_normals{i}];
        %manipulate triangle indexes so that they all point correctly to each respective set of points            
        faces = [faces; new_faces{i}+size_previous_pcl];    
    end
    faces = faces -1;
end

