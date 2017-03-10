% rotates SQ1 to match SQ2 (first and second param)
%(default is aligning using Z vector, but it can be specified in third param)
%outputs SQ1 rotated, aligned with SQ2
function [ SQ1 ] = AlignSQs( SQ1, SQ2, vec )
    if ~exist('vec','var')
        vec=3;
    end
    SQ1 = AlignSQWithVector(SQ1,GetSQVector(SQ2,vec));
end

