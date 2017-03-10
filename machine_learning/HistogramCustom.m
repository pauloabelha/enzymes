%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
%
%% Builds a histogram with a custom bin range
% Inputs:
%   values - N * 1 vector with values
%   bin_res - a number with the bin resolution
%   *optional* bin_range - the bin (open-closed) interval to consider
% Outputs:
%   hist_custom - 1 * M vector with the count in each bin
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ count_bins, bins ] = HistogramCustom( values, bin_res, bin_range )
    %% sanity check on dimensions
    if ~exist('values','var') || ~exist('bin_res','var')
        error('This function needs two parameters: values and bin_res');
    end
    CheckNumericArraySize(values,[1 Inf]);
    CheckScalarInRange( bin_res, 'open-open', [0 Inf] );
    if ~exist('bin_range','var')
        bin_range(1) = min(values)-bin_res;
        bin_range(2) = max(values);
    else
        CheckNumericArraySize(bin_range,[1 2]);
        if bin_range(2) <= bin_range(1)
            error('Third param ''bin_range'' second value must be greater than the first');
        end
    end
    %% get min and max values form the bin range
    min_value = bin_range(1);
    max_value = bin_range(2);
    if max(values) <= min_value
        error('The max value in vector must be greater than the min value');
    end
    %% initialize counting variables
    n_bins = ceil((max_value-min_value)/bin_res);
    count_bins = zeros(1,n_bins);
    sorted_values = sort(values);
    curr_value_ix = 1;
    curr_max = min_value + bin_res;
    size_sorted_values = size(sorted_values,2);
    bins = zeros(1,n_bins);
    %% count elems per bin
    for i=1:n_bins
        bins(i) = min_value + (i-1)*bin_res;
        n_values_in_bin = 0;    
        while curr_value_ix <= size_sorted_values && sorted_values(curr_value_ix) <= curr_max
            n_values_in_bin = n_values_in_bin + 1;
            curr_value_ix = curr_value_ix + 1;
        end    
        curr_max = curr_max + bin_res;        
        count_bins(i) = n_values_in_bin;        
    end
    %% check counting
    if ~exist('bin_range','var') && sum(count_bins) ~= size(values,2)
        error('Total number of counted elements is different than total numebr of elements. Something bad ocurred :(');
    end
end
