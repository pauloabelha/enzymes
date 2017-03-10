%calculate superellipsoid moment of inertia according to equtions in SUPERQUADRIC_BOOK (p. 36)
function [ I ] = MomentInertiaSQ( lambda )
    if lambda(5) < 0
        lambda(5) = 1;
    end
    I = zeros(3,3);
    a=lambda(1:3);
    epsilon=lambda(4:5);
    %calculate Ixx
    Ixx_fisrt_part = 0.5*a(1)*a(2)*a(3)*epsilon(1)*epsilon(2);
    Ixx_second_part = (a(2)^2)*beta((3*epsilon(1))/2,epsilon(2)/2)*beta(epsilon(1)/2,(2*epsilon(1)+1));
    Ixx_third_part = (4*(a(3)^2))*beta(epsilon(2)/2,(epsilon(2)/2)+1)*beta((3*epsilon(1))/2,epsilon(1)+1);
    I(1,1) = Ixx_fisrt_part*(Ixx_second_part+Ixx_third_part);
    %calculate Iyy
    Iyy_fisrt_part = 0.5*a(1)*a(2)*a(3)*epsilon(1)*epsilon(2);
    Iyy_second_part = (a(1)^2)*beta((3*epsilon(1))/2,epsilon(2)/2)*beta(epsilon(1)/2,(2*epsilon(1)+1));
    Iyy_third_part = (4*(a(3)^2))*beta(epsilon(2)/2,(epsilon(2)/2)+1)*beta((3*epsilon(1))/2,epsilon(1)+1);
    I(2,2) = Iyy_fisrt_part*(Iyy_second_part+Iyy_third_part);
    %calculate Izz
    I(3,3) = 0.5*a(1)*a(2)*a(3)*epsilon(1)*epsilon(2)*((a(1)^2)+(a(2)^2))*beta((3*epsilon(2))/2,epsilon(2)/2)*beta(epsilon(1)/2,(2*epsilon(1))+1);   
end

