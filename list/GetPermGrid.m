function [ X, Y ] = GetPermGrid( a, b )
    
    X = repmat([1:a]',b,1);
    Y = floor((a:a*b+(a-1))/a)';

end

