%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
% based on https://en.wikipedia.org/wiki/Kullback%E2%80%93Leibler_divergence
%
%% Kullback–Leibler divergence
%   Get the KL Divergence between two vectors of experimental results
%   First, construct a histogram of each vector and then calculate the KL
%   divergence by normalising the histograms to discrete prob dists
% Inputs:
%   P - 1 * N array with experimental results
%   Q - 1 * M array with experimental results
%       N and M must be greater than 1
%   log_base - desired log base (e.g. 2 for getting the answer in "bits")
% Outputs:
%   KL_div - K-L Divergence
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ KL_div ] = KLDivergenceExpResults( P, Q, log_base )
    %% sanity checks for P and Q dimensions
    if ~exist('P','var') || ~exist('Q','var')
        error('The function needs two inputs: P and Q (both N x 1 arrays)');
    end
    CheckNumericArraySize(P,[1 Inf]);
    CheckNumericArraySize(Q,[1 Inf]);
    %% max memory to be used (in GB) in order to choose bin resolution
    MAX_MEM = .001;    
    %% epsilon constant for real number equality (used to check if prob dists sum to 1)
    %% get bin resolution according to MAX_MEM
    % MATLAB's float is 32 bit and we need to store two big vectors
    MAX_N_ELEMS = MAX_MEM*8e9/(32*2);
    BIN_RES = size(P,1)/MAX_N_ELEMS;
    new_eps = 1e-10;
    %% calculate P's and Q's histograms    
    bin_range = [min([P Q]) max([P Q])];
    if bin_range(1) == bin_range(2)
        KL_div = 0;
        return;
    end
    P_hist = HistogramCustom( P, BIN_RES, bin_range );
    P_hist = P_hist/sum(P_hist(P_hist>0));
    if sum(P_hist) <= (1-new_eps) || sum(P_hist) >= (1+new_eps)
        error(['Probabilty distribution over P does not sum to 1 (it sums to ' num2str(sum(P_hist)) '): something bad happened :(']);
    end
    Q_hist = HistogramCustom( Q, BIN_RES, bin_range );
    Q_hist = Q_hist/sum(Q_hist(Q_hist>0));
    if sum(Q_hist) <= (1-new_eps) || sum(Q_hist) >= (1+new_eps)
        error(['Probabilty distribution over Q does not sum to 1 (it sums to ' num2str(sum(P_hist)) '): something bad happened :(']);
    end
    %% sanity check for absolute continuity (Q=0 -> P=0 for all elems)    
    P_hist = GetRidOfZerosInProbDist(P_hist,new_eps);
    Q_hist = GetRidOfZerosInProbDist(Q_hist,new_eps);    
    if ~isempty(Q_hist(Q_hist~=0 & P_hist==0))
        error('P and Q must obey the absolute continuity assumption (Q==0 -> P==0 for all elems)');
    end
    %% calculate K-L divergence
    if ~exist('log_base','var')
        log_base = 10;
    end
    P_over_Q = P_hist./Q_hist;
    log_results = log(P_over_Q)/log(log_base);
    KL_div = sum(P_hist.*log_results); 
    if KL_div < 0
        error('KL divergene is less than 0. Should nto be possible');
    end
end

function X = GetRidOfZerosInProbDist(X,new_eps)
    perc_to_dist = 1e-3;
    perc_per_elem = perc_to_dist/size(X,2);
    X = X + perc_to_dist/size(X,2);   
    X(X>perc_per_elem) = X(X>perc_per_elem) - perc_to_dist./size(X(X>perc_per_elem),2);
    if sum(X) <= (1-new_eps) || sum(X) >= (1+new_eps)
        error(['Probabilty distribution over X does not sum to 1 (it sums to ' num2str(sum(P_hist)) '): something bad happened :(']);
    end
end
















