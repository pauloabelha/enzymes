function [ P ] = PCLFaceNormals2PointNormals( P )
    max_n_faces_by_point = 10;
    points_tri_normals = zeros(size(P.v,1),max_n_faces_by_point,3);
    for i=1:size(P.f,1)
       j=1;
       while j <= max_n_faces_by_point && points_tri_normals(P.f(i,1),j,1) ~= 0 && points_tri_normals(P.f(i,1),j,2) ~= 0 && points_tri_normals(P.f(i,1),j,3) ~= 0
           j=j+1;
       end           
       points_tri_normals(P.f(i,1),j,:) = P.n(i,:); 
       j=1;
       while j <= max_n_faces_by_point && points_tri_normals(P.f(i,2),j,1) ~= 0 && points_tri_normals(P.f(i,2),j,2) ~= 0 && points_tri_normals(P.f(i,2),j,3) ~= 0
           j=j+1;
       end  
       points_tri_normals(P.f(i,2),j,:) = P.n(i,:); 
       j=1;
       while j <= max_n_faces_by_point && points_tri_normals(P.f(i,3),j,1) ~= 0 && points_tri_normals(P.f(i,3),j,2) ~= 0 && points_tri_normals(P.f(i,3),j,3) ~= 0
           j=j+1;
       end  
       points_tri_normals(P.f(i,3),j,:) = P.n(i,:); 
    end
    P.n = zeros(size(P.v));
    for i=1:size(points_tri_normals,1)
        j=1;
        sum_normal_vecs=zeros(1,3);
        while j <= max_n_faces_by_point && (points_tri_normals(i,j,1) ~= 0 && points_tri_normals(i,j,2) ~= 0 && points_tri_normals(i,j,3) ~= 0)
            normal = points_tri_normals(i,j,:);
            sum_normal_vecs(1,:) = sum_normal_vecs(1,:) + [normal(1,1,1) normal(1,1,2) normal(1,1,3)];
            j=j+1;            
        end 
        P.n(i,:) = sum_normal_vecs / (j-1);
    end
end

