function [ R ] = DeltaTheta( D_theta, a1, a2, epsilon, theta )
    numerator = (cos(theta)^2).*(sin(theta)^2);
    denominator = ((a1^2)*(signedpow(cos(theta),epsilon).^2).*(sin(theta).^4))+((a2^2).*(signedpow(sin(theta),epsilon).^2).*(cos(theta).^4));
    R = (D_theta/epsilon).*sqrt(numerator./denominator);
end

