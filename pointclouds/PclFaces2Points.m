function [ points ] = PclFaces2Points( vertices, faces )
    points = zeros(size(faces));
    for i=1:size(faces,1)
        centroid = [(vertices(faces(i,1),1) + vertices(faces(i,2),1) + vertices(faces(i,3),1))/3 (vertices(faces(i,1),2) + vertices(faces(i,2),2) + vertices(faces(i,3),2))/3 (vertices(faces(i,1),3) + vertices(faces(i,2),3) + vertices(faces(i,3),3))/3];
        points(i,:) = centroid;
    end
end

