function [I] = FiniteElemMOI(pcl, density)
    CheckNumericArraySize(pcl,[Inf 3]);
    if size(pcl,1) > 10000
        error('Can only deal with point clouds with at most 1e4 points');
    end
    if ~exist('density','var')
        density = 1;
    end
    I = zeros(3,3);
    
    num_elems = size(pcl,1);
    
    D = pdist2(pcl, pcl);
    D(1:num_elems+1:end) = Inf;
    min_D = min(D,[],1);
    clear D;            
    
    elem_radius = mean(min_D)/2;
    elem_vol = (4/3)*pi*elem_radius^2;
    total_volume = num_elems * elem_vol;
    elem_vol_contribution = (elem_vol/total_volume);
	elem_inertia = (8*pi/15)*elem_radius^5*density;
    
    % calculate the individual moments of inertia for each SQ part
    Iparts = zeros(num_elems,3,3);
    for i=1:num_elems
        Iparts(i,:,:) = elem_inertia;
    end
    
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
    for proj_axis=1:3
        sum=0; 
        for i=1:num_elems            
            sum=sum+Iparts(i,proj_axis,proj_axis)+(elem_vol_contribution*(d(i,proj_axis)^2));
        end
        I(proj_axis,proj_axis) = sum;
    end  
end

