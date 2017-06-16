% return the values for a Gaussian-noisy linear function
function [ Y, noise, w ] = LinearPlusNoise( X, w )
    %% sanity checks
    if ~exist('X','var')
        disp('Please provide an array of data points');
    end
    CheckNumericArraySize(X,[Inf Inf]);
    if ~exist('w','var')
        w = [ones(size(X,2),1); 0];
    end
    CheckNumericArraySize(w,[size(X,2)+1 1]);
    %% noisy linear function
    noise = normrnd(0,mean(X)/10,size(X,1),1);
    Y = [X ones(size(X,1),1)]*w + noise;
end

