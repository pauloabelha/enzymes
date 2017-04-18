function ptool = CheckPToolMass(ptool)
    MIN_MASS = 0.001;
    % check if ptool mass is larger than minimum   
    if ptool(21) < 0.001
       warning(['P-tool has mass ' num2str(ptool(21)) ' and minimum mass is ' num2str(MIN_MASS)]); 
       ptool(21) = MIN_MASS;
    end
end