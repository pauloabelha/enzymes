% add intertial params to a ptool (moment of inertia (MOI) and centre of mass
% input ptools can be a cell array of ptools, a matrix N x 21 of ptools or
% a single ptool vector
% if we have a task_name as input, we first rotate the ptool
% according to the task, and then calculate its inertial params
function [ ptools_inertia ] = AddInertialToPtools( ptools )
    %% check ptool params
    ptools = PTool2Matrix( ptools );
    % create the new p-tool matrix to hold p-tools with added inertial params
    ptools_inertia = zeros(size(ptools,1),21+6);
    for i=1:size(ptools,1)
        [ SQ_grasp, SQ_action ] = GetPToolsSQs( ptools(i,:) );
        [ centre_mass, I ] = CalcCompositeMomentInertia( {SQ_grasp,SQ_action}, ptools(i,21));
        ptools_inertia(i,:) = [ptools(i,:) centre_mass diag(I)'];
    end
end