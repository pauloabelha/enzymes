%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
% based on MacKay's bible
%
%% Probability mass of an array of experimental results
%   builds a histogram and then normalises the data to a prob mass array
%
% Inputs:
%   P - 1 * N vector with experimental results
%   log_base - desired log base (e.g. 2 for getting the answer in "bits")
%       default is base 2
% Outputs:
%   entropy - Average Shanon information content (in the chosen log base)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ P_mass, P_bins, mean_prob, max_prob_bin, max_prob ] = GetProbDistExpResults( P, BIN_RES, BIN_RANGE, MAX_MEM, plot_fig )
    CheckNumericArraySize(P,[1 Inf]);    
    %% check wether to plot
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end 
    %% max memory to be used (in GB) in order to choose bin resolution
    if ~exist('MAX_MEM','var') || MAX_MEM < 0
        MAX_MEM = .001; 
    else        
        CheckIsScalar(MAX_MEM);
    end  
    % MATLAB's float is 32 bit and we need to store two big vectors
    MAX_N_ELEMS = MAX_MEM*8e9/(32*2);
    %% bin resolution
    if exist('BIN_RES','var')
        CheckIsScalar(BIN_RES);
    else    
        BIN_RES = size(P,1)/MAX_N_ELEMS;    
    end
    %% bin range
    if ~exist('BIN_RANGE','var') || (numel(BIN_RANGE) == 1 && BIN_RANGE < 0)
        BIN_RANGE = [min(P) max(P)];  
    else            
        CheckNumericArraySize(BIN_RANGE,[1 2]);
    end   
    %% get mean
    mean_prob = mean(P);
    [P_hist, P_bins] = HistogramCustom( P, BIN_RES, BIN_RANGE );
    P_mass = P_hist/sum(P_hist(P_hist>0));
    %% get max probability bin
    [max_prob, max_prob_ix] = max(P_mass);
    max_prob_bin = P_bins(max_prob_ix);
    %% plot
    if plot_fig
        plot(P_bins,P_mass);
    end
end

