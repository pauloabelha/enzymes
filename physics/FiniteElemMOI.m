function [I, min_D] = FiniteElemMOI(P, mass)
    if ischar(P) && P == "--help"
        disp('Function get_inertia_finite_elem');        
        disp('This function will output the MOI'); 
        disp('It will consider each point in the point cloud as a small sphere of radius equal to the mean dist accross all points.');
        disp('Then it will calculate the MOI by summing them all taking into account their positions');
        disp('Maximum total number of points in point cloud is 1e4 (de to memoty issues of N^2 point-distance calculation');
        disp('This function does not tae segments into account');
        disp('Params:'); 
        disp([char(9) 'First param: filepath to the point cloud']);
        disp([char(9) 'Second param: mass of point cloud']);
        disp('Written by Paulo Abelha Ferreira'); 
        I=[]; min_D=[];
        return;
    end
    if ~exist('P','var')
        error('Please define point cloud as first param');
    end
    if ~exist('mass','var')
        error('Please define the mass as second param');
    end
    if ischar(mass)
        mass = str2double(mass);
    end
    try
        CheckIsPointCloudStruct(P);
        pcl = P.v;
    catch
        if ischar(P)
            P = ReadPointCloud(P);
            pcl = P.v;
        else
            pcl = P;
        end
    end
    if size(pcl,1) > 1e4
        error(['Can only deal with point clouds with at most 10000 points; this one has ' num2str(size(pcl,1))]);
    end
    I = zeros(3,3);
    
    num_elems = size(pcl,1);
    
    D = pdist2(pcl, pcl);
    D(1:num_elems+1:end) = Inf;
    min_D = min(D,[],1);
    clear D;            
    
    elem_radius = mean(min_D)/2;
    elem_mass = mass / num_elems;
    elem_vol_contribution = (1/num_elems);
	elem_inertia = (2/5)*elem_mass*elem_radius^2;
    
    % calculate the individual moments of inertia for each SQ part
    Iparts = zeros(num_elems,3,3) + elem_inertia;
    
     % Get projection distances of elems' centers on axis passing by center of mass
    d = zeros(num_elems,3);
    for i=1:num_elems 
        elem_center_coord = pcl(i, end-2:end);
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
            d(i, axis_1) = sqrt( (elem_center_coord(axis_2)^2) + (elem_center_coord(axis_3)^2) );
        end
    end

    % For each axis, sum moment of inertia of each SQ projected on this axis
    for proj_axis1=1:3
        for proj_axis2=1:3
            sum=0; 
            for i=1:num_elems            
                sum=sum+Iparts(i,proj_axis1,proj_axis2)+(elem_vol_contribution*(d(i,proj_axis1)^2));
            end
            I(proj_axis1,proj_axis2) = sum;
        end
    end  
    disp('inertia');
    disp(I);
end

