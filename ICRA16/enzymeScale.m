%Given a seed and a probability distribution over SQs, returns a fitted SQ
%pcl is a point cloud
%seed is a point in pcl (may be empty, in which case select random seed)
function [scale] = enzymeScale(scale,pcls,prob_random_scale)
    epsilon = 0.01;
    for mode=1:size(pcls,2)
        segm = 1;
        while segm<=size(pcls{mode}{2},2)
            if ~isempty(pcls{mode}{2}{segm}) && ~isempty(pcls{mode}{2}{segm}{1})
                for part=1:size(pcls{mode}{2}{segm}{2},2)
                    %if segment exists and it has a fitted SQ
                    if ~isempty(pcls{mode}{2}{segm}{1}) && ~isempty(pcls{mode}{2}{segm}{2}{part}{1})
                        %search for option for the part in the scale matrix
                        option_already_exists = false;
                        n_options = 0;
                        option = 1;
                        segm_scale = calculatePCLSegScale(pcls{mode}{2}{segm}{1});
                        while ~option_already_exists && option<=size(scale,1) && part<=size(scale,2) && ~isempty(scale{option,part})                  
                            %increase number of options
                            n_options = n_options+1;
                            %check for similar option
                            if pdist([segm_scale;scale{option,part}(2:4)],'euclidean') <= epsilon
                                option_already_exists = true;
                            end  
                            option=option+1;
                        end
                        if ~option_already_exists
                            %split option in scale matrix to include new option
                            %assign probability to new option
                            end_ix=0;
                            if size(scale,1)<=n_options
                                end_ix=1;
                            end
                            scale{end+end_ix,part} = zeros(1,4);
                            scale{end,part}(1) = 1/(n_options+1);
                            %calculate scale of pcl segment                  
                            scale{end,part}(2:4) = segm_scale;
                            %update probability for the other options
                            if size(scale,1)>1
                                for i=1:n_options
                                    scale{i,part,1}(1) = scale{i,part,1}(1)*(1-scale{end,part,1}(1));
                                end
                            end
                        end
                        %maxs are there to avoid /0 and also a probability > 1
                        if randi(max(1,1/max(1e-10,prob_random_scale))) == 1
                            %split option in scale matrix to include new option
                            %assign probability to new option
                            end_ix=0;
                            if size(scale,1)<=n_options
                                end_ix=1;
                            end
                            scale{end+end_ix,part} = zeros(1,4);
                            scale{end,part}(1) = 1/(n_options+1);
                            %calculate scale of pcl segment                  
                            scale{end,part}(2:4) = [randi(100)/1000 randi(100)/1000 randi(100)/1000];
                            disp('New random scale created:');
                            disp(scale{end,part});
                            %update probability for the other options
                            if size(scale,1)>1
                                for i=1:n_options
                                    scale{i,part,1}(1) = scale{i,part,1}(1)*(1-scale{end,part,1}(1));
                                end
                            end
                        end
                    end
                end
            end
            segm=segm+1;
        end
    end
end

