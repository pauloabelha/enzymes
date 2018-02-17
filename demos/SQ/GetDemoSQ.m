% By Paulo Abelha
% This demo gives back a typical SQ ot all typical SQ types
function [ SQ, SQ_types ] = GetDemoSQ( SQ_type )
    SQ_types = {'Superegg',...
                'Cube','Sphere','Double_Tetrahedron',...
                'Cuboid','Cylinder','Cone','Double_Cone',...
                'Pyramid',...
                'Round_Bowl', 'Square_Bowl', 'Small_Bowl'};
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
            SQ = [1 1 5 .1 .1 0 0 0 0 0 0 0 0 0 0];
        case SQ_types{6}
            SQ = [1 1 3 .1 1 0 0 0 0 0 0 0 0 0 0];
        case SQ_types{7}
            SQ = [1 2 3 .1 1 0 0 0 -1 -1 0 0 0 0 0];
        case SQ_types{8}
            SQ = [1 2 3 .1 1 0 0 0 -1 1 0 0 0 0 0];
        case SQ_types{9}
            SQ = [1 2 3 .1 .1 0 0 0 -1 -1 0 0 0 0 0];
        case SQ_types{10}
            SQ = [2 2 1 1 1 0 0 0  0 0 0 -1 0 0 0];
        case SQ_types{11}
            SQ = [2 2 1 .1 .1 0 0 0  0 0 0 -1 0 0 0];
        case SQ_types{12}
            SQ = [0.075 0.075 0.02 1 1 0 0 0  0 0 0 -1 0 0 0];
        otherwise
            error(['SQ type unkown. Available types: ' PrettyCellArrayString( SQ_types )]);
    end
end

