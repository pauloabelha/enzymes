% By Paulo Abelha
% This demo gives back a typical SQ ot all typical SQ types
function [ SQ, SQ_types ] = GetDemoSQ( SQ_type )
    SQ_types = {'Superegg - https://en.wikipedia.org/wiki/Superegg',...
                'Cube','Sphere','Double_Tetrahedron',...
                'Cuboid','Cylinder','Cone','Double_Cone',...
                'Pyramid'};
    if ~exist('SQ_type','var')
        SQ = SQ_types;
        return;
    end
    switch SQ_type
        case SQ_types{1}
            SQ = [1 1 1.33 .6 .6 0 0 0 0 0 0 0 0 0 0];
        case SQ_types{2}
            SQ = [1 1 1 .1 .1 0 0 0 0 0 0 0 0 0 0];
        case SQ_types{3}
            SQ = [1 1 1 1 1 0 0 0 0 0 0 0 0 0 0];
        case SQ_types{4}
            SQ = [1 1 1 2 2 0 0 0 0 0 0 0 0 0 0];
        case SQ_types{5}
            SQ = [1 2 3 .1 .1 0 0 0 0 0 0 0 0 0 0];
        case SQ_types{6}
            SQ = [1 1 3 .1 1 0 0 0 0 0 0 0 0 0 0];
        case SQ_types{7}
            SQ = [1 2 3 .1 1 0 0 0 -1 -1 0 0 0 0 0];
        case SQ_types{8}
            SQ = [1 2 3 .1 1 0 0 0 -1 1 0 0 0 0 0];
        case SQ_types{9}
            SQ = [1 2 3 .1 .1 0 0 0 -1 -1 0 0 0 0 0];
        otherwise
            error('SQ type unkown :(');
    end
end

