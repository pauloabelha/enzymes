function [ vec ] = GetSQVector( SQ, vec )
    % default vector is the z vector
    if ~exist('vec','var')
        vec = [0;0;1];
    else
        if vec == 'x' || vec == 1
            vec = [1;0;0];
        elseif vec == 'y' || vec == 2
            vec = [0;1;0];
        elseif vec == 'z' || vec == 3
            vec = [0;0;1];
        else
            error('Please deefine a vector through an int (1, 2 or 3) or char ''x'', ''y'' or ''z''');
        end 
    end
    vec = GetEulRotMtx(SQ(6:8))*vec;
    vec = vec/norm(vec);
    for i=1:3
        if vec(i) >= -eps && vec(i) <= eps
            vec(i) = 0;
        end
    end
end

