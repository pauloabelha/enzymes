function [ metric1 ] = Metric1( scores, groundtruth, n_categs )
    if ~exist('n_categs','var')
        n_categs = numel(unique(groundtruth));
    end
    if n_categs < 2
        error('Number of categories should be greater than 1');
    end
    CheckNumericArraySize(scores,[1 Inf]);
    CheckNumericArraySize(groundtruth,[1 Inf]);
    penalty_power = 2;
    diff = abs(scores - groundtruth).^penalty_power;
    metric1 = mean(((n_categs-1)^2 - diff)/(n_categs-1)^2);
    if metric1 < 0 || metric1 > 1
        error('Calculated metric1 is either smaller than 0 or greater than 1');
    end
end

