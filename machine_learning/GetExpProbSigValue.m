function [ minus_prob, plus_prob ] = GetExpProbSigValue( P_bins, P_mass, mean_prob, max_mass )
    if ~exist('max_mass','var')
        max_mass = 0.95;
    end
    half_max_mass = max_mass/2;
    accum_prob_mass = 0;
    ix = 1;
    while P_bins(ix) <= mean_prob        
        accum_prob_mass = accum_prob_mass + P_mass(ix);
        if accum_prob_mass >= half_max_mass
            minus_prob = P_bins(ix);
            break;
        end
    end
    while P_bins(ix) <= mean_prob        
        accum_prob_mass = accum_prob_mass + P_mass(ix);
        if accum_prob_mass >= half_max_mass
            minus_prob = P_bins(ix);
            break;
        end
    end
end

