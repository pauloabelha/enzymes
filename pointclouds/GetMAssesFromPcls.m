function [ tool_mases ] = GetMAssesFromPcls( root_folder, plot_fig )
    
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end

    pcl_filenames = FindAllFilesOfType({'ply'},root_folder);
    tot_toc = 0;
    tool_mases = zeros(1,size(pcl_filenames,2));
    for i=1:size(pcl_filenames,2)
        tic;        
        P = ReadPointCloud([root_folder pcl_filenames{i}]);
        tool_mases(i) = GetToolMass( P, pcl_filenames{i}(1:end-4) );
        disp(pcl_filenames{i});
        disp(['    Mass:  ' num2str(tool_mases(i))]);
        tot_toc = tot_toc+toc;
        avg_toc = tot_toc/i;
        estimated_time_hours = (avg_toc*(size(pcl_filenames,2)-i))/(24*60*60);
        disp(['Estimated time to finish (HH:MM:SS): ' datestr(estimated_time_hours, 'HH:MM:SS')]);
    end
    
    if plot_fig
        figure;
        plot(tool_mases);
        ax = gca;
        ax.XTickLabel = pcl_filenames;
        ax.XTickLabelRotation = 90;
        ax.XTick = 1:size(pcl_filenames,2);  
        title('Tool masses');
    end

end

function mass = GetToolMass( P, tool_name )
    tool_subnames = strsplit(tool_name,'_');
    tool_category = tool_subnames{1};
    tool_materials = tool_subnames{2};
    
    P.f = delaunay(P.v(:,1), P.v(:,2), P.v(:,3));
    
    %[totalVolume,~] = triangulationVolume(P.f,P.v(:,1),P.v(:,3),P.v(:,3));
    normals = faceNormal(P.v, P.f);
    totalVolume = abs(meshVolume(P.v, P.f));
    
    if size(tool_materials,2) == 1
        density = MaterialDensities( tool_materials ) ;
        raw_mass = density*totalVolume;
    elseif size(tool_materials,2) == 3
       material_1 =  tool_materials(1);
       density_1 = MaterialDensities( material_1 );
       material_1_prop = (str2double(tool_materials(2))/10);
       vol_1 = material_1_prop*totalVolume;
       mass_1 = density_1*vol_1;
       material_2 =  tool_materials(3);
       density_2 = MaterialDensities( material_2 );
       mass_2 = density_2*(totalVolume-vol_1);
       raw_mass = mass_1 + mass_2;
    else
        error(['There is a problem with the substring ''' tool_materials ''' representing the material of the tool named: ' tool_name]);
    end  

    vol_correc_factor = 1;
    switch tool_category
        case 'breadknife'
            vol_correc_factor = 0.6;
            mass_lower_bound = 0.2;
            mass_upper_bound = 0.3;
        case 'chineseknife'
            vol_correc_factor = 0.075;  
            mass_lower_bound = 0.3;
            mass_upper_bound = 0.5;
        case 'fryingpan'
            vol_correc_factor = 0.15; 
            mass_lower_bound = 0.5;
            mass_upper_bound = 1;
        case 'hammer'
            vol_correc_factor = 0.4; 
            mass_lower_bound = 0.6;
            mass_upper_bound = 1;
        case 'kitchenknife'
            vol_correc_factor = 0.3;
            mass_lower_bound = 0.2;
            mass_upper_bound = 0.4;
        case 'ladle'
            vol_correc_factor = 0.3;
            mass_lower_bound = 0.1;
            mass_upper_bound = 0.3;
        case 'mallet'
            vol_correc_factor = 0.4;
            mass_lower_bound = 0.4;
            mass_upper_bound = 1;
        case 'meshspatula'
            vol_correc_factor = 0.4;   
            mass_lower_bound = 0.1;
            mass_upper_bound = 0.4;
        case 'mug'
            vol_correc_factor = 0.15; 
            mass_lower_bound = 0.2;
            mass_upper_bound = 0.4;
        case 'pencil'
            vol_correc_factor = 0.2;
            mass_lower_bound = 0.001;
            mass_upper_bound = 0.005;
        case 'pen'
            vol_correc_factor = 0.2;  
            mass_lower_bound = 0.002;
            mass_upper_bound = 0.01;
        case 'rollingpin'
            vol_correc_factor = 0.4; 
            mass_lower_bound = 0.3;
            mass_upper_bound = 0.5;
        case 'skillet'
            vol_correc_factor = 0.4;
            mass_lower_bound = 0.6;
            mass_upper_bound = 1;
        case 'spatula'
            vol_correc_factor = 0.4;
            mass_lower_bound = 0.1;
            mass_upper_bound = 0.4;
        case 'spoon'
            vol_correc_factor = 0.15; 
            mass_lower_bound = 0.05;
            mass_upper_bound = 0.3;
        case 'squeegee'
            vol_correc_factor = 0.4; 
            mass_lower_bound = 0.05;
            mass_upper_bound = 0.2;
        case 'tablefork'
            vol_correc_factor = 0.2;
            mass_lower_bound = 0.1;
            mass_upper_bound = 0.3;
        case 'tableknife'
            vol_correc_factor = 0.2; 
            mass_lower_bound = 0.1;
            mass_upper_bound = 0.3;
    end
     mass = vol_correc_factor*raw_mass;
     max_iter = 1e3;
     ix = 1;
     while mass < mass_lower_bound || mass > mass_upper_bound
         ix = ix + 1;
         if ix > max_iter
             warning(['Could now find a suitable mass for tool ' tool_name '. Assigning average mass (between lower and upper bound)']);
             mass = (mass_upper_bound+mass_lower_bound)/2;
         end
         if mass < mass_upper_bound
             mass=mass*1.1;
         else
             mass=mass/1.1;
         end
     end
end
