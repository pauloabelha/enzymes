function [ normals ] = Get_Normals(pcl)
%Estimates the normals using the function from the visual toolbox.
%Orients the estimated normals using the angle between the normal and
%the vector going from the centre point to the surface point.
pclObj = pointCloud(pcl);
normals = pcnormals(pclObj);
sensorCenter = [0,0,0];
%http://uk.mathworks.com/help/vision/ref/pcnormals.html?refresh=true
for k = 1 : size(normals,1)
   p1 = sensorCenter - [pcl(k,1),pcl(k,2),pcl(k,3)];
   p2 = [normals(k,1),normals(k,2),normals(k,3)];
   %take the angle between the normal vector and the vector connecting the centre
   %with the surface point. If the angle is between 0 and 90 change sign (make it point outwards)
   angle = atan2(norm(cross(p1,p2)),p1*p2');
   if angle < pi/2 && angle > -pi/2
       normals(k,1) = -normals(k,1);
       normals(k,2) = -normals(k,2);
       normals(k,3) = -normals(k,3);
   end
end
end

