% this function will rotate the SQ to align its z axis with the provided vector
function [ SQ, rot_SQ ] = AlignSQWithVector( SQ, vec )
    z_vec = GetSQVector( SQ );
    r = vrrotvec(z_vec,vec);
    rot_SQ = vrrotvec2mat(r);

    r = vrrotvec([0;0;1],vec);
    rm = vrrotvec2mat(r);  
    SQ = RotateSQWithRotMtx(SQ,rm);
end

