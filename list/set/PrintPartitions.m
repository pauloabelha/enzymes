% By Paulo Abelha
%
% Print all sets of the partitions in PI
function [ output_args ] = PrintPartitions( PI )
    % each partition
    for i=1:numel(PI)
        disp(['Partition #' num2str(i)]);
        % each set in a partition
        for j=1:numel(PI{i})
            disp(['    Set #' num2str(j)]);
            % each element in a set
            disp(PI{i}{j});
        end
    end
end

