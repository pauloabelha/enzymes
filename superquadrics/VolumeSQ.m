function volume = VolumeSQ( SQ )
    if SQ(5) < 0
        volume = VolumeParaboloid( SQ );
        return;
    end
    volume = 0;
    if ~isempty(SQ)
        volume = 2.*SQ(:,1).*SQ(:,2).*SQ(:,3).*SQ(:,4).*SQ(:,5).*beta((SQ(:,4)/2)+1,SQ(:,4)).*beta(SQ(:,5)/2,SQ(:,5)/2);
    end
end