function F = SQToroidFunction( lambda, XYZ )        
    lambda = GetToroid( [lambda(1:3) lambda(5:end)], lambda(4) );
    T = [[eul2rotm_(lambda(7:9),'ZYZ') lambda(end-2:end)']; [0 0 0 1]];
    XYZ = [XYZ ones(size(XYZ,1),1)];
    XYZ = XYZ*T;
    XYZ = XYZ(:,1:3);
    
    X = XYZ(:,1)/lambda(1);
    Y = XYZ(:,2)/lambda(2);
    Z = XYZ(:,3)/lambda(3);
    
    %F = signedpow(signedpow(X_part+Y_part,lambda(6)/2)-lambda(4),2/lambda(5))+signedpow(Z_part,2/lambda(5));   
    F = abs((abs((abs(X.^(2/lambda(6)))+abs(Y.^(2/lambda(6)))).^(lambda(6)/2))-lambda(4)).^(2/lambda(5)))+abs(Z.^(2/lambda(5)));
    F = sqrt(lambda(1)*lambda(2)*lambda(3))*(F.^lambda(5) - 1);
end