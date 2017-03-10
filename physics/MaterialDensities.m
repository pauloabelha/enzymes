function [ density ] = MaterialDensities( material )

% 	a = aluminium
% 	c = ceramic
% 	p = plastic
% 	s = steel
% 	w = wood

    switch material
        case 'a'
            density = 2700;
            return;
        case 'c'
            density = 3000;
            return;        
        case 'p'
            density = 900;
            return;
        case 's'
            density = 7400;
            return;
        case 'w'
            density = 500;
            return;
    end
    error(['Could not find density for material: ' material]);
end

