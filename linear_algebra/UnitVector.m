function [ v ] = UnitVector( v )
    if norm(v) ~= 0
        v = v/norm(v);
    end
end

