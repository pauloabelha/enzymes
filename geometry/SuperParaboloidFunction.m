function [ F, F_raw ] = SuperParaboloidFunction( lambda, pcl )
    a1 = lambda(1);
    a2 = lambda(2);
    a3 = lambda(3);   
    eps1 = lambda(4);
    eps2 = lambda(5);
    rot = eul2rotm_(lambda(6:8),'ZYZ');
    pos = lambda(end-2:end)';    
    T_inv = inv([[rot; 0 0 0] [pos; 1]]);
    pcl = T_inv*[pcl ones(size(pcl,1),1)]';
    pcl = pcl(1:3,:)';
    X = (pcl(:,1)/a1).^2;
    Y = (pcl(:,2)/a2).^2;
    Z = pcl(:,3)/(2*a3);
    F_raw = ( (X.^eps2 + Y.^eps2).^(eps2/eps1) ) - Z;
    F = abs(F_raw);
end

