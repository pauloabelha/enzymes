% this function will rotate the SQ to align its z axis with the provided vector
function [ SQ, rot_SQ ] = AlignSQWithVector( SQ, vec, SQ_axis )
    if ~exist('SQ_axis','var')
        SQ_axis = 3;
    end
    % bending requires special rotation in X axis
    if SQ_axis == 1 && SQ(11) > 0
        vec = [-vec(1) vec(2) vec(3)];
    end
    SQ_vec = GetSQVector( SQ, SQ_axis );
    r = vrrotvec(SQ_vec,vec);
    rot_SQ = vrrotvec2mat(r);
    SQ = RotateSQWithRotMtx(SQ,rot_SQ);
end

