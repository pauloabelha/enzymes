%% Calculates the MOI by fitting SQs to the pcl
% If SQs is a path or a struct it will be considered a pcl param
%   and the function will fit SQs to the function
% If SQs is a cell array it will be considered as a list of SQs
%
% The outputs are:
%   centre of mass
%   The I inertial matrix)
%   inertial (6x1 array) holding both centre of mass and inertia diagonal
%   the read pcl P is SQs was a path to a pcl file or a P struct 
%% By Paulo Abelha
function [ centre_mass, I, inertial, P ] = CalcCompositeMomentInertia( SQs, mass)
    %% deal with SQs param
    if iscell(SQs)
        P = [];
    else
        if ischar(SQs)
            P = ReadPointCloud(SQs);
        elseif isstruct(SQs)
            P = SQs;        
        else
            error('Unrecognized first param');
        end
        SQs = PCL2SQ( P, 4, 0, 0, [1 1 1 0 1] );         
    end

    if size(mass,2) == 21
        mass = mass(21);
    end
    % initialise moment of inertia
    I=zeros(3,3);

    centre_mass = CentreOfMass( SQs );
    
    % calculate the individual moments of inertia for each SQ part
    Iparts = zeros(size(SQs,2),3,3);
    for i=1:size(SQs,2)
        Iparts(i,:,:)=MomentInertiaSQ(SQs{i});
    end

    
    % Get projection distances of SQs centers on axis passing by center of mass
    d = zeros(size(SQs,2),3);
    for i=1:size(SQs,2) % == length(SQs)
        SQ_center_coord = SQs{i}(end-2:end);
        for proj_axis=1:3 
            % ( if 1 = "x axis" for example, then 2 = y axis, and 3 = z axis)
            % To get the distance to the axis, we use Pythagoras theorem. 
            % This distance is then given by : (on x axis for example)
            %
            % dist_to_x_axis_passing_by_centerOfMass = sqrt(SQ_coord(y)^2+SQ_coord(z)^2)
            % 
            % In order to be generic, we use the modulo to get the next
            % axis id (1, 2 or 3). for example, if axis_1 has the value 2,
            % next axis (axis_2) will get 3 and the last one will get 1.
            % Since the modulo 3 gives us 0,1 or 2, we first apply the
            % modulo then add 1 to the resulting id.
            axis_1 = proj_axis;
            axis_2 = mod(axis_1,3)+1;
            axis_3 = mod(axis_1+1,3)+1;
            d(i, axis_1) = sqrt( (SQ_center_coord(axis_2)^2) + (SQ_center_coord(axis_3)^2) );
        end
    end

    % For each axis, sum moment of inertia of each SQ projected on this axis
    total_volume = 0;
    for  i=1:size(SQs,2)
        total_volume = total_volume + VolumeSQ(SQs{i});
    end
    for proj_axis=1:3
        sum=0; 
        for i=1:size(SQs,2)
            SQ_volume = VolumeSQ(SQs{i});
            SQ_mass = mass*(SQ_volume/total_volume);
            sum=sum+Iparts(i,proj_axis,proj_axis)+(SQ_mass*(d(i,proj_axis)^2));
        end
        I(proj_axis,proj_axis) = sum;
    end
    inertial = [centre_mass diag(I)'];
end