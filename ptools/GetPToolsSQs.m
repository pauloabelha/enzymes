% get the grasping and action SQs from a list of ptools
function [ SQs_grasp, SQs_action ] = GetPToolsSQs( ptools, task )
    ptools = PTool2Matrix( ptools );    
    if ~exist('task','var')
        task='';
    end      
    % check if the ptools matrix is Nx25
    if size(ptools,2) ~= 25
       error(['The p-tool(s) should have 21 elements and it has ' num2str(size(ptools,2))]); 
    end
    SQs_grasp = zeros(1,15);
    SQs_action = zeros(1,15);
    for i=1:size(ptools,1)
        SQ_grasp = [ptools(i,1:5) pi 0 0 ptools(i,6:7) ptools(i,8:9) 0 0 0];        
        SQ_action = [ptools(i,10:14) ptools(i,22:24) ptools(i,15:16) ptools(i,17:18) ptools(i,19:21)]; 
        % revert if bending
        if SQ_grasp(11) > 0
            SQ_grasp(6) = mod(SQ_grasp(6) + pi,2*pi);
        end
        if SQ_action(11) > 0
            SQ_action(6) = mod(SQ_action(6) + pi,2*pi);
        end
        transf_list = GetTrasnfsSQsTask( SQ_grasp, SQ_action, task );
        SQs = ApplyTransfSQs({SQ_grasp,SQ_action},transf_list);
        SQs_grasp(i,:) = SQs{1};
        SQs_action(i,:) = SQs{2};
    end
end

