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
function [ P_mass, P_bins ] = GetProbDistExpResults( P, BIN_RES, MAX_MEM )
    CheckNumericArraySize(P,[1 Inf]);    
    %% max memory to be used (in GB) in order to choose bin resolution
    if exist('MAX_MEM','var')
        CheckIsScalar(MAX_MEM);
    else
        MAX_MEM = .001; 
    end  
    % MATLAB's float is 32 bit and we need to store two big vectors
    MAX_N_ELEMS = MAX_MEM*8e9/(32*2);
    %% bin resolution
    if exist('BIN_RES','var')
        CheckIsScalar(BIN_RES);
    else    
        BIN_RES = size(P,1)/MAX_N_ELEMS;    
    end
    bin_range = [min(P) max(P)];     
    [P_hist, P_bins] = HistogramCustom( P, BIN_RES, bin_range );
    P_mass = P_hist/sum(P_hist(P_hist>0));
end

