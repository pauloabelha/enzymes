function [ centre_mass ] = CentreOfMass( SQs )    
    if ~iscell(SQs)
        SQ_{1} = SQs;
        SQs = SQ_{1};
    end
    total_volume = 0;
    
    for i=1:size(SQs,2)
        SQ_vol = VolumeSQ(SQs{i});
        sum_pos = zeros(1,3);
        for j=1:3
            sum_pos(j) = sum_pos(j) + SQs{i}(end+(j-3));
        end
        sum_pos = sum_pos.* SQ_vol;
        total_volume = total_volume + SQ_vol;
    end
    centre_mass = sum_pos ./ total_volume;
end

