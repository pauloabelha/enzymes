function F = SQToroidFunctionWoutNormalizingParams( lambda, XYZ )   
    lambda = GetToroid( [lambda(1:3) lambda(5:end)], lambda(4) );
    T = [[eul2rotm_(lambda(7:9),'ZYZ') lambda(end-2:end)']; [0 0 0 1]];
    XYZ = [XYZ ones(size(XYZ,1),1)];
    XYZ = XYZ*T;
    XYZ = XYZ(:,1:3);
    
    X_part = signedpow(XYZ(:,1)/lambda(1),2/lambda(6));
    Y_part = signedpow(XYZ(:,2)/lambda(2),2/lambda(6));
    Z_part = signedpow(XYZ(:,3)/lambda(3),2/lambda(5));
    
    F = signedpow(signedpow(X_part+Y_part,lambda(6)/2)-lambda(4),2/lambda(5))+signedpow(Z_part,2/lambda(5));   
    F=abs(F);
    F = signedpow(F,lambda(5));
end