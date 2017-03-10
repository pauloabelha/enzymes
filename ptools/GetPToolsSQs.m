% get the grasping and action SQs from a list of ptools
function [ SQs_grasp, SQs_action ] = GetPToolsSQs( ptools, task )
    ptools = PTool2Matrix( ptools );    
    if ~exist('task','var')
        task='';
    end      
    % check if the ptools matrix is Nx21
    if size(ptools,2) ~= 21
       error(['The p-tool(s) should have 21 elements and it has ' num2str(size(ptools,2))]); 
    end
    SQs_grasp = zeros(1,15);
    SQs_action = zeros(1,15);
    for i=1:size(ptools,1)
        SQ_grasp = [ptools(i,1:5) 0 0 0 ptools(i,6:7) 0 0 0 0 0];
        SQ_action = [ptools(i,8:12) ptools(i,18:20) ptools(i,13:14) 0 0 ptools(i,15:17)]; 
        transf_list = GetTrasnfsSQsTask( SQ_grasp, SQ_action, task );
        SQs = ApplyTransfSQs({SQ_grasp,SQ_action},transf_list);
        SQs_grasp(i,:) = SQs{1};
        SQs_action(i,:) = SQs{2};
    end
end

