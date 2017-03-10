function [ angle ] = AngleBetweenVectors( v1,v2, v1_sign_ix )
    norm_XI = sqrt(sum(v1.^2));
    norm_XJ = sqrt(sum(v2.^2));  
    A = norm_XJ*v1 - norm_XI*v2;
    B = norm_XJ*v1 + norm_XI*v2;
    norm_1 = sqrt(sum(A.^2));
    norm_2 = sqrt(sum(B.^2));
    angle = 2 * atan(norm_1 ./ norm_2);
    
    if nargin > 2
        sign_v1 = sign(v1(v1_sign_ix));
        if sign_v1 == 0
            sign_v1 = 1;
        end   
        angle = -sign_v1*angle;
    end    
end

