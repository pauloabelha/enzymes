function [ categ_scores ] = GetDistPerCategory( scores, task_name )
    categ_scores = TaskCategorisation( scores, task_name );
    categ_count = zeros(5,1);
    for i=1:size(categ_count)
       categ_count(i) = size(categ_scores(categ_scores==i-1),1)/size(categ_scores,1); 
    end
    figure; bar(0:4,categ_count);
    title('Percentage in each category');
end

