function [ toroid ] = GetToroid( SQ, thickness )
    bound = 1e-3;
    if thickness == 0 || thickness > (1+bound)
        error('Thickness must be in the interval <0 1]');
    end
    if thickness == 1
        a4=0;
    else
        a4 = (1/thickness)-1;
    end
    a1 = SQ(1)/(a4+1);
    a2 = SQ(2)/(a4+1);
    toroid = [a1 a2 SQ(3) a4 SQ(4:end)];
end

