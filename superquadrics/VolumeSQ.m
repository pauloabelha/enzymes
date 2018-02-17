function volume = VolumeSQ( SQ )
    if SQ(5) < 0
        volume = VolumeParaboloid( SQ );
        return;
    end
    a=SQ(1:3);
    epsilon=SQ(4:5);
    volume = 0;
    if ~isempty(SQ)
        volume = 2*a(1)*a(2)*a(3)*epsilon(1)*epsilon(2)*beta(epsilon(1)/2 +1,epsilon(1))*beta(epsilon(2)/2,epsilon(2)/2);
    end
end