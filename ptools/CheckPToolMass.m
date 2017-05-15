function ptool = CheckPToolMass(ptool)
    MIN_MASS = 0.001;
    % check if ptool mass is larger than minimum   
    if ptool(end) < 0.001
       warning(['P-tool has mass ' num2str(ptool(end)) ' and minimum mass is ' num2str(MIN_MASS)]); 
       ptool(end) = MIN_MASS;
    end
end