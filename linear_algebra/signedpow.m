function [ v ] = signedpow( x, p )
    v = sign(x).*(abs(x).^p);
end

