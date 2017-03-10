%outputs a rot mtx for rotation of theta along an arbitrary axis
%http://paulbourke.net/geometry/rotate/
function [ R ] = RotMtxArbitraryAxis( theta, axis )
    MIN_LENGTH = eps;
    norm_U = norm(axis);
    if norm_U < MIN_LENGTH
        error(['Axis length (norm) is less than ' num2str(MIN_LENGTH)]);
    end
    U = axis/norm_U;
    a = U(1);
    b = U(2);
    c = U(3);
    d = sqrt(b^2+c^2);
    
    Rx = eye(3);
    if d ~= 0        
        Rx(2,2) = c/d;
        Rx(2,3) = -b/d;
        Rx(3,2) = b/d;
        Rx(3,3) = c/d;        
    end

    Rx_inv = Rx;
    Rx_inv(2,3) = -Rx(2,3);
    Rx_inv(3,2) = -Rx(3,2);

    Ry = eye(3);
    Ry(1,1) = d;
    Ry(1,3) = -a;
    Ry(3,1) = a;
    Ry(3,3) = d;

    Ry_inv = Ry;
    Ry_inv(1,3) = -Ry(1,3);
    Ry_inv(3,1) = -Ry(3,1);

    Rz = GetRotMtx(theta,'z');

    R = Rx_inv*Ry_inv*Rz*Ry*Rx;
end

