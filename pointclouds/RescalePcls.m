function [ Ps ] = RescalePcls( root_folder, rescale_factor, add_noise, write_file, output_folder, plot_fig )
    
    if ~exist('add_noise','var')
        add_noise = 0;
    end

    if ~exist('write_file','var')
        write_file = 0;
    end
    
    if ~exist('output_folder','var')
        output_folder = '';
    else
        system(['mkdir ' root_folder output_folder]);
    end
    
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end

    pcl_filenames = FindAllFilesOfType({'ply'},root_folder);
    Ps = {};
    tot_toc = 0;
    max_sizes = zeros(1,size(pcl_filenames,2));
    for i=1:size(pcl_filenames,1)
        tic;       
        tool_categ = GetTolCateg( pcl_filenames{i}(1:end-4) );        
        P = ReadPointCloud([root_folder pcl_filenames{i}]);
        old_scale = range(P.v);
        [tool_max_size, rescale_noise] = ToolMaxSize( tool_categ );
        if ~exist('rescale_factor','var') || rescale_factor == -1
            max_range = max(range(P.v));
            if max_range < 1
                rescale_factor = 1;
            else
                rescale_factor = 10^-round(log10(max_range));;
            end
            P = RescalePCL( P, rescale_factor, rescale_noise );
        else
            if exist('rescale_factor','var') || rescale_factor > 0
            P = RescalePCL( P, rescale_factor, rescale_noise );
            else            
                tool_max_size = tool_max_size * ( 1 - rescale_noise );           
                mult_rescale = tool_max_size/max(old_scale);
                P = RescalePCL( P, mult_rescale, rescale_noise );
            end
        end
        P = ApplyPCAPCl(P);
        if ~add_noise
            rescale_noise = 0;
        else
            rescale_noise = randsample(0:rescale_noise/10:rescale_noise,1);
        end
        
        new_scale = range(P.v);
        max_sizes(i) = tool_max_size;
        Ps{end+1} = P;
        if write_file
            WritePly(P,[root_folder output_folder pcl_filenames{i}(1:end-4) '_rescaled.ply']);            
        end
        disp(pcl_filenames{i});
        disp(['    Tool category:  ' tool_categ]);
        disp(['    Old scale:  ' num2str(old_scale)]);
        disp(['    New scale:  ' num2str(new_scale)]);
        disp(['    Max size: ' num2str(max_sizes(i))]);
        disp(['    Rescale noise: ' num2str(rescale_noise)]);
        tot_toc = tot_toc+toc;
        avg_toc = tot_toc/i;
        estimated_time_hours = (avg_toc*(size(pcl_filenames,2)-i))/(24*60*60);
        disp(['Estimated time to finish (HH:MM:SS): ' datestr(estimated_time_hours, 'HH:MM:SS')]);
    end
    fileattrib([root_folder output_folder '/'],'+w','a');
    fileattrib([root_folder output_folder '/*'],'+w','a');
    
    if plot_fig
        figure;
        plot(max_sizes);
        ax = gca;
        ax.XTickLabel = pcl_filenames;
        ax.XTickLabelRotation = 90;
        ax.XTick = 1:size(pcl_filenames,2);  
        title('Maximum size of bounding box');
    end
end

function tool_categ = GetTolCateg( tool_name ) 
    tool_categ = '';
    list_categs = {'bottle','bowl','breadknife','chineseknife','chopstick', 'cup', ...
        'knifechinese', 'fryingpan','hammer','tableknife','kitchenknife','ladle','mallet','meshspatula', ...
        'mug','fork','pencil','pen','rollingpin','servingspoon','skillet','spatula','spoon', ...
        'squeegee','tablefork','tableknife','tablespoon','vase'};    
    for i=1:numel(list_categs)
        k = findstr(list_categs{i},tool_name);
        if ~isempty(k)
            tool_categ = list_categs{i};
            break;
        end
    end
    if isempty(tool_categ)
        warning(['Could not find tool caregory for tool name: ' tool_name]);
    end
end


function [max_size, rescale_noise] = ToolMaxSize( tool_category )   
    rescale_noise = 0.1;
    switch tool_category
        case 'breadknife'
            max_size = 0.3;
            return;
        case 'bowl'
            max_size = 0.2;
            return;
        case 'chineseknife'
            max_size = 0.35;
            return;
        case 'chopstick'
            max_size = 0.2;
            return;        
        case 'knifechinese'
            max_size = 0.35;
            return; 
        case 'fryingpan'
            max_size = 0.5;
            return;
        case 'fork'
            max_size = 0.3;
            return;
        case 'hammer'
            max_size = 0.4;
            return;
        case 'kitchenknife'
            max_size = 0.3;
            return;
        case 'tableknife'
            max_size = 0.25;
            return;
        case 'ladle'
            max_size = 0.15;
            return;
        case 'mallet'
            max_size = 0.4;
            return;
        case 'meshspatula'
            max_size = 0.4;
            return;
        case 'mug'
            max_size = 0.15;
            return;
        case 'pencil'
            max_size = 0.2;
            return;
        case 'pen'
            max_size = 0.2;
            return;
        case 'rollingpin'
            max_size = 0.4;
            return;
        case 'servingspoon'
            max_size = 0.4;
            return;
        case 'skillet'
            max_size = 0.4;
            return;
        case 'spatula'
            max_size = 0.3;
            return;
        case 'tablespoon'
            max_size = 0.25;
            return;
        case 'squeegee'
            max_size = 0.2;
            return;
        case 'tablefork'
            max_size = 0.25;
            return;
        case 'bottle'
            max_size = 0.3;
            return;
        case 'vase'
            max_size = 0.4;
            return;
        case 'cup'
            max_size = 0.15;
            return;
        case 'plate'
            max_size = 0.25;
            return;
    end
    warning(['Could not find tool category ' tool_category]);
    max_size = 0.5;    
end
