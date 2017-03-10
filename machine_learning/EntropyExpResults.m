%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
% based on MacKay's bible
%
%% Entropy of an experimental result
%   Get entropy of a vector with experimental results
%
% Inputs:
%   P - 1 * N vector with experimental results
%   log_base - desired log base (e.g. 2 for getting the answer in "bits")
%       default is base 2
% Outputs:
%   entropy - Average Shanon information content (in the chosen log base)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ H ] = EntropyExpResults( P, log_base )
    %% sanity checks    
    if ~exist('P','var')
        error('The function needs at least one parameter P with the experimental results');
    end
    CheckNumericArraySize(P,[1 Inf]);
    if ~exist('log_base','var')
        warning('Log base not defined: using base 2');
        log_base = 2;
    end
    if exist('log_base','var')
        CheckScalarInRange( log_base, 'closed-open', [2 Inf] );
    end    
       
    %% return max entropy if P is uniform
    if min(P) == max(P)
        H = log(size(P,2))/log(log_base);
        return;
    end
    %% get P's prob mass
    P_mass = GetProbDistExpResults(P);
    %% get log in the desired base
    % whenever P_hist is 0, log(1/P_hist) = 0
    log_1_over_P = zeros(1,size(P_mass,2));
    non_zero_P_mass_ixs = P_mass~=0;
    log_1_over_P(non_zero_P_mass_ixs) = log(1./P_mass(non_zero_P_mass_ixs))./log(log_base);
    %% get entropy
    H = sum(P_mass.*log_1_over_P);
    CheckScalarInRange( H, 'closed-open', [0 Inf] );
end