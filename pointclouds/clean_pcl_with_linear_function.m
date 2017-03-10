%remove from pcl every point that is to the left of the plane defined by
%the function f = ax+b
%the abscissa and ordinate definethe visual plane through 
%which one visualizes the pcl for cleaning it
% visual_plane may be 0 (xy), 1 (xz) or 2 (yz)

%plot the pcl, rotate the plot until you visualize only a plane, this is
%the visual plane. Now come up with a function (straight line) that cleans
%the bits you want.

function [new_XYZ, ixs] = clean_pcl_with_linear_function( XYZ, cut_mode,a, b, abscissa, ordinate) 
        if strcmp(cut_mode,'cut_right')
            ixs = ((XYZ(:,ordinate)-b)/a)>=XYZ(:,abscissa);
        else
            ixs = ((XYZ(:,ordinate)-b)/a)<=XYZ(:,abscissa);            
        end
        new_XYZ = XYZ(ixs,:);
end

