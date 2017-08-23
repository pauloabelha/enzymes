function [ vol_mult, lambda ] = GetVolMult( lambda )
    % deal with SQs with a scale number less than 1
    % this is too deal with arbitrarly small SQs and 
    % still being able to sample
    vol_mult = 1;
    if any(lambda(1:3) < 1)
        vol_mult = 1/min(lambda(1:3));
        lambda(1:3) = lambda(1:3)*vol_mult;
        %lambda(11) = lambda(11)*vol_mult;
    end
end

