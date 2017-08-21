function [ rand_sign ] = randsign( )
    rand_sign = -1 + 2*(rand > 0.5);
end

