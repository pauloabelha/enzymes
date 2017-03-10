function [ pTool_vecs_new ] = AddIntertialParams( pTool_vecs, task_name ) 
    if size(pTool_vecs,2) ~= 18
        error('This function needs as input pTools with 18 params (without inertial)');
    end
    masses = pTool_vecs(:,18);
    inertials = zeros(size(pTool_vecs,1),6);
    parfor i=1:size(pTool_vecs,1)
        [~,SQs,~] = getPFromPToolVec(pTool_vecs(i,:), task_name);        
        [ center_mass, ~, I_diag ] = CalcCompositeMomentInertia( SQs, masses(i));
        inertials(i,:) = [center_mass I_diag'];
    end
    pTool_vecs_new = [pTool_vecs inertials];
end