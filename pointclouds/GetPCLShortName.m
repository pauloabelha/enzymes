function [ pcl_shortname ] = GetPCLShortName( pcl_name )
    if ~isempty(strfind(pcl_name,'out'))
        pcl_shortname = pcl_name(1:strfind(pcl_name,'out')-2);
    else
        pcl_shortname = pcl_name(1:strfind(pcl_name,'.ply')-1);   
    end
end

