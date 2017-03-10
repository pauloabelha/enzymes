function [ area ] = AreaSQ( SQ )
    area = 0;
    if ~isempty(SQ)
        area = 2.*SQ(:,1).*SQ(:,2).*SQ(:,5).*beta(SQ(:,5)/2,(SQ(:,5)+2)/2);
    end
end

